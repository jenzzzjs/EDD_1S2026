package Grafos::Visualizador;
use strict;
use warnings;
use File::Slurp qw(write_file);
use File::Temp qw(tempfile);

sub new {
    my ($class) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

# Generar código DOT para GraphViz
sub generar_dot {
    my ($self, $grafo, $camino_resaltado) = @_;
    
    my $dot = "digraph GrafoRutas {\n";
    $dot .= "  rankdir=TB;\n";
    $dot .= "  node [shape=circle, style=filled, fillcolor=\"#4A90D9\", fontcolor=\"white\", fontname=\"Arial\"];\n";
    $dot .= "  bgcolor=\"#1a1a2e\";\n";
    $dot .= "  edge [color=\"#6c63ff\", fontcolor=\"white\", fontname=\"Arial\"];\n";
    $dot .= "  label=\"Grafo Dirigido de Rutas\";\n";
    $dot .= "  fontcolor=\"white\";\n\n";
    
    # Obtener todas las aristas
    my $aristas = $grafo->obtener_aristas();
    
    # Si hay un camino para resaltar, crear un hash para acceso rápido
    my %camino_hash = ();
    if ($camino_resaltado && ref($camino_resaltado) eq 'ARRAY') {
        for (my $i = 0; $i < scalar(@$camino_resaltado) - 1; $i++) {
            my $key = $camino_resaltado->[$i] . '|' . $camino_resaltado->[$i+1];
            $camino_hash{$key} = 1;
        }
    }
    
    # Agregar aristas al DOT
    foreach my $arista (@$aristas) {
        my $origen = $arista->{origen};
        my $destino = $arista->{destino};
        my $distancia = $arista->{distancia};
        
        my $key = "$origen|$destino";
        if ($camino_hash{$key}) {
            # Resaltar el camino más corto
            $dot .= "  \"$origen\" -> \"$destino\" [label=\"$distancia km\", color=\"#00ff88\", penwidth=3, fontcolor=\"#00ff88\"];\n";
        } else {
            $dot .= "  \"$origen\" -> \"$destino\" [label=\"$distancia km\"];\n";
        }
    }
    
    $dot .= "}\n";
    return $dot;
}

# Generar imagen PNG del grafo
sub generar_imagen {
    my ($self, $grafo, $camino_resaltado) = @_;
    
    my $dot_content = $self->generar_dot($grafo, $camino_resaltado);
    
    # Crear archivo temporal para el DOT
    my ($dot_fh, $dot_filename) = tempfile('grafo_XXXXXX', SUFFIX => '.dot', UNLINK => 0);
    print $dot_fh $dot_content;
    close $dot_fh;
    
    # Crear archivo temporal para la imagen
    my ($png_fh, $png_filename) = tempfile('grafo_XXXXXX', SUFFIX => '.png', UNLINK => 0);
    close $png_fh;
    
    # Ejecutar GraphViz para generar PNG
    my $comando = "dot -Tpng \"$dot_filename\" -o \"$png_filename\" 2>/dev/null";
    system($comando);
    
    # Leer la imagen generada
    my $imagen_data = undef;
    if (-f $png_filename) {
        open my $fh, '<', $png_filename;
        binmode $fh;
        local $/;
        $imagen_data = <$fh>;
        close $fh;
    }
    
    # Limpiar archivos temporales
    unlink $dot_filename if -f $dot_filename;
    unlink $png_filename if -f $png_filename;
    
    return $imagen_data;
}

# Generar imagen y devolver como base64 (para enviar en JSON)
sub generar_imagen_base64 {
    my ($self, $grafo, $camino_resaltado) = @_;
    
    my $imagen_data = $self->generar_imagen($grafo, $camino_resaltado);
    return undef unless $imagen_data;
    
    use MIME::Base64;
    my $base64 = encode_base64($imagen_data);
    $base64 =~ s/\s+//g;
    
    return $base64;
}

1;