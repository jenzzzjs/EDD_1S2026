package routes;
use strict;
use warnings;
use Mojo::JSON qw(encode_json decode_json);
use File::Slurp qw(read_file write_file);



# Debe ser:
use lib './lib';
use Grafos::Grafo;
use Grafos::Dijkstra;
use Grafos::Visualizador;
use lib::Grafos::Dijkstra;
use lib::Grafos::Visualizador;

# Instancias globales
our $grafo = Grafos::Grafo->new();
our $dijkstra = Grafos::Dijkstra->new();
our $visualizador = Grafos::Visualizador->new();

sub registrar_rutas {
    my ($r) = @_;
    
    # Endpoint para cargar rutas desde archivo
    $r->post('/api/rutas/cargar' => sub {
        my ($c) = @_;
        my $data = $c->req->json;
        my $archivo = $data->{archivo} // 'rutas.dat';
        
        my $total = $grafo->cargar_desde_archivo($archivo);
        
        if ($total > 0) {
            $c->render(json => {
                success => 1,
                message => "Se cargaron $total rutas exitosamente desde $archivo",
                total_rutas => $total
            });
        } else {
            $c->render(json => {
                success => 0,
                message => "No se pudieron cargar rutas desde $archivo"
            }, status => 400);
        }
    });
    
    # Endpoint para agregar una nueva ruta
    $r->post('/api/rutas' => sub {
        my ($c) = @_;
        my $data = $c->req->json;
        
        my $origen = $data->{origen};
        my $destino = $data->{destino};
        my $distancia = $data->{distancia};
        
        if (!$origen || !$destino || !$distancia) {
            $c->render(json => {
                success => 0,
                message => "Faltan parámetros requeridos: origen, destino, distancia"
            }, status => 400);
            return;
        }
        
        if ($distancia !~ /^[\d\.]+$/ || $distancia <= 0) {
            $c->render(json => {
                success => 0,
                message => "La distancia debe ser un número positivo"
            }, status => 400);
            return;
        }
        
        $grafo->agregar_ruta($origen, $destino, $distancia);
        
        $c->render(json => {
            success => 1,
            message => "Ruta agregada exitosamente",
            ruta => {
                origen => $origen,
                destino => $destino,
                distancia => $distancia
            }
        });
    });
    
    # Endpoint para obtener ruta más corta
    $r->post('/api/rutas/camino-corto' => sub {
        my ($c) = @_;
        my $data = $c->req->json;
        
        my $origen = $data->{origen};
        my $destino = $data->{destino};
        
        if (!$origen || !$destino) {
            $c->render(json => {
                success => 0,
                message => "Faltan parámetros: origen y destino"
            }, status => 400);
            return;
        }
        
        my $resultado = $dijkstra->encontrar_camino_mas_corto($grafo, $origen, $destino);
        
        if ($resultado->{existe}) {
            $c->render(json => {
                success => 1,
                ruta => $resultado,
                message => $resultado->{mensaje}
            });
        } else {
            $c->render(json => {
                success => 0,
                message => $resultado->{mensaje}
            });
        }
    });
    
    # Endpoint para obtener todas las rutas
    $r->get('/api/rutas' => sub {
        my ($c) = @_;
        
        my $vertices = $grafo->obtener_vertices();
        my $aristas = $grafo->obtener_aristas();
        
        $c->render(json => {
            success => 1,
            vertices => $vertices,
            rutas => $aristas,
            total_vertices => scalar(@$vertices),
            total_rutas => scalar(@$aristas)
        });
    });
    
    # Endpoint para obtener estadísticas del grafo
    $r->get('/api/estadisticas' => sub {
        my ($c) = @_;
        
        my $aristas = $grafo->obtener_aristas();
        my $vertices = $grafo->obtener_vertices();
        
        my $distancia_total = 0;
        foreach my $arista (@$aristas) {
            $distancia_total += $arista->{distancia};
        }
        
        my $distancia_promedio = $distancia_total / scalar(@$aristas) if @$aristas > 0;
        
        $c->render(json => {
            success => 1,
            estadisticas => {
                total_vertices => scalar(@$vertices),
                total_rutas => scalar(@$aristas),
                distancia_total => $distancia_total,
                distancia_promedio => $distancia_promedio // 0,
                vertices => $vertices
            }
        });
    });
    
    # Endpoint para generar y obtener imagen del grafo
    $r->post('/api/grafo' => sub {
        my ($c) = @_;
        my $data = $c->req->json // {};
        
        my $camino_resaltado = $data->{camino};
        
        my $imagen_base64 = $visualizador->generar_imagen_base64($grafo, $camino_resaltado);
        
        if ($imagen_base64) {
            $c->render(json => {
                success => 1,
                imagen => $imagen_base64,
                message => "Grafo generado exitosamente"
            });
        } else {
            $c->render(json => {
                success => 0,
                message => "Error al generar el grafo"
            }, status => 500);
        }
    });
    
    # Endpoint para obtener imagen del grafo como PNG directo
    $r->get('/api/grafo/png' => sub {
        my ($c) = @_;
        
        my $imagen_data = $visualizador->generar_imagen($grafo);
        
        if ($imagen_data) {
            $c->res->headers->content_type('image/png');
            $c->render(data => $imagen_data);
        } else {
            $c->render(json => {
                success => 0,
                message => "Error al generar el grafo"
            }, status => 500);
        }
    });
    
    # Endpoint para registrar ubicación
    $r->post('/api/ubicacion' => sub {
        my ($c) = @_;
        my $data = $c->req->json;
        
        my $departamento = $data->{departamento};
        my $municipio = $data->{municipio};
        
        if (!$departamento || !$municipio) {
            $c->render(json => {
                success => 0,
                message => "Faltan parámetros: departamento y municipio"
            }, status => 400);
            return;
        }
        
        my $ubicacion = "$municipio, $departamento";
        my $timestamp = localtime();
        
        # Guardar en archivo de log
        open my $fh, '>>', 'ubicaciones.log';
        print $fh "$timestamp - $ubicacion\n";
        close $fh;
        
        $c->render(json => {
            success => 1,
            message => "Ubicación registrada exitosamente",
            ubicacion => $ubicacion,
            timestamp => $timestamp
        });
    });
    
    # Endpoint para eliminar todas las rutas
    $r->delete('/api/rutas' => sub {
        my ($c) = @_;
        
        $grafo->limpiar();
        
        $c->render(json => {
            success => 1,
            message => "Todas las rutas han sido eliminadas"
        });
    });
    
    # Endpoint para obtener información de un vértice específico
    $r->get('/api/vertices/:nombre' => sub {
        my ($c) = @_;
        my $nombre = $c->stash('nombre');
        
        if (!$grafo->existe_vertice($nombre)) {
            $c->render(json => {
                success => 0,
                message => "El vértice '$nombre' no existe"
            }, status => 404);
            return;
        }
        
        my $adyacentes = $grafo->obtener_adyacentes($nombre);
        
        $c->render(json => {
            success => 1,
            vertice => $nombre,
            adyacentes => $adyacentes,
            total_conexiones => scalar(@$adyacentes)
        });
    });
    
    # Endpoint para verificar conectividad entre dos vértices
    $r->post('/api/rutas/conectividad' => sub {
        my ($c) = @_;
        my $data = $c->req->json;
        
        my $origen = $data->{origen};
        my $destino = $data->{destino};
        
        my $existe_directa = $grafo->existe_arista($origen, $destino);
        my $camino = $dijkstra->encontrar_camino_mas_corto($grafo, $origen, $destino);
        
        $c->render(json => {
            success => 1,
            conectividad => {
                origen => $origen,
                destino => $destino,
                conexion_directa => $existe_directa,
                existe_camino => $camino->{existe},
                distancia_camino_corto => $camino->{existe} ? $camino->{distancia} : undef
            }
        });
    });
}

1;