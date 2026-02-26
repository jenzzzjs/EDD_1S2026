
use strict;
use warnings;
use GraphViz;
use File::Path qw(make_path);
use File::Spec;

# clase nodo para la lista enlazada
package Nodo;

sub new {
    my ($class, $dpi, $nombre, $edad) = @_;
    my $self = {
        dpi    => $dpi,
        nombre => $nombre,
        edad   => $edad,
        siguiente => undef
    };
    bless $self, $class;
    return $self;
}

sub obtener_datos {
    my $self = shift;
    return ($self->{dpi}, $self->{nombre}, $self->{edad});
}

package ListaEnlazada;

sub new {
    my $class = shift;
    my $self = {
        cabeza => undef,
        tamano => 0
    };
    bless $self, $class;
    return $self;
}

# metodo para insertar al final
sub insertar {
    my ($self, $dpi, $nombre, $edad) = @_;
    my $nuevo_nodo = Nodo->new($dpi, $nombre, $edad);
    
    if (!$self->{cabeza}) {
        $self->{cabeza} = $nuevo_nodo;
    } else {
        my $actual = $self->{cabeza};
        while ($actual->{siguiente}) {
            $actual = $actual->{siguiente};
        }
        $actual->{siguiente} = $nuevo_nodo;
    }
    $self->{tamano}++;
    print "\n✓ Persona insertada correctamente.\n";
}

# metodo para eliminar a alguien por su dpi
sub eliminar {
    my ($self, $dpi) = @_;
    
    if (!$self->{cabeza}) {
        print "\n  La lista está vacía.\n";
        return;
    }
    
    # condicion por si eliminamos la cabeza
    if ($self->{cabeza}->{dpi} eq $dpi) {
        my $eliminado = $self->{cabeza};
        $self->{cabeza} = $self->{cabeza}->{siguiente};
        $self->{tamano}--;
        print "\n✓ Persona con DPI '$dpi' eliminada correctamente.\n";
        return 1;
    }
    
    # sino buscamos el nodo a eliminar
    my $actual = $self->{cabeza};
    while ($actual->{siguiente} && $actual->{siguiente}->{dpi} ne $dpi) {
        $actual = $actual->{siguiente};
    }
    
    # condicion por si se encuentra el nodo
    if ($actual->{siguiente}) {
        $actual->{siguiente} = $actual->{siguiente}->{siguiente};
        $self->{tamano}--;
        print "\n✓ Persona con DPI '$dpi' eliminada correctamente.\n";
        return 1;
    } else {
        print "\n  No se encontró una persona con DPI '$dpi'.\n";
        return 0;
    }
}

# metodo para busacar por el dpi
sub buscar {
    my ($self, $dpi) = @_;
    
    my $actual = $self->{cabeza};
    my $posicion = 1;
    
    while ($actual) {
        if ($actual->{dpi} eq $dpi) {
            my ($dpi_nodo, $nombre, $edad) = $actual->obtener_datos();
            print "\n✓ Persona encontrada:\n";
            print "   Posición: $posicion\n";
            print "   DPI: $dpi_nodo\n";
            print "   Nombre: $nombre\n";
            print "   Edad: $edad\n";
            return $posicion;
        }
        $actual = $actual->{siguiente};
        $posicion++;
    }
    
    print "\n  No se encontró una persona con DPI '$dpi'.\n";
    return 0;
}

# metodo para mostrar a todas las personas registradas
sub mostrar {
    my $self = shift;
    
    if (!$self->{cabeza}) {
        print "\n  La lista está vacía.\n";
        return;
    }
    
    print "\n" . "=" x 60 . "\n";
    print "LISTA DE PERSONAS REGISTRADAS\n";
    print "=" x 60 . "\n";
    printf "%-5s %-20s %-25s %-10s\n", "No.", "DPI", "NOMBRE", "EDAD";
    print "-" x 60 . "\n";
    
    my $actual = $self->{cabeza};
    my $contador = 1;
    
    while ($actual) {
        my ($dpi, $nombre, $edad) = $actual->obtener_datos();
        printf "%-5d %-20s %-25s %-10d\n", 
               $contador, $dpi, $nombre, $edad;
        $actual = $actual->{siguiente};
        $contador++;
    }
    print "=" x 60 . "\n";
    print "Total de personas: " . $self->{tamano} . "\n";
}

