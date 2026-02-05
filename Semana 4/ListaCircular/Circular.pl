#!/usr/bin/perl
use strict;
use warnings;

# Cargar módulos necesarios
eval {
    require GraphViz;
    GraphViz->import();
};

# Clase Nodo para la lista circular
package NodoCircular;

sub new {
    my ($class, $nombre, $edad) = @_;
    my $self = {
        nombre => $nombre,
        edad   => $edad,
        siguiente => undef
    };
    bless $self, $class;
    return $self;
}

sub obtener_datos {
    my $self = shift;
    return ($self->{nombre}, $self->{edad});
}

package ListaCircular;

sub new {
    my $class = shift;
    my $self = {
        cabeza => undef,
        tamano => 0
    };
    bless $self, $class;
    return $self;
}

# Método para insertar al final de la lista circular
sub insertar {
    my ($self, $nombre, $edad) = @_;
    my $nuevo_nodo = NodoCircular->new($nombre, $edad);
    
    if (!$self->{cabeza}) {
        # Primer nodo - se apunta a sí mismo
        $nuevo_nodo->{siguiente} = $nuevo_nodo;
        $self->{cabeza} = $nuevo_nodo;
    } else {
        # Insertar después del último nodo
        my $ultimo = $self->{cabeza};
        while ($ultimo->{siguiente} != $self->{cabeza}) {
            $ultimo = $ultimo->{siguiente};
        }
        $ultimo->{siguiente} = $nuevo_nodo;
        $nuevo_nodo->{siguiente} = $self->{cabeza};
    }
    $self->{tamano}++;
    print "\n✓ Amigo '$nombre' se ha sentado en la mesa.\n";
}

# Método para eliminar por nombre
sub eliminar {
    my ($self, $nombre) = @_;
    
    if (!$self->{cabeza}) {
        print "\n✗ La mesa está vacía.\n";
        return;
    }
    
    my $actual = $self->{cabeza};
    my $anterior = undef;
    
    # Buscar el nodo a eliminar
    do {
        if ($actual->{nombre} eq $nombre) {
            # Encontrado el nodo
            if ($self->{tamano} == 1) {
                # Único nodo en la lista
                $self->{cabeza} = undef;
            } elsif ($actual == $self->{cabeza}) {
                # Es la cabeza - encontrar el último nodo
                my $ultimo = $self->{cabeza};
                while ($ultimo->{siguiente} != $self->{cabeza}) {
                    $ultimo = $ultimo->{siguiente};
                }
                $self->{cabeza} = $actual->{siguiente};
                $ultimo->{siguiente} = $self->{cabeza};
            } else {
                # Nodo intermedio
                $anterior->{siguiente} = $actual->{siguiente};
            }
            
            $self->{tamano}--;
            print "\n✓ '$nombre' se ha levantado de la mesa.\n";
            return 1;
        }
        $anterior = $actual;
        $actual = $actual->{siguiente};
    } while ($actual != $self->{cabeza});
    
    print "\n✗ No hay nadie llamado '$nombre' en la mesa.\n";
    return 0;
}

# Método para buscar por nombre
sub buscar {
    my ($self, $nombre) = @_;
    
    if (!$self->{cabeza}) {
        print "\n✗ La mesa está vacía.\n";
        return;
    }
    
    my $actual = $self->{cabeza};
    my $posicion = 1;
    
    do {
        if ($actual->{nombre} eq $nombre) {
            my ($nombre_nodo, $edad) = $actual->obtener_datos();
            print "\n✓ Encontrado en la posición $posicion:\n";
            print "   Nombre: $nombre_nodo\n";
            print "   Edad: $edad años\n";
            return $posicion;
        }
        $actual = $actual->{siguiente};
        $posicion++;
    } while ($actual != $self->{cabeza});
    
    print "\n✗ No hay nadie llamado '$nombre' en la mesa.\n";
    return 0;
}

# Método para mostrar la mesa completa
sub mostrar {
    my $self = shift;
    
    if (!$self->{cabeza}) {
        print "\n✗ La mesa está vacía.\n";
        return;
    }
    
    print "\n" . "=" x 60 . "\n";
    print "MESA DE AMIGOS (Total: " . $self->{tamano} . " personas)\n";
    print "=" x 60 . "\n";
    printf "%-5s %-30s %-10s\n", "No.", "NOMBRE", "EDAD";
    print "-" x 60 . "\n";
    
    my $actual = $self->{cabeza};
    my $contador = 1;
    
    do {
        my ($nombre, $edad) = $actual->obtener_datos();
        printf "%-5d %-30s %-10d\n", $contador, $nombre, $edad;
        $actual = $actual->{siguiente};
        $contador++;
    } while ($actual != $self->{cabeza});
    
    print "=" x 60 . "\n";
}

