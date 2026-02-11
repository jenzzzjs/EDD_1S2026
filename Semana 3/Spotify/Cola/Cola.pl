package ColaCanciones;
use strict;
use warnings;

# Nodo de la cola
package NodoCancion;
sub new {
    my ($class, $nombre, $anio) = @_;
    my $self = {
        nombre => $nombre,
        anio => $anio,
        siguiente => undef
    };
    bless $self, $class;
    return $self;
}

# Cola de canciones
package ColaCanciones;
sub new {
    my $class = shift;
    my $self = {
        frente => undef,
        final => undef,
        tamanio => 0
    };
    bless $self, $class;
    return $self;
}

# Método para encolar una canción
sub encolar {
    my ($self, $nombre, $anio) = @_;
    
    my $nueva_cancion = NodoCancion->new($nombre, $anio);
    
    if (!$self->{frente}) {
        # Cola vacía
        $self->{frente} = $nueva_cancion;
        $self->{final} = $nueva_cancion;
    } else {
        # Agregar al final
        $self->{final}{siguiente} = $nueva_cancion;
        $self->{final} = $nueva_cancion;
    }
    
    $self->{tamanio}++;
    return 1;
}

# Método para obtener todas las canciones
sub obtener_todas_canciones {
    my $self = shift;
    
    my @canciones;
    my $actual = $self->{frente};
    
    while ($actual) {
        push @canciones, {
            nombre => $actual->{nombre},
            anio => $actual->{anio}
        };
        $actual = $actual->{siguiente};
    }
    
    return @canciones;
}

# Método para obtener el tamaño
sub tamanio {
    my $self = shift;
    return $self->{tamanio};
}

1;