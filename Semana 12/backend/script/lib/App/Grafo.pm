package Grafo;
use strict;
use warnings;
use Mojo::Base -base;
use Vertice;
use Arista;

has 'vertices' => (is => 'rw', default => sub { {} });
has 'aristas' => (is => 'rw', default => sub { [] });
has 'total_vertices' => (is => 'rw', default => 0);
has 'total_aristas' => (is => 'rw', default => 0);

sub agregar_vertice {
    my ($self, $nombre) = @_;
    
    return 0 if exists $self->vertices->{$nombre};
    
    my $vertice = Vertice->new(nombre => $nombre);
    $self->vertices->{$nombre} = $vertice;
    $self->total_vertices++;
    
    return 1;
}

sub obtener_vertice {
    my ($self, $nombre) = @_;
    return $self->vertices->{$nombre};
}

sub existe_vertice {
    my ($self, $nombre) = @_;
    return exists $self->vertices->{$nombre};
}

sub agregar_arista {
    my ($self, $origen_nombre, $destino_nombre, $distancia) = @_;
    
    # Agregar vértices si no existen
    $self->agregar_vertice($origen_nombre);
    $self->agregar_vertice($destino_nombre);
    
    my $origen = $self->obtener_vertice($origen_nombre);
    my $destino = $self->obtener_vertice($destino_nombre);
    
    # Verificar si la arista ya existe
    my $arista_existente = $self->buscar_arista($origen_nombre, $destino_nombre);
    
    if ($arista_existente) {
        # Actualizar distancia
        $arista_existente->distancia($distancia);
        return $arista_existente;
    }
    
    # Crear nueva arista
    my $arista = Arista->new(
        origen => $origen,
        destino => $destino,
        distancia => $distancia
    );
    
    push @{$self->aristas}, $arista;
    $origen->agregar_adyacente($arista);
    $self->total_aristas++;
    
    return $arista;
}

sub buscar_arista {
    my ($self, $origen_nombre, $destino_nombre) = @_;
    
    foreach my $arista (@{$self->aristas}) {
        if ($arista->equals($origen_nombre, $destino_nombre)) {
            return $arista;
        }
    }
    
    return undef;
}

sub obtener_adyacentes {
    my ($self, $vertice_nombre) = @_;
    
    my $vertice = $self->obtener_vertice($vertice_nombre);
    return [] unless $vertice;
    
    my @adyacentes = ();
    foreach my $arista ($vertice->obtener_adyacentes()) {
        push @adyacentes, {
            vertice => $arista->destino->nombre,
            distancia => $arista->distancia
        };
    }
    
    return \@adyacentes;
}

sub dijkstra {
    my ($self, $origen_nombre, $destino_nombre) = @_;
    
    # Verificar que los vértices existen
    return { existe => 0, mensaje => "Origen '$origen_nombre' no existe" }
        unless $self->existe_vertice($origen_nombre);
    
    return { existe => 0, mensaje => "Destino '$destino_nombre' no existe" }
        unless $self->existe_vertice($destino_nombre);
    
    # Inicializar estructuras
    my %distancias;
    my %predecesores;
    my %visitados;
    my @vertices_nombres = keys %{$self->vertices};
    
    foreach my $v (@vertices_nombres) {
        $distancias{$v} = 999999999;
        $predecesores{$v} = undef;
        $visitados{$v} = 0;
    }
    
    $distancias{$origen_nombre} = 0;
    
    # Algoritmo de Dijkstra
    while (1) {
        my $actual = undef;
        my $menor_distancia = 999999999;
        
        foreach my $v (@vertices_nombres) {
            if (!$visitados{$v} && $distancias{$v} < $menor_distancia) {
                $menor_distancia = $distancias{$v};
                $actual = $v;
            }
        }
        
        last unless defined $actual;
        last if $actual eq $destino_nombre;
        
        $visitados{$actual} = 1;
        
        # Explorar vecinos
        my $adyacentes = $self->obtener_adyacentes($actual);
        foreach my $vecino (@$adyacentes) {
            my $vecino_nombre = $vecino->{vertice};
            my $distancia = $vecino->{distancia};
            
            if (!$visitados{$vecino_nombre}) {
                my $nueva_distancia = $distancias{$actual} + $distancia;
                if ($nueva_distancia < $distancias{$vecino_nombre}) {
                    $distancias{$vecino_nombre} = $nueva_distancia;
                    $predecesores{$vecino_nombre} = $actual;
                }
            }
        }
    }
    
    # Verificar si se encontró camino
    if ($distancias{$destino_nombre} == 999999999) {
        return { 
            existe => 0, 
            mensaje => "No hay camino de $origen_nombre a $destino_nombre" 
        };
    }
    
    # Reconstruir camino
    my @camino = ();
    my $actual = $destino_nombre;
    while (defined $actual) {
        unshift @camino, $actual;
        $actual = $predecesores{$actual};
    }
    
    return {
        existe => 1,
        origen => $origen_nombre,
        destino => $destino_nombre,
        distancia => $distancias{$destino_nombre},
        camino => \@camino
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
    my ($self, $resaltar_camino) = @_;
    
    my $dot = "digraph G {\n";
    $dot .= "  rankdir=TB;\n";
    $dot .= "  node [shape=circle, style=filled, fillcolor=\"#4A90D9\", fontcolor=\"white\", fontname=\"Arial\"];\n";
    $dot .= "  bgcolor=\"#1a1a2e\";\n";
    $dot .= "  edge [color=\"#6c63ff\", fontcolor=\"white\", fontname=\"Arial\"];\n";
    $dot .= "  label=\"Grafo Dirigido de Rutas\";\n";
    $dot .= "  fontcolor=\"white\";\n\n";
    
    # Crear hash para caminos resaltados
    my %camino_hash = ();
    if ($resaltar_camino && ref($resaltar_camino) eq 'ARRAY') {
        for (my $i = 0; $i < scalar(@$resaltar_camino) - 1; $i++) {
            my $key = $resaltar_camino->[$i] . '|' . $resaltar_camino->[$i+1];
            $camino_hash{$key} = 1;
        }
    }
    
    # Agregar aristas
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