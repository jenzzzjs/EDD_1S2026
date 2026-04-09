#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite -signatures;


# CLASE VERTICE
package Vertice;
use Mojo::Base -base;

# ATRIBUTOS
has 'nombre';                    # Identificador único del vértice
has 'creado' => sub { time() };  # Timestamp de creación (útil para debugging)
has 'adyacentes' => sub { [] };  # Lista de aristas que salen de este vértice

# AGREGA UNA ARISTA A LA LISTA DE ADYACENTES
sub agregar_adyacente {
    my ($self, $arista) = @_;
    push @{$self->adyacentes}, $arista;
}

# OBTIENE TODAS LAS ARISTAS ADYACENTES 
sub obtener_adyacentes {
    my ($self) = @_;
    return @{$self->adyacentes};
}

1;

# CLASE ARISTA
# Representa una conexión entre dos vértices con un peso/distancia
package Arista;
use Mojo::Base -base;

# ATRIBUTOS
has 'origen';       # Referencia al vértice de origen 
has 'destino';      # Referencia al vértice de destino 
has 'distancia';    # Peso de la arista, cuanto cuesta para recorrerla
has 'creado' => sub { time() };

# CONVIERTE LA ARISTA A UN HASH PARA RESPUESTAS JSON
sub to_hash {
    my ($self) = @_;
    return {
        origen => $self->origen->nombre,   # Extrae solo el nombre, no el objeto
        destino => $self->destino->nombre,
        distancia => $self->distancia
    };
}

# COMPARA si esta arista conecta dos vértices específicos 
sub equals {
    my ($self, $origen_nombre, $destino_nombre) = @_;
    return ($self->origen->nombre eq $origen_nombre && 
            $self->destino->nombre eq $destino_nombre);
}

1;


# CLASE GRAFO

package Grafo;
use Mojo::Base -base;

# ATRIBUTOS
has 'vertices' => sub { {} };        # Hash: nombre => objeto Vertice
has 'aristas'  => sub { [] };        # Array de objetos Arista
has 'total_vertices' => sub { 0 };   # Contador de vértices
has 'total_aristas'  => sub { 0 };   # Contador de aristas

# AGREGA UN NUEVO VÉRTICE (si no existe)
sub agregar_vertice {
    my ($self, $nombre) = @_;
    
    # Prevenir duplicados
    return 0 if exists $self->vertices->{$nombre};
    
    my $vertice = Vertice->new(nombre => $nombre);
    $self->vertices->{$nombre} = $vertice;
    $self->total_vertices($self->total_vertices + 1);
    
    return 1;
}

# OBTIENE UN VÉRTICE POR SU NOMBRE
sub obtener_vertice {
    my ($self, $nombre) = @_;
    return $self->vertices->{$nombre};
}

# VERIFICA SI UN VÉRTICE EXISTE
sub existe_vertice {
    my ($self, $nombre) = @_;
    return exists $self->vertices->{$nombre};
}

# AGREGA UNA ARISTA (crea vértices automáticamente si no existen)
sub agregar_arista {
    my ($self, $origen_nombre, $destino_nombre, $distancia) = @_;
    
    
    $self->agregar_vertice($origen_nombre);
    $self->agregar_vertice($destino_nombre);
    
    my $origen = $self->obtener_vertice($origen_nombre);
    my $destino = $self->obtener_vertice($destino_nombre);
    
    # Buscar si ya existe la arista 
    my $arista_existente = $self->buscar_arista($origen_nombre, $destino_nombre);
    
    # Si existe, actualizar la distancia (última asignación prevalece)
    if ($arista_existente) {
        $arista_existente->distancia($distancia);
        return $arista_existente;
    }
    
    # Crear nueva arista
    my $arista = Arista->new(
        origen => $origen,
        destino => $destino,
        distancia => $distancia
    );
    
    # Registrar en el grafo
    push @{$self->aristas}, $arista;
    
    # Registrar en el vértice origen (adyacencia)
    $origen->agregar_adyacente($arista);
    
    $self->total_aristas($self->total_aristas + 1);
    
    return $arista;
}

