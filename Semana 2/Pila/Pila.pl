
use strict;
use warnings;


eval {
    require GraphViz;
    GraphViz->import();
};


package NodoPila;

sub new {
    my ($class, $nombre, $autor, $anio) = @_;
    my $self = {
        nombre => $nombre,
        autor  => $autor,
        anio   => $anio,
        siguiente => undef
    };
    bless $self, $class;
    return $self;
}

sub obtener_datos {
    my $self = shift;
    return ($self->{nombre}, $self->{autor}, $self->{anio});
}

package PilaLibros;

sub new {
    my $class = shift;
    my $self = {
        tope   => undef,  # Apunta al elemento superior de la pila
        tamano => 0
    };
    bless $self, $class;
    return $self;
}

# Método para apilar 
sub apilar {
    my ($self, $nombre, $autor, $anio) = @_;
    my $nuevo_nodo = NodoPila->new($nombre, $autor, $anio);
    
    # El nuevo nodo apunta al actual tope
    $nuevo_nodo->{siguiente} = $self->{tope};
    
    # El nuevo nodo se convierte en el nuevo tope
    $self->{tope} = $nuevo_nodo;
    $self->{tamano}++;
    
    print "\n✓ Libro '$nombre' apilado correctamente.\n";
}

# metodo para desapilar 
sub desapilar {
    my $self = shift;
    
    if ($self->esta_vacia()) {
        print "\n✗ La pila está vacía. No hay libros para desapilar.\n";
        return undef;
    }
    
    # Guardar referencia al libro que se va a desapilar
    my $libro_desapilado = $self->{tope};
    
    # El nuevo tope es el siguiente elemento
    $self->{tope} = $self->{tope}->{siguiente};
    $self->{tamano}--;
    
    my ($nombre, $autor, $anio) = $libro_desapilado->obtener_datos();
    print "\n✓ Libro desapilado: '$nombre' de $autor ($anio)\n";
    
    return $libro_desapilado;
}

# metodo para verificar si la pila esta vacia
sub esta_vacia {
    my $self = shift;
    return !defined $self->{tope};
}

# metodo para obtener el tamaño de la pila
sub obtener_tamano {
    my $self = shift;
    return $self->{tamano};
}

# metodo para mostrar toda la pila
sub mostrar {
    my $self = shift;
    
    if ($self->esta_vacia()) {
        print "\n✗ La pila está vacía.\n";
        return;
    }
    
    print "\n" . "=" x 70 . "\n";
    print "PILA DE LIBROS (Total: " . $self->{tamano} . " libros)\n";
    print "=" x 70 . "\n";
    printf "%-5s %-25s %-25s %-10s\n", "No.", "TÍTULO", "AUTOR", "AÑO";
    print "-" x 70 . "\n";
    
    my $actual = $self->{tope};
    my $contador = 1;
    
    while ($actual) {
        my ($nombre, $autor, $anio) = $actual->obtener_datos();
        printf "%-5d %-25s %-25s %-10d\n", 
               $contador, $nombre, $autor, $anio;
        
        # Mostrar flecha hacia abajo si hay más elementos
        if ($actual->{siguiente}) {
            printf "%-5s %-25s %-25s %-10s\n", "", "↓", "", "";
        }
        
        $actual = $actual->{siguiente};
        $contador++;
    }
    
    print "=" x 70 . "\n";
    print "↑ Tope de la pila\n";
}

