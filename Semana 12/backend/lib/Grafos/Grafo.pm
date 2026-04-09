package Grafos::Grafo;
use strict;
use warnings;
use Mojo::JSON qw(encode_json decode_json);

sub new {
    my ($class) = @_;
    my $self = {
        # Lista de adyacencia: { vertice => [ { destino => distancia } ] }
        adyacencia => {},
        # Conjunto de vértices para rápido acceso
        vertices => {},
        # Lista de aristas para fácil serialización
        aristas => []
    };
    bless $self, $class;
    return $self;
}

# Agregar un vértice al grafo
sub agregar_vertice {
    my ($self, $vertice) = @_;
    
    if (!$self->{adyacencia}{$vertice}) {
        $self->{adyacencia}{$vertice} = [];
        $self->{vertices}{$vertice} = 1;
    }
}

# Agregar una ruta dirigida
sub agregar_ruta {
    my ($self, $origen, $destino, $distancia) = @_;
    
    # Agregar vértices si no existen
    $self->agregar_vertice($origen);
    $self->agregar_vertice($destino);
    
    # Buscar si ya existe la ruta
    my $existe = 0;
    foreach my $ruta (@{$self->{adyacencia}{$origen}}) {
        if ($ruta->{destino} eq $destino) {
            $ruta->{distancia} = $distancia;
            $existe = 1;
            last;
        }
    }
    
    # Si no existe, agregar nueva ruta
    if (!$existe) {
        push @{$self->{adyacencia}{$origen}}, {
            destino => $destino,
            distancia => $distancia
        };
        push @{$self->{aristas}}, {
            origen => $origen,
            destino => $destino,
            distancia => $distancia
        };
    } else {
        # Actualizar arista en la lista
        for my $arista (@{$self->{aristas}}) {
            if ($arista->{origen} eq $origen && $arista->{destino} eq $destino) {
                $arista->{distancia} = $distancia;
                last;
            }
        }
    }
    
    return 1;
}

# Obtener todos los vértices
sub obtener_vertices {
    my ($self) = @_;
    return [sort keys %{$self->{vertices}}];
}

# Obtener todas las aristas
sub obtener_aristas {
    my ($self) = @_;
    return $self->{aristas};
}

# Obtener adyacentes de un vértice
sub obtener_adyacentes {
    my ($self, $vertice) = @_;
    return $self->{adyacencia}{$vertice} // [];
}

# Obtener distancia entre dos vértices
sub obtener_distancia {
    my ($self, $origen, $destino) = @_;
    
    my $adyacentes = $self->{adyacencia}{$origen};
    return undef unless $adyacentes;
    
    foreach my $ruta (@$adyacentes) {
        return $ruta->{distancia} if $ruta->{destino} eq $destino;
    }
    
    return undef;
}

# Verificar si existe un vértice
sub existe_vertice {
    my ($self, $vertice) = @_;
    return exists $self->{vertices}{$vertice};
}

# Verificar si existe una arista
sub existe_arista {
    my ($self, $origen, $destino) = @_;
    
    my $adyacentes = $self->{adyacencia}{$origen};
    return 0 unless $adyacentes;
    
    foreach my $ruta (@$adyacentes) {
        return 1 if $ruta->{destino} eq $destino;
    }
    
    return 0;
}

# Cargar rutas desde archivo
sub cargar_desde_archivo {
    my ($self, $archivo) = @_;
    
    open my $fh, '<', $archivo or return 0;
    my $contador = 0;
    
    while (my $linea = <$fh>) {
        chomp $linea;
        next if $linea =~ /^\s*$/;
        
        # Formato: origen/destino/distancia
        if ($linea =~ /^([^\/]+)\/([^\/]+)\/(.+)$/) {
            my ($origen, $destino, $distancia) = ($1, $2, $3);
            $distancia =~ s/\s+//g;
            
            if ($distancia =~ /^[\d\.]+$/) {
                $self->agregar_ruta($origen, $destino, $distancia);
                $contador++;
            }
        }
    }
    
    close $fh;
    return $contador;
}

# Exportar a formato JSON
sub to_json {
    my ($self) = @_;
    return encode_json({
        vertices => $self->obtener_vertices(),
        aristas => $self->obtener_aristas()
    });
}

# Limpiar todos los datos del grafo
sub limpiar {
    my ($self) = @_;
    $self->{adyacencia} = {};
    $self->{vertices} = {};
    $self->{aristas} = [];
    return 1;
}

1;