# BUSCA UNA ARISTA POR NOMBRES DE ORIGEN Y DESTINO
sub buscar_arista {
    my ($self, $origen_nombre, $destino_nombre) = @_;
    
    foreach my $arista (@{$self->aristas}) {
        if ($arista->equals($origen_nombre, $destino_nombre)) {
            return $arista;
        }
    }
    
    return undef;
}

# OBTIENE LOS VECINOS DE UN VÉRTICE (devuelve array de hashes)
# Este método es CRUCIAL para el algoritmo de Dijkstra
sub obtener_adyacentes {
    my ($self, $vertice_nombre) = @_;
    
    my $vertice = $self->obtener_vertice($vertice_nombre);
    return [] unless $vertice;  # Retornar lista vacía si no existe
    
    my @adyacentes = ();
    foreach my $arista ($vertice->obtener_adyacentes()) {
        push @adyacentes, {
            vertice => $arista->destino->nombre,  # Solo el nombre, no el objeto
            distancia => $arista->distancia        # Peso de la arista
        };
    }
    
    return \@adyacentes;
}

sub dijkstra {
    my ($self, $origen_nombre, $destino_nombre) = @_;
    
    # validacion de los vertices
    # Verifica que el origen y destino existan en el grafo
    return { existe => 0, mensaje => "Origen '$origen_nombre' no existe" }
        unless $self->existe_vertice($origen_nombre);
    
    return { existe => 0, mensaje => "Destino '$destino_nombre' no existe" }
        unless $self->existe_vertice($destino_nombre);
    
   
    my %distancias;      # Almacena la distancia mínima conocida a cada vértice
    my %predecesores;    # Guarda el vértice anterior en la ruta óptima
    my %visitados;       # Marca los vértices ya procesados
    my @vertices_nombres = keys %{$self->vertices};
    
    # 1. Establecer distancia infinita (999999999) y sin predecesor para todos
    foreach my $v (@vertices_nombres) {
        $distancias{$v} = 999999999;
        $predecesores{$v} = undef;
        $visitados{$v} = 0;
    }
    
    # 2. La distancia al origen es 0
    $distancias{$origen_nombre} = 0;
    
    # ALGORITMO PRINCIPAL
    while (1) {
        # SELECCIÓN DEL VÉRTICE NO VISITADO CON MENOR DISTANCIA
        my $actual = undef;
        my $menor_distancia = 999999999;
        
        foreach my $v (@vertices_nombres) {
            if (!$visitados{$v} && $distancias{$v} < $menor_distancia) {
                $menor_distancia = $distancias{$v};
                $actual = $v;
            }
        }
        
        # Condiciones de parada:
        # - No hay más vértices alcanzables
        # - Llegamos al destino (optimización)
        last unless defined $actual;
        last if $actual eq $destino_nombre;
        
        # Marcar como visitado (procesado)
        $visitados{$actual} = 1;
        
        # RELAJACIÓN DE ARISTAS
        # Para cada vecino del vértice actual, actualizar su distancia si encontramos
        # un camino más corto a través de 'actual'
        my $adyacentes = $self->obtener_adyacentes($actual);
        foreach my $vecino (@$adyacentes) {
            my $vecino_nombre = $vecino->{vertice};
            my $distancia = $vecino->{distancia};
            
            if (!$visitados{$vecino_nombre}) {
                my $nueva_distancia = $distancias{$actual} + $distancia;
                # Si encontramos una distancia menor, actualizamos
                if ($nueva_distancia < $distancias{$vecino_nombre}) {
                    $distancias{$vecino_nombre} = $nueva_distancia;
                    $predecesores{$vecino_nombre} = $actual;
                }
            }
        }
    }
    
    # VERIFICACIÓN DE CAMINO ENCONTRADO
    if ($distancias{$destino_nombre} == 999999999) {
        return { 
            existe => 0, 
            mensaje => "No hay camino de $origen_nombre a $destino_nombre" 
        };
    }
    
    # RECONSTRUCCIÓN DEL CAMINO
    # Desde el destino, retrocedemos usando los predecesores hasta el origen
    my @camino = ();
    my $actual = $destino_nombre;
    while (defined $actual) {
        unshift @camino, $actual;  # Insertar al principio para obtener orden correcto
        $actual = $predecesores{$actual};
    }
    
    # RESULTADO FINAL
    return {
        existe => 1,
        origen => $origen_nombre,
        destino => $destino_nombre,
        distancia => $distancias{$destino_nombre},  # Distancia total más corta
        camino => \@camino                           # Secuencia de vértices
    };
}

