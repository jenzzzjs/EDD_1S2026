#!/usr/bin/perl
use strict;
use warnings;



{
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
}

{
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
    
    sub encolar {
        my ($self, $nombre, $anio) = @_;
        
        my $nueva_cancion = NodoCancion->new($nombre, $anio);
        
        if (!$self->{frente}) {
            $self->{frente} = $nueva_cancion;
            $self->{final} = $nueva_cancion;
        } else {
            $self->{final}{siguiente} = $nueva_cancion;
            $self->{final} = $nueva_cancion;
        }
        
        $self->{tamanio}++;
        return 1;
    }
    
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
    
    sub tamanio {
        my $self = shift;
        return $self->{tamanio};
    }
}

{
    package NodoArtista;
    sub new {
        my ($class, $nombre) = @_;
        my $self = {
            nombre => $nombre,
            cola_canciones => ColaCanciones->new(),  # Cada artista tiene su cola
            siguiente => undef,
            anterior => undef
        };
        bless $self, $class;
        return $self;
    }
    
    sub agregar_cancion {
        my ($self, $nombre, $anio) = @_;
        return $self->{cola_canciones}->encolar($nombre, $anio);
    }
    
    sub obtener_canciones {
        my $self = shift;
        return $self->{cola_canciones}->obtener_todas_canciones();
    }
    
    sub cantidad_canciones {
        my $self = shift;
        return $self->{cola_canciones}->tamanio();
    }
}