# metodo para graficar todo
sub graficar {
    my $self = shift;
    
    if ($self->{tamano} == 0) {
        print "\n  No se puede graficar: la lista está vacía.\n";
        return;
    }
    
    # crea un bojeto de graphviz
    my $graph = GraphViz->new(
        layout => 'dot',
        rankdir => 'LR',  #
        node => {
            shape => 'box',
            style => 'filled,rounded',
            fillcolor => '#e6f2ff',
            fontname => 'Arial',
            fontsize => '10'
        },
        edge => {
            color => '#0066cc',
            fontname => 'Arial',
            fontsize => '9',
            fontcolor => '#0066cc'
        }
    );
    
    my $actual = $self->{cabeza};
    my $contador = 0;
    
    while ($actual) {
        my ($dpi, $nombre, $edad) = $actual->obtener_datos();
        
        # etiquetas para incluir los datos que querramos mostrar
        my $etiqueta = "DPI: $dpi\\nNombre: $nombre\\nEdad: $edad";
        
        # añade el nodo al grafico
        $graph->add_node("nodo$contador", label => $etiqueta);
        
        # conecta con el siguiente nodo si existe
        if ($actual->{siguiente}) {
            $graph->add_edge("nodo$contador" => "nodo" . ($contador + 1), label => "siguiente");
        }
        
        $actual = $actual->{siguiente};
        $contador++;
    }
    
    # nodo al final el cual es null
    $graph->add_node("null", 
                     label => "NULL", 
                     shape => "box",
                     style => "filled",
                     fillcolor => "#f0f0f0",
                     fontcolor => "#666666");
    
    if ($contador > 0) {
        $graph->add_edge("nodo" . ($contador - 1) => "null", label => "siguiente");
    }
    
    # la definicion de la carpeta reportes
    my $carpeta_reportes = 'Reportes';
    
    # creamos la carpeta si es que no existe
    unless (-d $carpeta_reportes) {
        make_path($carpeta_reportes) or die "No se pudo crear la carpeta '$carpeta_reportes': $!";
        print "\n✓ Carpeta '$carpeta_reportes' creada.\n";
    }
    
    # generamos los nombres con el localtime para evitar sobreescribir sobre el mismo archivo
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
    $year += 1900;
    $mon += 1;
    my $timestamp = sprintf("%04d%02d%02d_%02d%02d%02d", $year, $mon, $mday, $hour, $min, $sec);
    
    # rutas de los archivos con su nombre
    my $nombre_png = "lista_enlazada_$timestamp.png";
    my $nombre_dot = "lista_enlazada_$timestamp.dot";
    
    my $ruta_png = File::Spec->catfile($carpeta_reportes, $nombre_png);
    my $ruta_dot = File::Spec->catfile($carpeta_reportes, $nombre_dot);
    
    # Guardar archivos
    $graph->as_png($ruta_png);
    $graph->as_text($ruta_dot);
    
    print "\n" . "=" x 60 . "\n";
    print "✓ GRÁFICO GENERADO EXITOSAMENTE\n";
    print "=" x 60 . "\n";
    print "Archivos guardados en la carpeta '$carpeta_reportes':\n";
    print "  • $nombre_png (imagen PNG)\n";
    print "  • $nombre_dot (código fuente DOT)\n";
    print "\nRuta completa: " . File::Spec->rel2abs($carpeta_reportes) . "\n";
    
    #
    abrir_imagen($ruta_png);
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
    
    print "\nAbriendo imagen en el visor predeterminado...\n";
    system($comando);
}

# menu principal
package main;

sub mostrar_menu {
    print "\n" . "=" x 50 . "\n";
    print "SISTEMA DE LISTAS ENLAZADAS\n";
    print "=" x 50 . "\n";
    print "1. Insertar nueva persona\n";
    print "2. Mostrar lista completa\n";
    print "3. Buscar persona por DPI\n";
    print "4. Eliminar persona por DPI\n";
    print "5. Graficar lista enlazada\n";
    print "6. Salir\n";
    print "=" x 50 . "\n";
    print "Seleccione una opción [1-6]: ";
}

sub main {
    # creamos la lista vacia
    my $lista = ListaEnlazada->new();
    
    print "\n" . "*" x 50 . "\n";
    print "BIENVENIDO AL SISTEMA DE LISTAS ENLAZADAS\n";
    print "*" x 50 . "\n";
    

    eval {
        require GraphViz;
        GraphViz->import();
    };
    
    if ($@) {
        print "\n⚠ ADVERTENCIA: GraphViz no está instalado.\n";
        print "El gráfico no se podrá generar.\n";
        print "Para instalar: sudo cpan install GraphViz\n\n";
    }
    
    while (1) {
        mostrar_menu();
        my $opcion = <STDIN>;
        chomp $opcion;
        
        if ($opcion == 1) {
            print "\n--- INSERTAR NUEVA PERSONA ---\n";
            
            print "DPI: ";
            my $dpi = <STDIN>;
            chomp $dpi;
            
            print "Nombre: ";
            my $nombre = <STDIN>;
            chomp $nombre;
            
            print "Edad: ";
            my $edad = <STDIN>;
            chomp $edad;
            
            if ($dpi && $nombre && $edad) {
                $lista->insertar($dpi, $nombre, $edad);
            } else {
                print "\n  Error: Todos los campos son obligatorios.\n";
            }
            
        } elsif ($opcion == 2) {
            $lista->mostrar();
            
        } elsif ($opcion == 3) {
            print "\n--- BUSCAR PERSONA ---\n";
            print "Ingrese DPI a buscar: ";
            my $dpi = <STDIN>;
            chomp $dpi;
            $lista->buscar($dpi);
            
        } elsif ($opcion == 4) {
            print "\n--- ELIMINAR PERSONA ---\n";
            print "Ingrese DPI a eliminar: ";
            my $dpi = <STDIN>;
            chomp $dpi;
            $lista->eliminar($dpi);
            
        } elsif ($opcion == 5) {
            print "\n--- GENERANDO GRÁFICO ---\n";
            $lista->graficar();
            
        } elsif ($opcion == 6) {
            print "\n" . "*" x 50 . "\n";
            print "Reportes Generados/\n";
            print "*" x 50 . "\n\n";
            last;
            
        } else {
            print "\n  Opción no válida. Intente de nuevo.\n";
        }
    }
}


main();