sub obtener_todas_aristas {
    my ($self) = @_;
    my @aristas = ();
    
    foreach my $arista (@{$self->aristas}) {
        push @aristas, $arista->to_hash();
    }
    
    return \@aristas;
}

sub obtener_todos_vertices {
    my ($self) = @_;
    return [keys %{$self->vertices}];
}

sub obtener_estadisticas {
    my ($self) = @_;
    
    my $distancia_total = 0;
    foreach my $arista (@{$self->aristas}) {
        $distancia_total += $arista->distancia;
    }
    
    my $distancia_promedio = 0;
    if ($self->total_aristas > 0) {
        $distancia_promedio = $distancia_total / $self->total_aristas;
    }
    
    return {
        total_vertices => $self->total_vertices,
        total_rutas => $self->total_aristas,
        distancia_total => $distancia_total,
        distancia_promedio => $distancia_promedio,
        vertices => $self->obtener_todos_vertices()
    };
}

sub limpiar {
    my ($self) = @_;
    $self->vertices({});
    $self->aristas([]);
    $self->total_vertices(0);
    $self->total_aristas(0);
}

sub generar_dot {
    my ($self, $resaltar_camino, $conf) = @_;
    
    $conf //= { size => '8,6', fontsize => '10', nodesize => '0.5' };
    
    my $dot = "digraph G {\n";
    $dot .= "  rankdir=TB;\n";
    $dot .= "  size=\"$conf->{size}\";\n";
    $dot .= "  ratio=fill;\n";
    $dot .= "  node [shape=circle, style=filled, fillcolor=\"#4A90D9\", fontcolor=\"white\", fontname=\"Arial\", fontsize=$conf->{fontsize}, width=$conf->{nodesize}, height=$conf->{nodesize}];\n";
    $dot .= "  bgcolor=\"#1a1a2e\";\n";
    $dot .= "  edge [color=\"#6c63ff\", fontcolor=\"white\", fontname=\"Arial\", fontsize=$conf->{fontsize}];\n";
    $dot .= "  fontcolor=\"white\";\n\n";
    
    my %camino_hash = ();
    if ($resaltar_camino && ref($resaltar_camino) eq 'ARRAY') {
        for (my $i = 0; $i < scalar(@$resaltar_camino) - 1; $i++) {
            my $key = $resaltar_camino->[$i] . '|' . $resaltar_camino->[$i+1];
            $camino_hash{$key} = 1;
        }
    }
    
    foreach my $arista (@{$self->aristas}) {
        my $origen = $arista->origen->nombre;
        my $destino = $arista->destino->nombre;
        my $distancia = $arista->distancia;
        
        my $key = "$origen|$destino";
        if ($camino_hash{$key}) {
            $dot .= "  \"$origen\" -> \"$destino\" [label=\"$distancia km\", color=\"#00ff88\", penwidth=3, fontcolor=\"#00ff88\"];\n";
        } else {
            $dot .= "  \"$origen\" -> \"$destino\" [label=\"$distancia km\"];\n";
        }
    }
    
    $dot .= "}\n";
    return $dot;
}

1;


package ServicioRutas;
use Mojo::Base -base;