{
    package ListaDoblementeEnlazada;
    sub new {
        my $class = shift;
        my $self = {
            cabeza => undef,
            cola => undef,
            tamanio => 0
        };
        bless $self, $class;
        return $self;
    }
    
    sub insertar {
        my ($self, $nombre) = @_;
        
        my $nuevo_nodo = NodoArtista->new($nombre);
        
        if (!$self->{cabeza}) {
            $self->{cabeza} = $nuevo_nodo;
            $self->{cola} = $nuevo_nodo;
        } else {
            $nuevo_nodo->{anterior} = $self->{cola};
            $self->{cola}{siguiente} = $nuevo_nodo;
            $self->{cola} = $nuevo_nodo;
        }
        
        $self->{tamanio}++;
        return 1;
    }
    
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
    
    sub existe {
        my ($self, $nombre) = @_;
        return defined $self->buscar($nombre);
    }
    
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
    
    sub agregar_cancion_a_artista {
        my ($self, $nombre_artista, $nombre_cancion, $anio) = @_;
        
        my $artista = $self->buscar($nombre_artista);
        return 0 unless $artista;
        
        return $artista->agregar_cancion($nombre_cancion, $anio);
    }
    
    sub obtener_canciones_de_artista {
        my ($self, $nombre_artista) = @_;
        
        my $artista = $self->buscar($nombre_artista);
        return () unless $artista;
        
        return $artista->obtener_canciones();
    }
    
    sub tamanio {
        my $self = shift;
        return $self->{tamanio};
    }
    
    sub contar_canciones_totales {
        my $self = shift;
        
        my $total = 0;
        my $actual = $self->{cabeza};
        
        while ($actual) {
            $total += $actual->cantidad_canciones();
            $actual = $actual->{siguiente};
        }
        
        return $total;
    }
    
 sub generar_dot_completo {
    my $self = shift;
    
    my $dot = "digraph SistemaMusica {\n";
    $dot .= "    rankdir=TB;\n";
    $dot .= "    node [fontname=\"Helvetica\", fontsize=12];\n";
    $dot .= "    edge [fontname=\"Helvetica\", fontsize=10];\n";
    $dot .= "    compound=true;\n";
    $dot .= "    bgcolor=\"white\";\n";
    $dot .= "    ranksep=0.5;\n";
    $dot .= "    nodesep=0.4;\n\n";
    
    
    $dot .= "    // ESTILOS GLOBALES\n";
    $dot .= "    graph [splines=ortho];\n";
    $dot .= "    edge [arrowsize=0.8, color=black, fontcolor=black];\n\n";
    
    $dot .= "    {\n";
    $dot .= "        rank=same;\n";
    
    my @artistas = $self->obtener_artistas();
    my $contador_a = 0;
    
    foreach my $artista (@artistas) {
        $dot .= "        artista$contador_a [label=\"" . $artista->{nombre} . 
                "\", shape=box, style=\"filled,rounded\", fillcolor=\"black\", " .
                "color=\"black\", penwidth=2, width=1.8, height=0.8, " .
                "fontname=\"Helvetica-Bold\", fontcolor=\"white\"];\n";
        $contador_a++;
    }
    $dot .= "    }\n\n";
    

    $dot .= "    // CONEXIONES ENTRE ARTISTAS\n";
    for (my $i = 0; $i < $contador_a; $i++) {
        if ($i < $contador_a - 1) {
            $dot .= "    artista$i -> artista" . ($i + 1) . 
                    " [color=black, label=\"siguiente\", dir=forward, " .
                    "penwidth=1.5, arrowhead=vee];\n";
            $dot .= "    artista" . ($i + 1) . " -> artista$i " .
                    "[color=black, label=\"anterior\", constraint=false, " .
                    "penwidth=1.5, arrowhead=vee];\n";
        }
    }
    
    $dot .= "\n";
    
    $contador_a = 0;
    foreach my $artista (@artistas) {
        $dot .= "    // CANCIONES DE: " . $artista->{nombre} . "\n";
        my @canciones = $artista->obtener_canciones();
        my $contador_c = 0;
        
        if (@canciones) {
        
            $dot .= "    subgraph cluster_artista$contador_a {\n";
            $dot .= "        label=\"\";\n";
            $dot .= "        style=invis;\n";
            $dot .= "        ranksep=0.3;\n";
            
         
            foreach my $cancion (@canciones) {
            
                my $r = 30;
                my $g = 60;
                my $b = 160;
                
                my $color_fill = sprintf("#%02x%02x%02x", $r, $g, $b);
                my $color_border = "black";
                
                $dot .= "        cancion${contador_a}_${contador_c} [label=\"" . 
                        $cancion->{nombre} . "\\n(" . $cancion->{anio} . ")\", " .
                        "shape=box, style=\"filled\", fillcolor=\"$color_fill\", " .
                        "color=\"$color_border\", penwidth=1.5, width=1.4, height=0.9, " .
                        "fontcolor=\"white\", fontname=\"Helvetica\"];\n";
                $contador_c++;
            }
            
            $dot .= "    }\n";
            
           # conectamos las canciones entre si
            for (my $i = 0; $i < $contador_c; $i++) {
                if ($i < $contador_c - 1) {
                    $dot .= "    cancion${contador_a}_${i} -> cancion${contador_a}_" . ($i + 1) . 
                            " [color=black, dir=forward, penwidth=1.5, " .
                            "arrowhead=vee];\n";
                }
            }
            
            # conectamos artista con la primera cancion
            $dot .= "    artista$contador_a -> cancion${contador_a}_0 " .
                    "[color=black, dir=forward, minlen=2.5, penwidth=2, " .
                    "arrowhead=vee];\n";
            
           
            if ($contador_c > 0) {
                $dot .= "    { rank=same; cancion${contador_a}_0 }\n";
            }
        } else {
            $dot .= "    sin_canciones$contador_a [label=\"SIN CANCIONES\", " .
                    "shape=plaintext, fontcolor=\"gray\", fontsize=9, " .
                    "fontname=\"Helvetica-Italic\"];\n";
            $dot .= "    artista$contador_a -> sin_canciones$contador_a " .
                    "[style=dotted, color=\"gray\", minlen=2.5, penwidth=1];\n";
        }
        
        $dot .= "\n";
        $contador_a++;
    }
    

    $dot .= "    // TITULO\n";
    $dot .= "    titulo_invisible [label=\"\", shape=plaintext, width=0, height=0];\n";
    
    $dot .= "}\n";
    return $dot;
}
}

