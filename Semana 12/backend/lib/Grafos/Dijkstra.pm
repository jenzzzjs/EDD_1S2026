package Grafos::Dijkstra;
use strict;
use warnings;

sub new {
    my ($class) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

# Implementación del algoritmo de Dijkstra
sub encontrar_camino_mas_corto {
    my ($self, $grafo, $origen, $destino) = @_;
    
    # Verificar que origen y destino existan
    return { existe => 0, mensaje => "El origen '$origen' no existe en el grafo" }
        unless $grafo->existe_vertice($origen);
    
    return { existe => 0, mensaje => "El destino '$destino' no existe en el grafo" }
        unless $grafo->existe_vertice($destino);
    
    # Inicializar estructuras de datos
    my %distancias = ();
    my %predecesores = ();
    my %visitados = ();
    my @vertices = @{$grafo->obtener_vertices()};
    
    # Inicializar distancias
    foreach my $vertice (@vertices) {
        $distancias{$vertice} = inf();
        $predecesores{$vertice} = undef;
        $visitados{$vertice} = 0;
    }
    
    $distancias{$origen} = 0;
    
    # Algoritmo principal
    while (1) {
        # Encontrar vértice no visitado con menor distancia
        my $actual = undef;
        my $menor_distancia = inf();
        
        foreach my $vertice (@vertices) {
            if (!$visitados{$vertice} && $distancias{$vertice} < $menor_distancia) {
                $menor_distancia = $distancias{$vertice};
                $actual = $vertice;
            }
        }
        
        last unless defined $actual;
        last if $actual eq $destino;
        
        $visitados{$actual} = 1;
        
        # Actualizar distancias a los adyacentes
        my $adyacentes = $grafo->obtener_adyacentes($actual);
        foreach my $ruta (@$adyacentes) {
            my $vecino = $ruta->{destino};
            my $distancia = $ruta->{distancia};
            
            if (!$visitados{$vecino}) {
                my $nueva_distancia = $distancias{$actual} + $distancia;
                if ($nueva_distancia < $distancias{$vecino}) {
                    $distancias{$vecino} = $nueva_distancia;
                    $predecesores{$vecino} = $actual;
                }
            }
        }
    }
    
    # Construir el camino
    my @camino = ();
    my $actual = $destino;
    
    if ($distancias{$destino} == inf()) {
        return { existe => 0, mensaje => "No existe un camino de $origen a $destino" };
    }
    
    # Reconstruir camino desde destino hasta origen
    while (defined $actual) {
        unshift @camino, $actual;
        $actual = $predecesores{$actual};
    }
    
    return {
        existe => 1,
        origen => $origen,
        destino => $destino,
        distancia => $distancias{$destino},
        camino => \@camino,
        mensaje => "Camino encontrado exitosamente"
    };
}

# Función auxiliar para infinito
sub inf {
    return 999999999;
}

1;