has 'grafo' => sub { Grafo->new() };
has 'ubicaciones' => sub { [] };

sub cargar_rutas_desde_archivo {
    my ($self, $archivo) = @_;
    
    open my $fh, '<', $archivo or return 0;
    my $contador = 0;
    
    while (my $linea = <$fh>) {
        chomp $linea;
        next if $linea =~ /^\s*$/;
        
        if ($linea =~ /^([^\/]+)\/([^\/]+)\/(.+)$/) {
            my ($origen, $destino, $distancia_str) = ($1, $2, $3);
            $distancia_str =~ s/\s+//g;
            
            if ($distancia_str =~ /^[\d\.]+$/) {
                my $distancia = $distancia_str + 0;
                $self->grafo->agregar_arista($origen, $destino, $distancia);
                $contador++;
            }
        }
    }
    
    close $fh;
    return $contador;
}

sub registrar_ruta {
    my ($self, $origen, $destino, $distancia) = @_;
    $self->grafo->agregar_arista($origen, $destino, $distancia);
}

sub registrar_ubicacion {
    my ($self, $departamento, $municipio) = @_;
    
    my $ubicacion = "$municipio, $departamento";
    my $timestamp = localtime();
    
    open my $fh, '>>', 'ubicaciones.log';
    print $fh "$timestamp - $ubicacion\n";
    close $fh;
    
    push @{$self->ubicaciones}, $ubicacion;
    
    open my $ubi_fh, '>>', 'ubicaciones_registradas.txt';
    print $ubi_fh "$ubicacion\n";
    close $ubi_fh;
    
    $self->grafo->agregar_vertice($ubicacion);
    
    return $ubicacion;
}

sub cargar_ubicaciones_persistentes {
    my ($self) = @_;
    
    if (-f 'ubicaciones_registradas.txt') {
        open my $fh, '<', 'ubicaciones_registradas.txt';
        while (my $linea = <$fh>) {
            chomp $linea;
            if ($linea =~ /\S/) {
                push @{$self->ubicaciones}, $linea;
                $self->grafo->agregar_vertice($linea);
            }
        }
        close $fh;
    }
}

sub obtener_ubicaciones {
    my ($self) = @_;
    return $self->ubicaciones;
}

sub obtener_ruta_mas_corta {
    my ($self, $origen, $destino) = @_;
    return $self->grafo->dijkstra($origen, $destino);
}

sub obtener_estadisticas {
    my ($self) = @_;
    return $self->grafo->obtener_estadisticas();
}

sub eliminar_todas_rutas {
    my ($self) = @_;
    $self->grafo->limpiar();
    
    foreach my $ubicacion (@{$self->ubicaciones}) {
        $self->grafo->agregar_vertice($ubicacion);
    }
}

1;


package main;

my $servicio = ServicioRutas->new();
$servicio->cargar_ubicaciones_persistentes();

# Configuración CORS
app->hook(before_dispatch => sub ($c) {
    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
    $c->res->headers->header('Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS');
    $c->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type, Authorization');
    
    if ($c->req->method eq 'OPTIONS') {
        $c->rendered(200);
        return;
    }
});

#  ENDPOINTS 

get '/' => sub ($c) {
    $c->render(json => {
        mensaje => "API de Rutas - Servidor funcionando correctamente (POO)",
        version => "2.0"
    });
};

post '/api/rutas/cargar' => sub ($c) {
    my $data = $c->req->json;
    my $archivo = $data->{archivo} // 'rutas.dat';
    
    my $total = $servicio->cargar_rutas_desde_archivo($archivo);
    
    $c->render(json => {
        success => 1,
        message => "Se cargaron $total rutas exitosamente desde $archivo",
        total_rutas => $total
    });
};