my $lista_artistas = ListaDoblementeEnlazada->new();


sub limpiar_pantalla {
    system('clear') == 0 || system('cls') == 0 || print "\n" x 50;
}


sub mostrar_menu {
    print "\n" . "=" x 50 . "\n";
    print "    SISTEMA DE GESTIÓN DE MÚSICA\n";
    print "=" x 50 . "\n";
    print "1. Ingresar un artista\n";
    print "2. Ingresar una canción\n";
    print "3. Generar reporte gráfico\n";
    print "4. Mostrar datos actuales\n";
    print "5. Salir\n";
    print "=" x 50 . "\n";
    print "Seleccione una opción: ";
}


sub ingresar_artista {
    limpiar_pantalla();
    print "\n" . "-" x 50 . "\n";
    print "   INGRESAR NUEVO ARTISTA\n";
    print "-" x 50 . "\n";
    
    print "Nombre del artista: ";
    my $nombre = <STDIN>;
    chomp($nombre);
    
    if ($nombre eq "") {
        print "\n✗ Error: El nombre no puede estar vacío.\n";
        print "Presione Enter para continuar...";
        <STDIN>;
        return;
    }
    
    if ($lista_artistas->existe($nombre)) {
        print "\n✗ Error: El artista '$nombre' ya existe en el sistema.\n";
    } else {
        $lista_artistas->insertar($nombre);
        print "\n✓ Artista '$nombre' agregado exitosamente!\n";
    }
    
    print "Presione Enter para continuar...";
    <STDIN>;
}


sub ingresar_cancion {
    limpiar_pantalla();
    print "\n" . "-" x 50 . "\n";
    print "   INGRESAR NUEVA CANCIÓN\n";
    print "-" x 50 . "\n";
    
    print "Nombre del artista: ";
    my $artista = <STDIN>;
    chomp($artista);
    
    if (!$lista_artistas->existe($artista)) {
        print "\n✗ Error: El artista '$artista' no existe en el sistema.\n";
        print "Primero debe agregar el artista en la opción 1.\n";
        print "Presione Enter para continuar...";
        <STDIN>;
        return;
    }
    
    print "Nombre de la canción: ";
    my $cancion = <STDIN>;
    chomp($cancion);
    
    if ($cancion eq "") {
        print "\n✗ Error: El nombre de la canción no puede estar vacío.\n";
        print "Presione Enter para continuar...";
        <STDIN>;
        return;
    }
    
    print "Año de lanzamiento: ";
    my $anio = <STDIN>;
    chomp($anio);
    
    if ($anio !~ /^\d{4}$/ || $anio < 1800 || $anio > 2050) {
        print "\n✗ Error: Año inválido. Debe ser un número de 4 dígitos entre 1900 y 2024.\n";
        print "Presione Enter para continuar...";
        <STDIN>;
        return;
    }
    
  
    if ($lista_artistas->agregar_cancion_a_artista($artista, $cancion, $anio)) {
        print "\n✓ Canción '$cancion' agregada exitosamente al artista '$artista'!\n";
    } else {
        print "\n✗ Error: No se pudo agregar la canción.\n";
    }
    
    print "Presione Enter para continuar...";
    <STDIN>;
}


