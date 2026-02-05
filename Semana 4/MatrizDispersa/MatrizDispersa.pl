#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';

# Clase Nodo para la matriz dispersa
package Node {
    sub new {
        my ($class, $row, $col, $medicamento, $precio) = @_;
        my $self = {
            row => $row,
            col => $col,
            medicamento => $medicamento,
            precio => $precio,
            up => undef,
            down => undef,
            left => undef,
            right => undef
        };
        bless $self, $class;
        return $self;
    }

    sub get_row { $_[0]->{row} }
    sub get_col { $_[0]->{col} }
    sub get_medicamento { $_[0]->{medicamento} }
    sub get_precio { $_[0]->{precio} }
    
    sub set_up { $_[0]->{up} = $_[1] }
    sub set_down { $_[0]->{down} = $_[1] }
    sub set_left { $_[0]->{left} = $_[1] }
    sub set_right { $_[0]->{right} = $_[1] }
    
    sub get_up { $_[0]->{up} }
    sub get_down { $_[0]->{down} }
    sub get_left { $_[0]->{left} }
    sub get_right { $_[0]->{right} }
}

# Clase Matriz Dispersa
package MatrizDispersaMedicamentos {
    sub new {
        my ($class) = @_;
        my $self = {
            head => Node->new("HEAD", "HEAD", "", 0),
            proveedores => {},  # Hash para búsqueda rápida de proveedores
            medicamentos => {}   # Hash para búsqueda rápida de medicamentos
        };
        bless $self, $class;
        return $self;
    }

    # Método para reemplazar espacios por guiones bajos (para Graphviz)
    sub reemplazar_espacios {
        my ($self, $texto) = @_;
        $texto =~ s/ /_/g;
        return $texto;
    }

    # Buscar encabezado de proveedor (fila)
    sub buscar_proveedor_head {
        my ($self, $proveedor) = @_;
        my $temp = $self->{head};
        
        while ($temp) {
            return $temp if ($temp->get_row() eq $proveedor);
            $temp = $temp->get_down();
        }
        return undef;
    }

    # Buscar encabezado de medicamento (columna)
    sub buscar_medicamento_head {
        my ($self, $medicamento) = @_;
        my $temp = $self->{head};
        
        while ($temp) {
            return $temp if ($temp->get_col() eq $medicamento);
            $temp = $temp->get_right();
        }
        return undef;
    }

    # Crear encabezado de proveedor
    sub crear_proveedor_head {
        my ($self, $proveedor) = @_;
        
        # Verificar si ya existe
        my $existe = $self->buscar_proveedor_head($proveedor);
        return $existe if $existe;
        
        # Crear nuevo nodo encabezado
        my $nuevo_nodo = Node->new($proveedor, "", "", 0);
        $self->{proveedores}->{$proveedor} = 1;
        
        my $temp = $self->{head};
        
        # Encontrar posición correcta (orden alfabético)
        while ($temp->get_down() && $temp->get_down()->get_row() lt $proveedor) {
            $temp = $temp->get_down();
        }
        
        # Insertar en la posición correcta
        $nuevo_nodo->set_down($temp->get_down());
        $temp->set_down($nuevo_nodo);
        $nuevo_nodo->set_up($temp);
        
        if ($nuevo_nodo->get_down()) {
            $nuevo_nodo->get_down()->set_up($nuevo_nodo);
        }
        
        return $nuevo_nodo;
    }

    # Crear encabezado de medicamento
    sub crear_medicamento_head {
        my ($self, $medicamento) = @_;
        
        # Verificar si ya existe
        my $existe = $self->buscar_medicamento_head($medicamento);
        return $existe if $existe;
        
        # Crear nuevo nodo encabezado
        my $nuevo_nodo = Node->new("", $medicamento, "", 0);
        $self->{medicamentos}->{$medicamento} = 1;
        
        my $temp = $self->{head};
        
        # Encontrar posición correcta (orden alfabético)
        while ($temp->get_right() && $temp->get_right()->get_col() lt $medicamento) {
            $temp = $temp->get_right();
        }
        
        # Insertar en la posición correcta
        $nuevo_nodo->set_right($temp->get_right());
        $temp->set_right($nuevo_nodo);
        $nuevo_nodo->set_left($temp);
        
        if ($nuevo_nodo->get_right()) {
            $nuevo_nodo->get_right()->set_left($nuevo_nodo);
        }
        
        return $nuevo_nodo;
    }

    # Insertar medicamento en la matriz
    sub insertar_medicamento {
        my ($self, $proveedor, $codigo_medicamento, $nombre_medicamento, $precio) = @_;
        
        # Crear encabezados si no existen
        $self->crear_proveedor_head($proveedor);
        $self->crear_medicamento_head($codigo_medicamento);
        
        # Buscar encabezados
        my $proveedor_head = $self->buscar_proveedor_head($proveedor);
        my $medicamento_head = $self->buscar_medicamento_head($codigo_medicamento);
        
        # Crear nuevo nodo
        my $nuevo_nodo = Node->new($proveedor, $codigo_medicamento, $nombre_medicamento, $precio);
        
        # Insertar en la fila (proveedor)
        my $temp_fila = $proveedor_head;
        while ($temp_fila->get_right() && $temp_fila->get_right()->get_col() lt $codigo_medicamento) {
            $temp_fila = $temp_fila->get_right();
        }
        
        $nuevo_nodo->set_right($temp_fila->get_right());
        $temp_fila->set_right($nuevo_nodo);
        $nuevo_nodo->set_left($temp_fila);
        
        if ($nuevo_nodo->get_right()) {
            $nuevo_nodo->get_right()->set_left($nuevo_nodo);
        }
        
        # Insertar en la columna (medicamento)
        my $temp_col = $medicamento_head;
        while ($temp_col->get_down() && $temp_col->get_down()->get_row() lt $proveedor) {
            $temp_col = $temp_col->get_down();
        }
        
        $nuevo_nodo->set_down($temp_col->get_down());
        $temp_col->set_down($nuevo_nodo);
        $nuevo_nodo->set_up($temp_col);
        
        if ($nuevo_nodo->get_down()) {
            $nuevo_nodo->get_down()->set_up($nuevo_nodo);
        }
        
        return $nuevo_nodo;
    }

    # Mostrar matriz completa
    sub mostrar_matriz_completa {
        my ($self) = @_;
        
        say "\n" . "=" x 60;
        say "     MATRIZ DISPERSA DE MEDICAMENTOS - RESUMEN";
        say "=" x 60;
        
        # Contar proveedores
        my $num_proveedores = scalar(keys %{$self->{proveedores}});
        say "Total de proveedores: $num_proveedores";
        
        # Contar medicamentos
        my $num_medicamentos = scalar(keys %{$self->{medicamentos}});
        say "Total de códigos de medicamento: $num_medicamentos";
        
        # Mostrar lista de proveedores
        say "\nLista de proveedores:";
        my $temp = $self->{head}->get_down();
        while ($temp) {
            say "  - " . $temp->get_row();
            $temp = $temp->get_down();
        }
        
        # Mostrar lista de medicamentos
        say "\nLista de códigos de medicamento:";
        $temp = $self->{head}->get_right();
        while ($temp) {
            say "  - " . $temp->get_col();
            $temp = $temp->get_right();
        }
        
        say "=" x 60;
    }

    # Generar archivo DOT para Graphviz con estructura de matriz tradicional
    sub generar_graphviz {
        my ($self) = @_;
        my $nombre_archivo = "matriz_medicamentos.dot";
        
        open my $fh, '>', $nombre_archivo or die "No se pudo crear el archivo: $!";
        
        print $fh "digraph MatrizDispersaMedicamentos {\n";
        print $fh "    rankdir=TB;\n";
        print $fh "    node [shape=box];\n";
        print $fh "    edge [dir=both];\n";
        print $fh "    splines=ortho;\n";
        print $fh "    ranksep=0.5;\n";
        print $fh "    nodesep=0.5;\n\n";
        
        # ===== ENCABEZADOS DE COLUMNAS (MEDICAMENTOS) =====
        print $fh "    // ===== ENCABEZADOS DE COLUMNAS (CÓDIGOS DE MEDICAMENTO) =====\n";
        my $col_temp = $self->{head}->get_right();
        my %col_nodes = ();
        my $col_count = 0;
        
        # Crear nodos para encabezados de columnas
        while ($col_temp) {
            my $col_id = "COL_" . $self->reemplazar_espacios($col_temp->get_col());
            $col_nodes{$col_temp->get_col()} = $col_id;
            
            print $fh "    $col_id [label=\"" . $col_temp->get_col() . "\", width=1.8, style=filled, fillcolor=lightblue];\n";
            $col_count++;
            $col_temp = $col_temp->get_right();
        }
        print $fh "\n";
        
        # ===== ENCABEZADOS DE FILAS (PROVEEDORES) =====
        print $fh "    // ===== ENCABEZADOS DE FILAS (PROVEEDORES) =====\n";
        my $row_temp = $self->{head}->get_down();
        my %row_nodes = ();
        my $row_count = 0;
        
        # Crear nodos para encabezados de filas
        while ($row_temp) {
            my $row_id = "ROW_" . $self->reemplazar_espacios($row_temp->get_row());
            $row_nodes{$row_temp->get_row()} = $row_id;
            
            print $fh "    $row_id [label=\"" . $row_temp->get_row() . "\", width=1.8, style=filled, fillcolor=lightgreen];\n";
            $row_count++;
            $row_temp = $row_temp->get_down();
        }
        print $fh "\n";
        
        # ===== NODOS DE DATOS (VALORES) =====
        print $fh "    // ===== NODOS DE DATOS (MEDICAMENTOS Y PRECIOS) =====\n";
        $row_temp = $self->{head}->get_down();
        my %data_positions = ();  # Para rastrear posición de cada nodo de datos
        my $data_count = 0;
        
        # Primera pasada: crear todos los nodos de datos
        while ($row_temp) {
            my $data_temp = $row_temp->get_right();
            
            while ($data_temp) {
                $data_count++;
                my $data_id = "DATA_" . $data_count;
                # Guardar posición para referencia posterior
                $data_positions{$data_temp->get_row()}{$data_temp->get_col()} = $data_id;
                
                my $label = $data_temp->get_medicamento() . "\\n" . "Q" . sprintf("%.2f", $data_temp->get_precio());
                
                print $fh "    $data_id [label=\"$label\", width=1.8, style=filled, fillcolor=yellow];\n";
                
                $data_temp = $data_temp->get_right();
            }
            $row_temp = $row_temp->get_down();
        }
        print $fh "\n";
        
        # ===== ESTRUCTURA DE MATRIZ TRADICIONAL =====
        print $fh "    // ===== ESTRUCTURA DE MATRIZ TRADICIONAL =====\n";
        
        # Nodo vacío en la esquina superior izquierda
        print $fh "    ESQUINA [label=\"\", shape=none, width=0.1, height=0.1];\n\n";
        
        # ===== FILA SUPERIOR: ENCABEZADOS DE COLUMNAS =====
        print $fh "    // ===== FILA SUPERIOR: ENCABEZADOS DE COLUMNAS =====\n";
        print $fh "    { rank=same; ESQUINA; ";
        $col_temp = $self->{head}->get_right();
        while ($col_temp) {
            my $col_id = "COL_" . $self->reemplazar_espacios($col_temp->get_col());
            print $fh "$col_id; ";
            $col_temp = $col_temp->get_right();
        }
        print $fh "}\n\n";
        
        # ===== CONEXIONES HORIZONTALES EN LA FILA SUPERIOR =====
        print $fh "    // ===== CONEXIONES HORIZONTALES EN LA FILA SUPERIOR =====\n";
        $col_temp = $self->{head}->get_right();
        my $prev_col_id = "ESQUINA";
        
        while ($col_temp) {
            my $col_id = "COL_" . $self->reemplazar_espacios($col_temp->get_col());
            print $fh "    $prev_col_id -> $col_id [color=blue];\n";
            $prev_col_id = $col_id;
            $col_temp = $col_temp->get_right();
        }
        print $fh "\n";
        
        # ===== FILAS DE DATOS (UNA POR PROVEEDOR) =====
        print $fh "    // ===== FILAS DE DATOS (UNA POR PROVEEDOR) =====\n";
        $row_temp = $self->{head}->get_down();
        my $fila_num = 0;
        
        while ($row_temp) {
            $fila_num++;
            my $row_id = $row_nodes{$row_temp->get_row()};
            my $data_temp = $row_temp->get_right();
            
            # Crear una fila para cada proveedor
            print $fh "    // Fila: " . $row_temp->get_row() . "\n";
            print $fh "    { rank=same; $row_id; ";
            
            # Añadir todos los datos de esta fila
            while ($data_temp) {
                my $data_id = $data_positions{$data_temp->get_row()}{$data_temp->get_col()};
                print $fh "$data_id; ";
                $data_temp = $data_temp->get_right();
            }
            print $fh "}\n\n";
            
            $row_temp = $row_temp->get_down();
        }
        
        # ===== CONEXIONES VERTICALES: ESQUINA -> PRIMER PROVEEDOR =====
        print $fh "    // ===== CONEXIONES VERTICALES =====\n";
        $row_temp = $self->{head}->get_down();
        my $prev_row_id = "ESQUINA";
        
        while ($row_temp) {
            my $row_id = "ROW_" . $self->reemplazar_espacios($row_temp->get_row());
            print $fh "    $prev_row_id -> $row_id [color=green];\n";
            $prev_row_id = $row_id;
            $row_temp = $row_temp->get_down();
        }
        print $fh "\n";
        
        # ===== CONEXIONES HORIZONTALES DENTRO DE CADA FILA =====
        print $fh "    // ===== CONEXIONES HORIZONTALES DENTRO DE CADA FILA =====\n";
        $row_temp = $self->{head}->get_down();
        
        while ($row_temp) {
            my $row_id = $row_nodes{$row_temp->get_row()};
            my $data_temp = $row_temp->get_right();
            
            # Conectar proveedor con su primer dato
            if ($data_temp) {
                my $first_data_id = $data_positions{$data_temp->get_row()}{$data_temp->get_col()};
                print $fh "    $row_id -> $first_data_id [color=green];\n";
                
                # Conectar datos entre sí horizontalmente
                my $prev_data_id = $first_data_id;
                $data_temp = $data_temp->get_right();
                
                while ($data_temp) {
                    my $data_id = $data_positions{$data_temp->get_row()}{$data_temp->get_col()};
                    print $fh "    $prev_data_id -> $data_id [color=red];\n";
                    $prev_data_id = $data_id;
                    $data_temp = $data_temp->get_right();
                }
            }
            $row_temp = $row_temp->get_down();
        }
        print $fh "\n";
        
        # ===== CONEXIONES VERTICALES DENTRO DE CADA COLUMNA =====
        print $fh "    // ===== CONEXIONES VERTICALES DENTRO DE CADA COLUMNA =====\n";
        my $col_temp2 = $self->{head}->get_right();
        
        while ($col_temp2) {
            my $col_id = $col_nodes{$col_temp2->get_col()};
            my $row_temp2 = $self->{head}->get_down();
            
            # Conectar encabezado de columna con su primer dato
            my $first_data_in_col = undef;
            my $prev_data_id = undef;
            
            while ($row_temp2) {
                if (exists $data_positions{$row_temp2->get_row()}{$col_temp2->get_col()}) {
                    my $data_id = $data_positions{$row_temp2->get_row()}{$col_temp2->get_col()};
                    
                    if (!defined $first_data_in_col) {
                        print $fh "    $col_id -> $data_id [color=blue];\n";
                        $first_data_in_col = $data_id;
                    }
                    
                    if (defined $prev_data_id) {
                        print $fh "    $prev_data_id -> $data_id [color=orange];\n";
                    }
                    $prev_data_id = $data_id;
                }
                $row_temp2 = $row_temp2->get_down();
            }
            
            $col_temp2 = $col_temp2->get_right();
        }
        
        # ===== ETIQUETAS PARA LA MATRIZ =====
        print $fh "\n    // ===== ETIQUETAS PARA LA MATRIZ =====\n";
        print $fh "    subgraph cluster_etiquetas {\n";
        print $fh "        style=invis;\n";
        print $fh "        margin=20;\n";
        print $fh "        \n";
        print $fh "        // Etiqueta para columnas\n";
        print $fh "        ETIQUETA_COLUMNAS [label=\"CÓDIGOS DE MEDICAMENTO\", shape=none, fontsize=16, fontcolor=blue];\n";
        print $fh "        \n";
        print $fh "        // Etiqueta para filas\n";
        print $fh "        ETIQUETA_FILAS [label=\"PROVEEDORES\", shape=none, fontsize=16, fontcolor=green];\n";
        print $fh "    }\n";
        
        # Posicionar etiquetas
        print $fh "    \n";
        print $fh "    // Posicionar etiqueta de columnas encima de la primera fila\n";
        print $fh "    ETIQUETA_COLUMNAS -> ESQUINA [style=invis];\n";
        print $fh "    \n";
        print $fh "    // Posicionar etiqueta de filas a la izquierda de la primera columna\n";
        print $fh "    ETIQUETA_FILAS -> ESQUINA [style=invis];\n";
        print $fh "    { rank=same; ETIQUETA_FILAS; ESQUINA; }\n";
        
        print $fh "}\n";
        close $fh;
        
        say "\n✓ Archivo DOT generado: $nombre_archivo";
        
        # Generar imagen PNG
        my $png_file = "matriz_medicamentos.png";
        
        if (system("dot -Tpng $nombre_archivo -o $png_file 2>/dev/null") == 0) {
            say "✓ Imagen PNG generada: $png_file";
            
            # Abrir automáticamente según el sistema operativo
            my $os = $^O;
            if ($os eq 'MSWin32') {
                system("start $png_file");
            } elsif ($os eq 'darwin') {
                system("open $png_file");
            } else {
                system("xdg-open $png_file 2>/dev/null || echo 'Abre manualmente: $png_file'");
            }
        } else {
            say "\n⚠ Graphviz no está instalado.";
            say "Instala Graphviz desde: https://graphviz.org/download/";
        }
    }
}