# Método para generar gráfico con Graphviz
sub graficar {
    my $self = shift;
    
    if ($self->{tamano} == 0) {
        print "\n✗ No se puede graficar: la mesa está vacía.\n";
        return;
    }
    
    # Verificar si GraphViz está disponible
    unless (defined &GraphViz::new) {
        print "\n✗ Error: GraphViz no está instalado o no se pudo cargar.\n";
        print "   Para instalar: sudo cpan install GraphViz\n";
        return;
    }
    
    # Crear objeto Graphviz
    my $graph = GraphViz->new(
        layout => 'circo',  # Layout circular para lista circular
        node => {
            shape => 'circle',
            style => 'filled',
            fillcolor => '#ffebcc',
            fontname => 'Arial',
            fontsize => '10'
        },
        edge => {
            color => '#ff6600',
            fontname => 'Arial',
            fontsize => '9'
        }
    );
    
    my $actual = $self->{cabeza};
    my $contador = 0;
    my %nodos;  # Para guardar referencia a los nodos
    
    # Crear todos los nodos
    do {
        my ($nombre, $edad) = $actual->obtener_datos();
        my $etiqueta = "$nombre\\n$edad años";
        
        $graph->add_node("nodo$contador", label => $etiqueta);
        
        $nodos{$actual} = "nodo$contador";
        $actual = $actual->{siguiente};
        $contador++;
    } while ($actual != $self->{cabeza});
    
    # Crear las conexiones circulares
    $actual = $self->{cabeza};
    do {
        my $nodo_actual = $nodos{$actual};
        my $nodo_siguiente = $nodos{$actual->{siguiente}};
        
        $graph->add_edge($nodo_actual => $nodo_siguiente);
        $actual = $actual->{siguiente};
    } while ($actual != $self->{cabeza});
    
    # Crear carpeta Reportes si no existe
    my $carpeta_reportes = 'Reportes';
    unless (-d $carpeta_reportes) {
        mkdir $carpeta_reportes or warn "⚠ No se pudo crear la carpeta '$carpeta_reportes': $!";
        print "\n✓ Carpeta '$carpeta_reportes' creada.\n";
    }
    
    # Nombres fijos para los archivos
    my $nombre_png = "ListaCircular.png";
    my $nombre_dot = "ListaCircular.dot";
    
    my $ruta_png = "$carpeta_reportes/$nombre_png";
    my $ruta_dot = "$carpeta_reportes/$nombre_dot";
    
    # Guardar archivos
    eval {
        $graph->as_png($ruta_png);
        $graph->as_text($ruta_dot);
        
        print "\n" . "=" x 60 . "\n";
        print "✓ GRÁFICO DE LA MESA GENERADO\n";
        print "=" x 60 . "\n";
        print "Archivos guardados en '$carpeta_reportes/':\n";
        print "  • $nombre_png\n";
        print "  • $nombre_dot\n";
        
        # Abrir automáticamente la imagen
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
    print "MESA DE AMIGOS - LISTA CIRCULAR\n";
    print "=" x 50 . "\n";
    print "1. Agregar amigo a la mesa\n";
    print "2. Mostrar todos en la mesa\n";
    print "3. Buscar amigo por nombre\n";
    print "4. Eliminar amigo por nombre\n";
    print "5. Graficar lista circular\n";
    print "6. Salir\n";
    print "=" x 50 . "\n";
    print "Seleccione una opción [1-6]: ";
}

sub main {
    # Crear mesa vacía
    my $mesa = ListaCircular->new();
    
    print "\n" . "*" x 50 . "\n";
    print "SISTEMA DE LISTA CIRCULAR\n";
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
            print "\n--- AGREGAR AMIGO A LA MESA ---\n";
            
            print "Nombre: ";
            my $nombre = <STDIN>;
            chomp $nombre;
            $nombre =~ s/^\s+|\s+$//g;
            
            print "Edad: ";
            my $edad = <STDIN>;
            chomp $edad;
            
            if ($nombre && $edad) {
                $mesa->insertar($nombre, $edad);
            } else {
                print "\n✗ Error: Todos los campos son obligatorios.\n";
            }
            
        } elsif ($opcion == 2) {
            $mesa->mostrar();
            
        } elsif ($opcion == 3) {
            print "\n--- BUSCAR AMIGO ---\n";
            print "Ingrese nombre a buscar: ";
            my $nombre = <STDIN>;
            chomp $nombre;
            $mesa->buscar($nombre);
            
        } elsif ($opcion == 4) {
            print "\n--- ELIMINAR AMIGO ---\n";
            print "Ingrese nombre a eliminar: ";
            my $nombre = <STDIN>;
            chomp $nombre;
            $mesa->eliminar($nombre);
            
        } elsif ($opcion == 5) {
            print "\n--- GENERANDO GRÁFICO ---\n";
            $mesa->graficar();
            
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


main();