sub generar_reporte {
    limpiar_pantalla();
    print "\n" . "-" x 50 . "\n";
    print "   GENERAR REPORTE GRÁFICO\n";
    print "-" x 50 . "\n";
    
   
    if ($lista_artistas->tamanio() == 0) {
        print "\n✗ Error: No hay datos para generar el reporte.\n";
        print "Agregue artistas primero.\n";
        print "Presione Enter para continuar...";
        <STDIN>;
        return;
    }
    

    my $dot_file = "reporte_musica.dot";
    my $png_file = "reporte_musica.png";
    
    open(my $fh, '>', $dot_file) or die "No se pudo crear el archivo DOT: $!";
    
   
    my $dot_content = $lista_artistas->generar_dot_completo();
    print $fh $dot_content;
    
    close($fh);
    
    print "\n✓ Archivo DOT generado: $dot_file\n";
    print "\nContenido del sistema:\n";
    print "-" x 30 . "\n";
    
    my @artistas = $lista_artistas->obtener_artistas();
    foreach my $artista (@artistas) {
        print "• " . $artista->{nombre} . " (" . $artista->cantidad_canciones() . " canciones)\n";
    }
    
    print "\n¿Desea generar la imagen PNG con Graphviz? (s/n): ";
    my $respuesta = <STDIN>;
    chomp($respuesta);
    
    if ($respuesta =~ /^s/i) {
        
        my $graphviz_check = `which dot 2>/dev/null`;
        
        if (!$graphviz_check) {
    
           
            print "  dot -Tpng $dot_file -o $png_file\n";
        } else {
            print "\nGenerando imagen PNG...\n";
            system("dot -Tpng $dot_file -o $png_file");
            
            if (-e $png_file) {
                print "\n✓ Imagen generada exitosamente: $png_file\n";
                
               
               
                print "  ├─ Artistas registrados: " . $lista_artistas->tamanio() . "\n";
                print "  └─ Canciones totales: " . $lista_artistas->contar_canciones_totales() . "\n";
                
               
                print "  ├─ $dot_file (código DOT para Graphviz)\n";
                print "  └─ $png_file (imagen del diagrama)\n";
                
               
            } else {
                print "\n✗ Error al generar la imagen.\n";
                print "Intente ejecutar manualmente:\n";
                print "  dot -Tpng $dot_file -o $png_file\n";
            }
        }
    } else {
        print "\nℹ️  Puede generar la imagen manualmente con:\n";
        print "  dot -Tpng $dot_file -o $png_file\n";
    }
    
    print "\nPresione Enter para continuar...";
    <STDIN>;
}


sub mostrar_datos {
    limpiar_pantalla();
    print "\n" . "-" x 50 . "\n";
    print "   DATOS ACTUALES DEL SISTEMA\n";
    print "-" x 50 . "\n";
    
    print "\n🎤 ARTISTAS REGISTRADOS (" . $lista_artistas->tamanio() . "):\n";
    print "-" x 40 . "\n";
    
    my @artistas = $lista_artistas->obtener_artistas();
    if (@artistas) {
        foreach my $artista (@artistas) {
            print "┌─ " . $artista->{nombre} . "\n";
            
            
            my @canciones = $artista->obtener_canciones();
            if (@canciones) {
                print "│  🎵 Canciones (" . scalar(@canciones) . "):\n";
                foreach my $cancion (@canciones) {
                    print "│    • " . $cancion->{nombre} . " (" . $cancion->{anio} . ")\n";
                }
            } else {
                print "│   Sin canciones\n";
            }
            print "└\n";
        }
    } else {
        print "   No hay artistas registrados.\n";
    }
    
    print "\n RESUMEN:\n";
    print "-" x 30 . "\n";
    print "  Artistas: " . $lista_artistas->tamanio() . "\n";
    print "  Canciones: " . $lista_artistas->contar_canciones_totales() . "\n";
    
    print "\nPresione Enter para continuar...";
    <STDIN>;
}




sub main {
    my $opcion;
    
    while (1) {
        limpiar_pantalla();
        mostrar_menu();
        
        $opcion = <STDIN>;
        chomp($opcion);
        
        if ($opcion == 1) {
            ingresar_artista();
        }
        elsif ($opcion == 2) {
            ingresar_cancion();
        }
        elsif ($opcion == 3) {
            generar_reporte();
        }
        elsif ($opcion == 4) {
            mostrar_datos();
        }
        elsif ($opcion == 5) {
            mostrar_creditos();
            last;
        }
        else {
            print "\n✗ Opción inválida. Por favor, seleccione 1-5.\n";
            print "Presione Enter para continuar...";
            <STDIN>;
        }
    }
}


main();