# Programa principal con menú
package main;

sub mostrar_menu {
    print "\n" . "=" x 50 . "\n";
    print "     MATRIZ DISPERSA DE MEDICAMENTOS\n";
    print "=" x 50 . "\n";
    print "1. Agregar nuevo medicamento\n";
    print "2. Mostrar resumen de la matriz\n";
    print "3. Generar gráfico con Graphviz\n";
    print "4. Salir\n";
    print "-" x 50 . "\n";
    print "Seleccione una opción: ";
}

# Crear matriz dispersa
my $matriz = MatrizDispersaMedicamentos->new();

say "\n" . "*" x 60;
say "   BIENVENIDO AL SISTEMA DE MATRIZ DISPERSA";
say "   Filas: Proveedores | Columnas: Códigos de Medicamento";
say "*" x 60;

# Menú principal
my $opcion = 0;
while ($opcion != 4) {
    mostrar_menu();
    $opcion = <STDIN>;
    chomp $opcion;
    
    if ($opcion == 1) {
        print "\n" . "-" x 40 . "\n";
        print "AGREGAR NUEVO MEDICAMENTO\n";
        print "-" x 40 . "\n";
        
        # Solicitar datos
        print "Proveedor: ";
        my $proveedor = <STDIN>;
        chomp $proveedor;
        
        print "Código del medicamento: ";
        my $codigo = <STDIN>;
        chomp $codigo;
        
        print "Nombre del medicamento: ";
        my $nombre = <STDIN>;
        chomp $nombre;
        
        print "Precio (en Quetzales): ";
        my $precio_input = <STDIN>;
        chomp $precio_input;
        
        # Validar precio
        if ($precio_input =~ /^\d+(\.\d+)?$/) {
            my $precio = $precio_input + 0;
            
            # Insertar en la matriz
            $matriz->insertar_medicamento($proveedor, $codigo, $nombre, $precio);
            say "\n✓ Medicamento agregado exitosamente!";
            say "  Proveedor: $proveedor";
            say "  Código: $codigo";
            say "  Nombre: $nombre";
            say "  Precio: Q" . sprintf("%.2f", $precio);
            
        } else {
            say "\n✗ Error: El precio debe ser un número válido (ej: 25.50)";
        }
        
    } elsif ($opcion == 2) {
        $matriz->mostrar_matriz_completa();
        
    } elsif ($opcion == 3) {
        print "\n" . "-" x 40 . "\n";
        print "GENERANDO GRÁFICO CON GRAPHVIZ\n";
        print "-" x 40 . "\n";
        
        $matriz->generar_graphviz();
        
    } elsif ($opcion == 4) {
        say "\n" . "=" x 50;
        say "¡Gracias por usar el sistema!";
        say "=" x 50 . "\n";
        
    } else {
        say "\n✗ Opción no válida. Por favor, seleccione 1-4.";
    }
    
    # Pausa antes de continuar
    if ($opcion != 4) {
        print "\nPresione Enter para continuar...";
        <STDIN>;
    }
}