post '/api/rutas' => sub ($c) {
    my $data = $c->req->json;
    
    my $origen = $data->{origen};
    my $destino = $data->{destino};
    my $distancia = $data->{distancia};
    
    if (!$origen || !$destino || !$distancia) {
        $c->render(json => {
            success => 0,
            message => "Faltan parámetros: origen, destino, distancia"
        }, status => 400);
        return;
    }
    
    $servicio->registrar_ruta($origen, $destino, $distancia);
    
    $c->render(json => {
        success => 1,
        message => "Ruta agregada exitosamente",
        ruta => {
            origen => $origen,
            destino => $destino,
            distancia => $distancia
        }
    });
};

get '/api/rutas' => sub ($c) {
    my $vertices = $servicio->grafo->obtener_todos_vertices();
    my $rutas = $servicio->grafo->obtener_todas_aristas();
    
    $c->render(json => {
        success => 1,
        vertices => $vertices,
        rutas => $rutas,
        total_vertices => scalar(@$vertices),
        total_rutas => scalar(@$rutas)
    });
};

post '/api/rutas/camino-corto' => sub ($c) {
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
    
    my $resultado = $servicio->obtener_ruta_mas_corta($origen, $destino);
    
    if ($resultado->{existe}) {
        $c->render(json => {
            success => 1,
            ruta => $resultado,
            message => "Camino encontrado"
        });
    } else {
        $c->render(json => {
            success => 0,
            message => $resultado->{mensaje}
        });
    }
};

get '/api/estadisticas' => sub ($c) {
    my $estadisticas = $servicio->obtener_estadisticas();
    
    $c->render(json => {
        success => 1,
        estadisticas => $estadisticas
    });
};

post '/api/ubicacion' => sub ($c) {
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
    
    my $ubicacion = $servicio->registrar_ubicacion($departamento, $municipio);
    my $timestamp = localtime();
    
    $c->render(json => {
        success => 1,
        message => "Ubicación '$ubicacion' registrada exitosamente y agregada al grafo",
        ubicacion => $ubicacion,
        timestamp => $timestamp
    });
};

get '/api/ubicaciones' => sub ($c) {
    my $ubicaciones = $servicio->obtener_ubicaciones();
    
    $c->render(json => {
        success => 1,
        ubicaciones => $ubicaciones,
        total => scalar(@$ubicaciones)
    });
};

del '/api/rutas' => sub ($c) {
    $servicio->eliminar_todas_rutas();
    
    $c->render(json => {
        success => 1,
        message => "Todas las rutas han sido eliminadas"
    });
};

# Endpoint para generar grafo con tamaño personalizado
post '/api/grafo/generar' => sub ($c) {
    my $data = $c->req->json // {};
    my $nombre_archivo = $data->{nombre} // 'grafo_rutas';
    my $resaltar_camino = $data->{camino} // undef;
    my $tamaño = $data->{tamaño} // 'pequeno';
    
    my %tamaños = (
        'pequeno' => { size => '6,4', fontsize => '8', nodesize => '0.4' },
        'mediano' => { size => '10,7', fontsize => '10', nodesize => '0.5' },
        'grande' => { size => '14,10', fontsize => '12', nodesize => '0.6' }
    );
    
    my $conf = $tamaños{$tamaño} // $tamaños{'pequeno'};
    
    my $dot_content = $servicio->grafo->generar_dot($resaltar_camino, $conf);
    
    my $dot_file = "$nombre_archivo.dot";
    open my $fh, '>', $dot_file;
    print $fh $dot_content;
    close $fh;
    
    my $png_file = "$nombre_archivo.png";
    my $comando = "dot -Tpng \"$dot_file\" -o \"$png_file\" 2>/dev/null";
    system($comando);
    
    if (-f $png_file) {
        $c->render(json => {
            success => 1,
            message => "Grafo generado exitosamente",
            archivos => {
                dot => $dot_file,
                png => $png_file
            }
        });
    } else {
        $c->render(json => {
            success => 0,
            message => "Error al generar el grafo. Asegúrate de tener GraphViz instalado"
        }, status => 500);
    }
};

