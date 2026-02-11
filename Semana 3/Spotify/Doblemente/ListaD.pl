package ListaDoblementeEnlazada;
use strict;
use warnings;
use Cwd qw(abs_path);
use File::Basename;

# Nodo de la lista doblemente enlazada CON COLA PROPIA
package NodoArtista;
sub new {
    my ($class, $nombre) = @_;
    my $self = {
        nombre => $nombre,
        cola_canciones => undef,  # Cada artista tiene su propia cola
        siguiente => undef,
        anterior => undef
    };
    bless $self, $class;
    return $self;
}

# Lista Doblemente Enlazada
package ListaDoblementeEnlazada;

# Variable para controlar si ya cargamos ColaCanciones
my $cola_cargada = 0;

sub new {
    my $class = shift;
    my $self = {
        cabeza => undef,
        cola => undef,
        tamanio => 0
    };
    bless $self, $class;
    
    # Asegurar que ColaCanciones esté cargado
    _cargar_cola();
    
    return $self;
}

# Función privada para cargar ColaCanciones
sub _cargar_cola {
    return if $cola_cargada;
    
    # Intentar diferentes rutas
    my @rutas_posibles = (
        'Cola/Cola.pl',
        '../Cola/Cola.pl',
        abs_path(dirname(__FILE__) . '/../Cola/Cola.pl')
    );
    
    foreach my $ruta (@rutas_posibles) {
        if (-e $ruta) {
            require $ruta;
            $cola_cargada = 1;
            last;
        }
    }
    
    unless ($cola_cargada) {
        die "No se pudo encontrar Cola/Cola.pl. Rutas probadas: " . join(', ', @rutas_posibles);
    }
}

# Método para insertar un artista
sub insertar {
    my ($self, $nombre) = @_;
    
    my $nuevo_nodo = NodoArtista->new($nombre);
    
    if (!$self->{cabeza}) {
        # Lista vacía
        $self->{cabeza} = $nuevo_nodo;
        $self->{cola} = $nuevo_nodo;
    } else {
        # Insertar al final
        $nuevo_nodo->{anterior} = $self->{cola};
        $self->{cola}{siguiente} = $nuevo_nodo;
        $self->{cola} = $nuevo_nodo;
    }
    
    $self->{tamanio}++;
    return 1;
}

# Método para buscar un artista
sub buscar {
    my ($self, $nombre) = @_;
    
    my $actual = $self->{cabeza};
    while ($actual) {
        if ($actual->{nombre} eq $nombre) {
            return $actual;
        }
        $actual = $actual->{siguiente};
    }
    
    return undef;
}

# Método para verificar si existe un artista
sub existe {
    my ($self, $nombre) = @_;
    return defined $self->buscar($nombre);
}

# Método para obtener todos los artistas
sub obtener_artistas {
    my $self = shift;
    
    my @artistas;
    my $actual = $self->{cabeza};
    
    while ($actual) {
        push @artistas, $actual;
        $actual = $actual->{siguiente};
    }
    
    return @artistas;
}

# Método para agregar canción a un artista específico
sub agregar_cancion_a_artista {
    my ($self, $nombre_artista, $nombre_cancion, $anio) = @_;
    
    my $artista = $self->buscar($nombre_artista);
    return 0 unless $artista;
    
    # Asegurar que ColaCanciones esté cargado
    _cargar_cola();
    
    # Si el artista no tiene cola, creamos una
    if (!$artista->{cola_canciones}) {
        $artista->{cola_canciones} = ColaCanciones->new();
    }
    
    # Agregar la canción a la cola del artista
    return $artista->{cola_canciones}->encolar($nombre_cancion, $anio);
}

# Método para obtener las canciones de un artista
sub obtener_canciones_de_artista {
    my ($self, $nombre_artista) = @_;
    
    my $artista = $self->buscar($nombre_artista);
    return () unless $artista && $artista->{cola_canciones};
    
    return $artista->{cola_canciones}->obtener_todas_canciones();
}

