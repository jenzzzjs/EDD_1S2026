package ServicioRutas;
use strict;
use warnings;
use Mojo::Base -base;
use Grafo;
use File::Basename;

has 'grafo' => (is => 'rw', default => sub { Grafo->new() });
has 'ubicaciones' => (is => 'rw', default => sub { [] });

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
    
    # Guardar en archivo de log
    open my $fh, '>>', 'ubicaciones.log';
    print $fh "$timestamp - $ubicacion\n";
    close $fh;
    
    # Guardar en lista de ubicaciones registradas
    push @{$self->ubicaciones}, $ubicacion;
    
    # Guardar en archivo persistente
    open my $ubi_fh, '>>', 'ubicaciones_registradas.txt';
    print $ubi_fh "$ubicacion\n";
    close $ubi_fh;
    
    # Agregar al grafo
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
    
    # Recargar ubicaciones como vértices
    foreach my $ubicacion (@{$self->ubicaciones}) {
        $self->grafo->agregar_vertice($ubicacion);
    }
}

1;