get '/api/grafo/listar' => sub ($c) {
    my @archivos_png = glob("*.png");
    my @archivos_dot = glob("*.dot");
    
    my %grafos_map = ();
    
    foreach my $archivo (@archivos_png) {
        if ($archivo =~ /^(.*)\.png$/) {
            my $nombre = $1;
            next if $nombre =~ /^temp_grafo/;
            $grafos_map{$nombre}->{png} = $archivo;
            $grafos_map{$nombre}->{nombre} = $nombre;
            $grafos_map{$nombre}->{tamaño} = -s $archivo;
            $grafos_map{$nombre}->{modificado} = localtime((stat $archivo)[9]);
        }
    }
    
    my @grafos = ();
    foreach my $nombre (keys %grafos_map) {
        push @grafos, {
            nombre => $grafos_map{$nombre}->{nombre},
            png => $grafos_map{$nombre}->{png} // ""
        };
    }
    
    $c->render(json => {
        success => 1,
        grafos => \@grafos,
        total => scalar(@grafos)
    });
};

get '/api/grafo/descargar/:nombre' => sub ($c) {
    my $nombre = $c->stash('nombre');
    my $formato = $c->req->param('formato') // 'png';
    
    my $archivo = "$nombre.$formato";
    
    if (-f $archivo) {
        my $content_type = $formato eq 'png' ? 'image/png' : 'text/plain';
        $c->res->headers->content_type($content_type);
        $c->res->headers->header('Content-Disposition', "attachment; filename=\"$archivo\"");
        
        open my $fh, '<', $archivo;
        binmode $fh;
        local $/;
        my $contenido = <$fh>;
        close $fh;
        
        $c->render(data => $contenido);
    } else {
        $c->render(json => {
            success => 0,
            message => "Archivo $archivo no encontrado"
        }, status => 404);
    }
};

del '/api/grafo/eliminar/:nombre' => sub ($c) {
    my $nombre = $c->stash('nombre');
    
    my $eliminados = 0;
    my $dot_file = "$nombre.dot";
    my $png_file = "$nombre.png";
    
    if (-f $dot_file) {
        unlink $dot_file;
        $eliminados++;
    }
    
    if (-f $png_file) {
        unlink $png_file;
        $eliminados++;
    }
    
    if ($eliminados > 0) {
        $c->render(json => {
            success => 1,
            message => "Se eliminaron $eliminados archivos del grafo '$nombre'"
        });
    } else {
        $c->render(json => {
            success => 0,
            message => "No se encontraron archivos del grafo '$nombre'"
        }, status => 404);
    }
};

get '/api/grafo/png' => sub ($c) {
    my $temp_nombre = "temp_grafo_" . time();
    my $conf = { size => '6,4', fontsize => '8', nodesize => '0.4' };
    my $dot_content = $servicio->grafo->generar_dot(undef, $conf);
    
    my $dot_file = "$temp_nombre.dot";
    my $png_file = "$temp_nombre.png";
    
    open my $fh, '>', $dot_file;
    print $fh $dot_content;
    close $fh;
    
    system("dot -Tpng \"$dot_file\" -o \"$png_file\" 2>/dev/null");
    
    if (-f $png_file) {
        $c->res->headers->content_type('image/png');
        open my $img_fh, '<', $png_file;
        binmode $img_fh;
        local $/;
        my $imagen_data = <$img_fh>;
        close $img_fh;
        
        unlink $dot_file if -f $dot_file;
        unlink $png_file if -f $png_file;
        
        $c->render(data => $imagen_data);
    } else {
        $c->render(json => {
            success => 0,
            message => "Error al generar el grafo"
        }, status => 500);
    }
};

# Iniciar servidor
my $port = $ENV{MOJO_PORT} // 3004;
say "=========================================";
say "  Servidor Corriendo";
say "=========================================";
say "  Puerto: $port";
say "  URL: http://localhost:$port";
say "=========================================";

app->start('daemon', '-l', "http://*:$port");