# metodo para generar grafico con Graphviz
sub graficar_graphviz {
    my $self = shift;
    
    if ($self->esta_vacia()) {
        print "\n✗ La pila está vacía. No hay nada que graficar.\n";
        return;
    }
    
    # Verificar si GraphViz está disponible
    unless (defined &GraphViz::new) {
        print "\n✗ Error: GraphViz no está instalado.\n";
        print "   Para instalar: sudo cpan install GraphViz\n";
        return;
    }
    
    # Crear objeto Graphviz
    my $graph = GraphViz->new(
        layout => 'dot',
        rankdir => 'TB',  # De arriba hacia abajo
        node => {
            shape => 'box',
            style => 'filled,rounded',
            fontname => 'Arial',
            fontsize => '10'
        },
        edge => {
            color => '#3366cc',
            fontname => 'Arial',
            fontsize => '9',
            arrowsize => '0.8'
        }
    );
    
    my $actual = $self->{tope};
    my $contador = 0;
    my $total_libros = $self->{tamano};
    
    # Recorrer la pila de arriba osea el tope hacia abajo
    while ($actual) {
        my ($nombre, $autor, $anio) = $actual->obtener_datos();
        
        # Determinar si es el tope o la base
        my $posicion = "";
        if ($contador == 0) {
            $posicion = "TOPE\\n\\n";
        } elsif ($contador == $total_libros - 1) {
            $posicion = "BASE\\n\\n";
        }
        
        # Crear etiqueta para el nodo
        my $etiqueta = "${posicion}Título: $nombre\\nAutor: $autor\\nAño: $anio";
        
        # Color diferente para tope y base
        my $color_fondo;
        if ($contador == 0) {
            $color_fondo = '#f80000';     # Rojo claro para el tope
        } elsif ($contador == $total_libros - 1) {
            $color_fondo = '#0dff092c';     # Verde claro para la base
        } else {
            $color_fondo = '#ffc505';     # Azul claro para los intermedios
        }
        
        # Añadir nodo al gráfico
        my $nodo_id = "nodo$contador";
        $graph->add_node($nodo_id, 
                        label => $etiqueta,
                        fillcolor => $color_fondo);
        
        # Conectar con el nodo siguiente el que está abajo en la pila
        if ($actual->{siguiente}) {
            my $nodo_siguiente = "nodo" . ($contador + 1);
            $graph->add_edge($nodo_id => $nodo_siguiente, 
                           label => "↓ siguiente ↓", 
                           color => '#3366cc');
        }
        
        $actual = $actual->{siguiente};
        $contador++;
    }
    
    # Crear carpeta Reportes si no existe
    my $carpeta_reportes = 'Reportes';
    unless (-d $carpeta_reportes) {
        mkdir $carpeta_reportes or warn "⚠ No se pudo crear la carpeta '$carpeta_reportes': $!";
        print "\n✓ Carpeta '$carpeta_reportes' creada.\n";
    }
    
    # Rutas de los archivos
    my $nombre_png = "PilaLibros.png";
    my $nombre_dot = "PilaLibros.dot";
    
    my $ruta_png = "$carpeta_reportes/$nombre_png";
    my $ruta_dot = "$carpeta_reportes/$nombre_dot";
    
    # Guardar archivos
    eval {
        $graph->as_png($ruta_png);
        $graph->as_text($ruta_dot);
        
        print "\n" . "=" x 60 . "\n";
        print "✓ GRÁFICO DE LA PILA GENERADO\n";
        print "=" x 60 . "\n";
        print "Archivos guardados en '$carpeta_reportes/':\n";
        print "  • $nombre_png\n";
        print "  • $nombre_dot\n";
        
        # Abrir automaticamente la imagen 
        abrir_imagen($ruta_png);
    };
    
    if ($@) {
        print "\n✗ Error al generar el gráfico: $@\n";
    }
}

sub abrir_imagen {
    my $archivo = shift;
    
    my $comando;
    if ($^O eq 'MSWin32') {
        $comando = "start \"\" \"$archivo\"";
    } elsif ($^O eq 'darwin') {
        $comando = "open \"$archivo\"";
    } else {
        $comando = "xdg-open \"$archivo\" 2>/dev/null";
    }
    
    print "Abriendo imagen en el visor predeterminado...\n";
    system($comando);
}

# Menú principal
package main;

sub mostrar_menu {
    print "\n" . "=" x 50 . "\n";
    print " SISTEMA DE PILA DE LIBROS\n";
    print "=" x 50 . "\n";
    print "1. Apilar nuevo libro (Push)\n";
    print "2. Desapilar libro (Pop)\n";
    print "3. Mostrar todos los libros\n";
    print "4. Ver tamaño de la pila\n";
    print "5. Graficar pila con Graphviz\n";
    print "6. Salir\n";
    print "=" x 50 . "\n";
    print "Seleccione una opción [1-6]: ";
}

sub main {
    # Crear pila vacia
    my $pila = PilaLibros->new();
    
    print "\n" . "*" x 50 . "\n";
    print "*" x 50 . "\n";
    
    # Verificar si GraphViz está instalado
    unless (defined &GraphViz::new) {
        print "\n⚠ ADVERTENCIA: GraphViz no está instalado.\n";
        print "El gráfico no se podrá generar (opción 5).\n";
        print "Para instalar: sudo cpan install GraphViz\n\n";
    }
    
    while (1) {
        mostrar_menu();
        my $opcion = <STDIN>;
        chomp $opcion;
        
        if ($opcion == 1) {
            print "\n--- APILAR NUEVO LIBRO ---\n";
            
            print "Título del libro: ";
            my $nombre = <STDIN>;
            chomp $nombre;
            $nombre =~ s/^\s+|\s+$//g;
            
            print "Autor: ";
            my $autor = <STDIN>;
            chomp $autor;
            $autor =~ s/^\s+|\s+$//g;
            
            print "Año de publicación: ";
            my $anio = <STDIN>;
            chomp $anio;
            
            if ($nombre && $autor && $anio) {
                $pila->apilar($nombre, $autor, $anio);
            } else {
                print "\n✗ Error: Todos los campos son obligatorios.\n";
            }
            
        } elsif ($opcion == 2) {
            print "\n--- DESAPILAR LIBRO ---\n";
            $pila->desapilar();
            
        } elsif ($opcion == 3) {
            $pila->mostrar();
            
        } elsif ($opcion == 4) {
            my $tamano = $pila->obtener_tamano();
            print "\n Tamaño actual de la pila: $tamano libros\n";
            
        } elsif ($opcion == 5) {
            print "\n--- GENERANDO GRÁFICO CON GRAPHVIZ ---\n";
            $pila->graficar_graphviz();
            
        } elsif ($opcion == 6) {
            print "\n" . "*" x 50 . "\n";
            print "¡Hasta luego!\n";
            print "*" x 50 . "\n\n";
            last;
            
        } else {
            print "\n✗ Opción no válida. Intente de nuevo.\n";
        }
    }
}

# 
main();