# Método para generar el DOT completo con colas
sub generar_dot_completo {
    my $self = shift;
    
    my $dot = "digraph SistemaMusicaCompleto {\n";
    $dot .= "    rankdir=TB;\n";
    $dot .= "    compound=true;\n";
    $dot .= "    node [fontname=\"Arial\"];\n\n";
    
    my @artistas = $self->obtener_artistas();
    my $contador_a = 0;
    
    # Para cada artista
    foreach my $artista (@artistas) {
        # Nodo del artista
        $dot .= "    subgraph cluster_artista$contador_a {\n";
        $dot .= "        label = \"" . $artista->{nombre} . "\";\n";
        $dot .= "        style=filled;\n";
        $dot .= "        color=lightgrey;\n";
        
        # Nodo del artista en el centro
        $dot .= "        artista$contador_a [label=\"" . $artista->{nombre} . "\", shape=ellipse, style=filled, color=white];\n";
        
        # Si el artista tiene canciones
        if ($artista->{cola_canciones}) {
            my @canciones = $artista->{cola_canciones}->obtener_todas_canciones();
            my $contador_c = 0;
            
            $dot .= "        {\n";
            $dot .= "            rank=same;\n";
            
            # Crear nodos de canciones para este artista
            foreach my $cancion (@canciones) {
                $dot .= "            cancion_${contador_a}_${contador_c} [label=\"" . $cancion->{nombre} . "\\n(" . $cancion->{anio} . ")\", shape=box];\n";
                $contador_c++;
            }
            $dot .= "        }\n";
            
            # Conectar artista a su primera canción
            if ($contador_c > 0) {
                $dot .= "        artista$contador_a -> cancion_${contador_a}_0;\n";
            }
            
            # Conectar canciones entre sí (cola)
            for (my $i = 0; $i < $contador_c; $i++) {
                if ($i < $contador_c - 1) {
                    $dot .= "        cancion_${contador_a}_${i} -> cancion_${contador_a}_" . ($i + 1) . ";\n";
                }
            }
            
            # Agregar etiquetas de Frente y Final
            if ($contador_c > 0) {
                $dot .= "        frente${contador_a} [label=\"Frente\", shape=plaintext];\n";
                $dot .= "        final${contador_a} [label=\"Final\", shape=plaintext];\n";
                $dot .= "        frente${contador_a} -> cancion_${contador_a}_0 [style=dotted];\n";
                $dot .= "        cancion_${contador_a}_" . ($contador_c - 1) . " -> final${contador_a} [style=dotted];\n";
            }
        } else {
            $dot .= "        sin_canciones$contador_a [label=\"Sin canciones\", shape=plaintext];\n";
            $dot .= "        artista$contador_a -> sin_canciones$contador_a [style=dotted];\n";
        }
        
        $dot .= "    }\n\n";
        $contador_a++;
    }
    
    # Conectar artistas entre sí (lista doblemente enlazada)
    for (my $i = 0; $i < $contador_a; $i++) {
        if ($i < $contador_a - 1) {
            $dot .= "    artista$i -> artista" . ($i + 1) . " [constraint=false, style=bold, color=blue, label=\"next\"];\n";
            $dot .= "    artista" . ($i + 1) . " -> artista$i [constraint=false, style=bold, color=red, label=\"prev\"];\n";
        }
    }
    
    $dot .= "}\n";
    return $dot;
}

# Método para obtener el tamaño
sub tamanio {
    my $self = shift;
    return $self->{tamanio};
}

# Método para contar canciones totales
sub contar_canciones_totales {
    my $self = shift;
    
    my $total = 0;
    my $actual = $self->{cabeza};
    
    while ($actual) {
        if ($actual->{cola_canciones}) {
            $total += $actual->{cola_canciones}->tamanio();
        }
        $actual = $actual->{siguiente};
    }
    
    return $total;
}

1;