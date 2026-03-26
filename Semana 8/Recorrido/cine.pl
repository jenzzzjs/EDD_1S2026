
use strict;
use warnings;
use Gtk3 '-init';

# definimos la clase nodo para el arbol
package Nodo;
sub new {

    # el constructor de la clase, lo llamamos al crear un nuevo nodo
    # crea y devuelve un objeto nodo con los atributos siguientes
    my ($class, $asiento, $nombre, $genero) = @_;
    my $self = {
        asiento => $asiento, # el numero de asiento que utilizaremos para manejar el orden o clave del nodo
        nombre => $nombre, # el nombre de la persona que reservara el asiento
        genero => $genero, # genero de la persona que ocupara el asiento
        izquierdo => undef, # Referencia al hijo izquierdo del nodo, undef significa que no tiene hijo izquierdo inicialmente
        derecho => undef, # Referencia al hijo derecho del nodo
        altura => 1 # Altura del nodo en el árbol, recordando que 1 = nodo hoja, esto nos va a servir para mantener el balance del arbol
    };
    bless $self, $class;
    return $self;
}

# Clase Árbol AVL
package ArbolAVL;
sub new {
    my $class = shift;
     # Obtiene el nombre de la clase del array @_
    my $self = { raiz => undef };
    # Crea el objeto árbol con un único atributo, que en este caso es la raiz, inicialmente esta vacio
    bless $self, $class;
    return $self;
}

# metodos importantes

# metodo para obtener la altura de un nodo
sub altura {
     # Obtiene la altura de un nodo, osea la distancia maxima que hay hasta una hoja
    my ($self, $nodo) = @_;
     # Recibe el objeto árbol y el nodo a consultar
    return 0 unless defined $nodo;
    # Si el nodo no existe entonces la altura = 0
     # Esto nos ayuda para las operaciones con hijos nulos
    return $nodo->{altura};
      # Devuelve la altura almacenada en el nodo
}



# Actualizar altura de un nodo
sub actualizar_altura {
    # calcumaos y actualizamos la altura de un nodo basado en sus hijos
    # La altura = 1 + max(altura_hijo_izq, altura_hijo_der)
    my ($self, $nodo) = @_;
    return 0 unless defined $nodo;
    # Si el nodo no existe, retorna 0
    my $altura_izq = $self->altura($nodo->{izquierdo});
    # Obtiene altura del hijo izquierdo la cual es una llamada recursiva al metodo del altura

    # Obtiene altura del hijo derecho
    my $altura_der = $self->altura($nodo->{derecho});

     # formula: 1 + la mayor altura entre los dos hijos
    $nodo->{altura} = ($altura_izq > $altura_der ? $altura_izq : $altura_der) + 1;

     # Devuelve la nueva altura calculada
    return $nodo->{altura};
}

# metodo para balancear


sub balance {

    # Calcula el factor de balance del nodo
    # Factor = altura_izquierda - altura_derecha
    # AVL requiere que este valor sea -1, 0 o 1
    my ($self, $nodo) = @_;
    return 0 unless defined $nodo;
     # Nodo nulo tiene balance 0


    return $self->altura($nodo->{izquierdo}) - $self->altura($nodo->{derecho});
     # Retorna diferencia de alturas entre hijo izquierdo y derecho
}

# metodo para la rotacion hacia la derecha
sub rotar_derecha {

    # Rotación simple a la derecha
    # Corrige cuando el árbol está cargado a la izquierda osea que el balance > 1
    my ($self, $y) = @_;

    # y es el nodo desbalanceado osea que es el padre original
    my $x = $y->{izquierdo};
    # x es el hijo izquierdo de y que vendria siendo la nueva raiz
    my $t2 = $x->{derecho};
    # t2 es el hijo derecho de x que iria cambiando de padre
    
     # Realizamos la rotacion
    $x->{derecho} = $y;

     # El hijo derecho de x ahora es y
    $y->{izquierdo} = $t2;

    # El hijo izquierdo de y ahora es t2
    
    # actualizamos alturas despues de la rotacion

    # Primero y porque ahora es hijo
    $self->actualizar_altura($y);

     # Luego x porque es la nueva raíz
    $self->actualizar_altura($x);
    
    return $x;
     # Devuelve x como la nueva raíz de este subárbol
}



# metodo para la rotacion hacia la  izquierda
sub rotar_izquierda {

      # Rotación simple a la izquierda
    # Corrige cuando el árbol está cargado a la derecha osea que el balance < -1
    my ($self, $x) = @_;
 # x es el nodo desbalanceado osea que es el padre original

    my $y = $x->{derecho};

 # y es el hijo derecho de x que será la nueva raíz
    my $t2 = $y->{izquierdo};

    # t2 es el hijo izquierdo de y que cambiara de padre
    

    # se realiza la rotacion
    $y->{izquierdo} = $x;
 # El hijo izquierdo de y ahora es x

    $x->{derecho} = $t2;
     # El hijo derecho de x ahora es t2
    
    # actuaizamos las alturas 
    $self->actualizar_altura($x);
    #primero x porque ahora es el hijo 
    $self->actualizar_altura($y);
    # Luego y porque es la nueva raíz
    
    return $y;
     # Devuelve y como la nueva raíz de este subárbol
}

# Insertar nodo
sub insertar {

    # Inserta un nuevo nodo en el árbol manteniendo la propiedad AVL
    # Es un método recursivo que inserta como lo hace un bst normal, tambien actualiza las alturas y verifica el balance, y tambien aplica los metodos de rotacion si son necesarios
    my ($self, $raiz, $asiento, $nombre, $genero) = @_;

    # self para el objeto del arbol, raiz para el nodo acrual de la recursion y los demas datos que utilizaremos para la insersion en el nuevo ndo
    

    # en el caso base
    unless (defined $raiz) {
        # Si llegamos a un lugar vacío, creamos nuevo nodo aquí
        return Nodo->new($asiento, $nombre, $genero);
        # Crea y devuelve un nuevo nodo con los datos proporcionados
    }
    
    # insersion normal de como en un BST
    if ($asiento < $raiz->{asiento}) {
        # Si el asiento es menor, va al subárbol izquierdo
        $raiz->{izquierdo} = $self->insertar($raiz->{izquierdo}, $asiento, $nombre, $genero);
        # Llamada recursiva para insertar en el hijo izquierdo
        # Actualiza la referencia al hijo izquierdo con lo que devuelva la inserción
    } elsif ($asiento > $raiz->{asiento}) {
         # Si el asiento es mayor, va al subárbol derecho
        $raiz->{derecho} = $self->insertar($raiz->{derecho}, $asiento, $nombre, $genero);
 # Llamada recursiva para insertar en el hijo derecho


    } else {
          # Si el asiento ya existe, no insertamos duplicados
        return $raiz;
         # Devuelve el nodo existente sin cambios
    }
    #actualizamos la altura del nodo actual
    $self->actualizar_altura($raiz);

    # Recalcula la altura después de la inserción en alguno de los hijos
    
    #Verificar balance del nodo
    my $balance = $self->balance($raiz);
     # Obtiene el factor de balance que es la diferencia de alturas
    
    # Aplicar rotaciones según el caso de desbalanceo


    # condicion 1 el cual es el desbalanceo izquierda-izquierda
    # balance > 1: subárbol izquierdo es más alto
        # Se corrige con una rotación derecha
    if ($balance > 1 && $asiento < $raiz->{izquierdo}{asiento}) {
        return $self->rotar_derecha($raiz);
    }

    #  Desbalanceo derecha-derecha
# balance < -1: subárbol derecho es más alto
# Se corrige con una rotación izquierda
    if ($balance < -1 && $asiento > $raiz->{derecho}{asiento}) {
        return $self->rotar_izquierda($raiz);
    }

    # Desbalanceo izquierda-derecha
     # balance > 1: subárbol izquierdo más alto
    if ($balance > 1 && $asiento > $raiz->{izquierdo}{asiento}) {
         # Primero rotación izquierda en el hijo, luego rotación derecha en el padre
        $raiz->{izquierdo} = $self->rotar_izquierda($raiz->{izquierdo});
        # se convierte en un caso de izquierda-izquierda
        return $self->rotar_derecha($raiz);
         # Luego aplica rotación derecha
    }

   # Desbalanceo derecha-izquierda

    # balance < -1: subárbol derecho más alto
    if ($balance < -1 && $asiento < $raiz->{derecho}{asiento}) {


        # Primero rotación derecha en el hijo, luego rotación izquierda en el padre
        $raiz->{derecho} = $self->rotar_derecha($raiz->{derecho});
        # Convierte el caso en derecha-derecha
        return $self->rotar_izquierda($raiz);
         # Luego aplica rotación izquierda
    }
    # Si llegamos aquí, el nodo está balanceado
    return $raiz;
    # Devuelve el nodo
}



# metodos para la eliminacion 

# Encontrar nodo mínimo
sub minimo {

      # Encuentra el nodo con el valor mínimo en un subárbol
    # que es util para encontrar el sucesor en eliminaciones
    my ($self, $nodo) = @_;

    # Comienza desde el nodo dado
    my $actual = $nodo;
    while (defined $actual->{izquierdo}) {

         # Mientras tenga hijo izquierdo
        $actual = $actual->{izquierdo};
         # Avanza hacia la izquierda, los menores siempre estaran en la izquierda
    }
    # Cuando ya no tiene hijo izquierdo, ese es el mínimo
    return $actual;
}

# Eliminar nodo
sub eliminar {
    my ($self, $raiz, $asiento) = @_;
    
     # CASO BASE: Subárbol vacío o no encontrado
    return undef unless defined $raiz;

    # PASO 1: Buscar el nodo a eliminar
     # Si el valor es menor, buscar en subárbol izquierdo
    if ($asiento < $raiz->{asiento}) {
        # Si el valor es menor, buscar en subárbol izquierdo
        
        $raiz->{izquierdo} = $self->eliminar($raiz->{izquierdo}, $asiento);
        # Llamada recursiva y actualiza referencia al hijo izquierdo
    } elsif ($asiento > $raiz->{asiento}) {
         # Si el valor es mayor, buscar en subárbol derecho
        $raiz->{derecho} = $self->eliminar($raiz->{derecho}, $asiento);
        # Llamada recursiva y actualiza referencia al hijo derecho
    } else {

        # NODO ENCONTRADO - proceder a eliminar según los casos
        
        # CASO 1: Nodo con un solo hijo o ningún hijo
        if (!defined $raiz->{izquierdo} || !defined $raiz->{derecho}) {
            # Si falta al menos un hijo
            my $temp = $raiz->{izquierdo} // $raiz->{derecho};
            # Obtiene el hijo existente si es que hay alguno
            return $temp unless defined $temp;

 # Si hay un hijo, lo devuelve reemplazando al nodo actual

            return undef;

             # Si no hay hijos, devuelve undef eliminando el nodo
        } else {

            # CASO 2: Nodo con dos hijos
            my $temp = $self->minimo($raiz->{derecho});

             # Encuentra el mínimo del subárbol derecho osea el sucesor en inorden

              # Copiar datos del sucesor al nodo actual
            $raiz->{asiento} = $temp->{asiento};
            $raiz->{nombre} = $temp->{nombre};
            $raiz->{genero} = $temp->{genero};

             # Eliminar el sucesor que tiene 0 o 1 hijo
            $raiz->{derecho} = $self->eliminar($raiz->{derecho}, $temp->{asiento});
        }
    }
      # Si el nodo no existe después de la eliminación
    return undef unless defined $raiz;
    # Verificación de seguridad


    # PASO 2: Actualizar altura
    $self->actualizar_altura($raiz);
      # Recalcula altura después de la eliminación
    

     # PASO 3: Verificar balance
    my $balance = $self->balance($raiz);

    # Obtiene factor de balance
    
    # PASO 4: Aplicar rotaciones si es necesario
    # Similar a inserción pero verificando balances de hijos
    
    # Rotaciones

     # CASO 1: Desbalanceo izquierda-izquierda
    if ($balance > 1 && $self->balance($raiz->{izquierdo}) >= 0) {
        return $self->rotar_derecha($raiz);
    }

    # CASO 2: Desbalanceo izquierda-derecha
    if ($balance > 1 && $self->balance($raiz->{izquierdo}) < 0) {
        $raiz->{izquierdo} = $self->rotar_izquierda($raiz->{izquierdo});
        return $self->rotar_derecha($raiz);
    }

    # CASO 3: Desbalanceo derecha-derecha
    if ($balance < -1 && $self->balance($raiz->{derecho}) <= 0) {
        return $self->rotar_izquierda($raiz);
    }

    # CASO 4: Desbalanceo derecha-izquierda
    if ($balance < -1 && $self->balance($raiz->{derecho}) > 0) {
        $raiz->{derecho} = $self->rotar_derecha($raiz->{derecho});
        return $self->rotar_izquierda($raiz);
    }
    # Devuelve el nodo
    return $raiz;
}

# Recorrido inorden
sub inorden {

    # Recorrido inorden: izquierdo - raíz - derecho
    my ($self, $raiz, $resultados) = @_;
    return unless defined $raiz;
    $self->inorden($raiz->{izquierdo}, $resultados);
    push @$resultados, [$raiz->{asiento}, $raiz->{nombre}, $raiz->{genero}];
    $self->inorden($raiz->{derecho}, $resultados);
}

# Recorrido preorden
sub preorden {
     # Recorrido preorden: raíz - izquierdo - derecho
    my ($self, $raiz, $resultados) = @_;
    return unless defined $raiz;
    push @$resultados, [$raiz->{asiento}, $raiz->{nombre}, $raiz->{genero}];
    $self->preorden($raiz->{izquierdo}, $resultados);
    $self->preorden($raiz->{derecho}, $resultados);
}

# Recorrido postorden
sub postorden {
    # Recorrido postorden: izquierdo - derecho - raíz
    # Resultado: útil para eliminar el árbol (hojas primero)
    my ($self, $raiz, $resultados) = @_;
    return unless defined $raiz;
    $self->postorden($raiz->{izquierdo}, $resultados);
    $self->postorden($raiz->{derecho}, $resultados);
    push @$resultados, [$raiz->{asiento}, $raiz->{nombre}, $raiz->{genero}];
}

# Generar archivo DOT para Graphviz
sub generar_dot {

    # Genera el código DOT para Graphvi
    my ($self, $raiz, $dot, $contador) = @_;

        # $dot: referencia al string que acumula el código DOT
    # $contador: referencia a un array con un número que sirve como ID unico
    return unless defined $raiz;
     # Si no hay nodo, termina
    
    my $id = $contador->[0]++;

    # Asigna un ID único a este nodo y luego incrementa el contador
    # Los IDs son números secuenciales 0, 1 2 3 
    my $label = "Asiento: $raiz->{asiento}\\nNombre: $raiz->{nombre}\\nGénero: $raiz->{genero}";
    # Crea la etiqueta del nodo con los 3 datos
    # \\n es un salto de línea
    
    $$dot .= "    node$id [label=\"$label\"];\n";

      # Agrega la definición del nodo al código DOT
    # .$ = concatenación
    # $$dot accede al valor de la referencia en el string
    
    if (defined $raiz->{izquierdo}) {

          # Si tiene hijo izquierdo
        my $hijo_id = $contador->[0];

         # El ID del hijo será el siguiente número 
        $self->generar_dot($raiz->{izquierdo}, $dot, $contador);

         # Llamada recursiva para generar el hijo izquierdo
        $$dot .= "    node$id -> node$hijo_id ;\n";
         # Agrega una arista del nodo actual a su hijo izquierdo
    }
    
    if (defined $raiz->{derecho}) {
        # Si tiene hijo derecho
        my $hijo_id = $contador->[0];
         # El ID del hijo será el siguiente número
        $self->generar_dot($raiz->{derecho}, $dot, $contador);
         # Llamada recursiva para generar el hijo derecho
        $$dot .= "    node$id -> node$hijo_id ;\n";
        
    }
}

# Interfaz principal
package main;

# Crear árbol AVL
my $arbol = ArbolAVL->new();

# Crear ventana principal
my $ventana = Gtk3::Window->new('toplevel');
$ventana->set_title('Sistema de Cine - Arbol AVL');
$ventana->set_default_size(900, 700);
$ventana->set_border_width(10);
$ventana->signal_connect('destroy' => sub { Gtk3->main_quit(); });

# Box principal vertical
my $box_principal = Gtk3::Box->new('vertical', 5);
$ventana->add($box_principal);

# Frame para controles
my $frame_controles = Gtk3::Frame->new('Controles del Arbol AVL');
$box_principal->pack_start($frame_controles, 0, 0, 5);

# Box para controles
my $box_controles = Gtk3::Box->new('vertical', 5);
$box_controles->set_border_width(10);
$frame_controles->add($box_controles);

# Grid para entrada de datos
my $grid_datos = Gtk3::Grid->new();
$grid_datos->set_row_spacing(5);
$grid_datos->set_column_spacing(5);
$box_controles->pack_start($grid_datos, 0, 0, 5);

# Campos de entrada
my $label_asiento = Gtk3::Label->new('Asiento:');
$grid_datos->attach($label_asiento, 0, 0, 1, 1);

my $entrada_asiento = Gtk3::Entry->new();
$entrada_asiento->set_width_chars(10);
$grid_datos->attach($entrada_asiento, 1, 0, 1, 1);

my $label_nombre = Gtk3::Label->new('Nombre:');
$grid_datos->attach($label_nombre, 2, 0, 1, 1);

my $entrada_nombre = Gtk3::Entry->new();
$entrada_nombre->set_width_chars(20);
$grid_datos->attach($entrada_nombre, 3, 0, 1, 1);

my $label_genero = Gtk3::Label->new('Genero:');
$grid_datos->attach($label_genero, 4, 0, 1, 1);

my $entrada_genero = Gtk3::Entry->new();
$entrada_genero->set_width_chars(15);
$grid_datos->attach($entrada_genero, 5, 0, 1, 1);

# Box para botones
my $box_botones = Gtk3::Box->new('horizontal', 5);
$box_controles->pack_start($box_botones, 0, 0, 5);

# Botón Insertar
my $boton_insertar = Gtk3::Button->new_with_label('Insertar Dato');
$boton_insertar->signal_connect('clicked' => sub {
    my $asiento = $entrada_asiento->get_text();
    my $nombre = $entrada_nombre->get_text();
    my $genero = $entrada_genero->get_text();
    
    if ($asiento && $nombre && $genero) {
        $arbol->{raiz} = $arbol->insertar($arbol->{raiz}, $asiento, $nombre, $genero);
        $entrada_asiento->set_text('');
        $entrada_nombre->set_text('');
        $entrada_genero->set_text('');
        actualizar_tabla();
    }
});
$box_botones->pack_start($boton_insertar, 0, 0, 5);

# Botón Eliminar
my $boton_eliminar = Gtk3::Button->new_with_label('Eliminar Dato');
$boton_eliminar->signal_connect('clicked' => sub {
    my $asiento = $entrada_asiento->get_text();
    if ($asiento) {
        $arbol->{raiz} = $arbol->eliminar($arbol->{raiz}, $asiento);
        $entrada_asiento->set_text('');
        actualizar_tabla();
    }
});
$box_botones->pack_start($boton_eliminar, 0, 0, 5);

# Botón Cargar Datos
my $boton_cargar = Gtk3::Button->new_with_label('Cargar Datos');
$boton_cargar->signal_connect('clicked' => sub {
    my @datos_ejemplo = (
        [1, "Jens Pablo", "Masculino"],
        [2, "Esdras Mazat", "Masculino"],
        [3, "Lesly Rubio", "Femenino"],
        [4, "Eduardo Zamora", "Masculino"],
        [5, "Sherly Pascual", "Femenino"],
        [6, 'Gueslim Fernandez', 'masculino'],
        [7, "Maria Flores", "Femenino"],
        [8, "Allan Cardona", "Masculino"],
        [9, 'Alejandro Giron', 'masculino'],
        [10, 'Mariana Sulecio', 'Femenino']
    );
    
    foreach my $dato (@datos_ejemplo) {
        $arbol->{raiz} = $arbol->insertar($arbol->{raiz}, $dato->[0], $dato->[1], $dato->[2]);
    }
    actualizar_tabla();
});
$box_botones->pack_start($boton_cargar, 0, 0, 5);

# Botón Graficar
my $boton_graficar = Gtk3::Button->new_with_label('Graficar arbol');
$boton_graficar->signal_connect('clicked' => sub {
    if (defined $arbol->{raiz}) {
        my $dot = "digraph AVL {\n";
        $dot .= "    node [shape=record, style=filled, fillcolor=lightblue];\n";
        my $contador = [0];
        $arbol->generar_dot($arbol->{raiz}, \$dot, $contador);
        $dot .= "}\n";
        
        my $archivo_dot = 'arbol_avl.dot';
        open(my $fh, '>', $archivo_dot) or warn "No se pudo crear el archivo: $!";
        print $fh $dot;
        close $fh;
        
        system('dot -Tpng arbol_avl.dot -o arbol_avl.png');
        system('xdg-open arbol_avl.png > /dev/null 2>&1 &');
    }
});
$box_botones->pack_start($boton_graficar, 0, 0, 5);

# Frame para recorridos
my $frame_recorridos = Gtk3::Frame->new('Recorridos del arbol');
$box_principal->pack_start($frame_recorridos, 1, 1, 5);

# Box para recorridos
my $box_recorridos = Gtk3::Box->new('vertical', 5);
$box_recorridos->set_border_width(10);
$frame_recorridos->add($box_recorridos);

# Box para botones de tipo de recorrido
my $box_tipo_recorrido = Gtk3::Box->new('horizontal', 5);
$box_recorridos->pack_start($box_tipo_recorrido, 0, 0, 5);

my $label_recorrido = Gtk3::Label->new('Seleccionar recorrido:');
$box_tipo_recorrido->pack_start($label_recorrido, 0, 0, 5);

my $recorrido_actual = 'inorden';

my $boton_inorden = Gtk3::Button->new_with_label('Inorden');
$boton_inorden->signal_connect('clicked' => sub {
    $recorrido_actual = 'inorden';
    actualizar_tabla();
});
$box_tipo_recorrido->pack_start($boton_inorden, 0, 0, 5);

my $boton_preorden = Gtk3::Button->new_with_label('Preorden');
$boton_preorden->signal_connect('clicked' => sub {
    $recorrido_actual = 'preorden';
    actualizar_tabla();
});
$box_tipo_recorrido->pack_start($boton_preorden, 0, 0, 5);

my $boton_postorden = Gtk3::Button->new_with_label('Postorden');
$boton_postorden->signal_connect('clicked' => sub {
    $recorrido_actual = 'postorden';
    actualizar_tabla();
});
$box_tipo_recorrido->pack_start($boton_postorden, 0, 0, 5);

# Crear TreeView para mostrar los recorridos
my $modelo_tabla = Gtk3::ListStore->new('Glib::String', 'Glib::String', 'Glib::String');

my $treeview = Gtk3::TreeView->new_with_model($modelo_tabla);

# Crear columnas
my $columna_asiento = Gtk3::TreeViewColumn->new();
$columna_asiento->set_title('Asiento');
my $render_asiento = Gtk3::CellRendererText->new();
$columna_asiento->pack_start($render_asiento, 1);
$columna_asiento->add_attribute($render_asiento, 'text', 0);
$columna_asiento->set_fixed_width(150);
$treeview->append_column($columna_asiento);

my $columna_nombre = Gtk3::TreeViewColumn->new();
$columna_nombre->set_title('Nombre');
my $render_nombre = Gtk3::CellRendererText->new();
$columna_nombre->pack_start($render_nombre, 1);
$columna_nombre->add_attribute($render_nombre, 'text', 1);
$columna_nombre->set_fixed_width(300);
$treeview->append_column($columna_nombre);

my $columna_genero = Gtk3::TreeViewColumn->new();
$columna_genero->set_title('Genero');
my $render_genero = Gtk3::CellRendererText->new();
$columna_genero->pack_start($render_genero, 1);
$columna_genero->add_attribute($render_genero, 'text', 2);
$columna_genero->set_fixed_width(200);
$treeview->append_column($columna_genero);

# Scroll para el TreeView
my $scroll = Gtk3::ScrolledWindow->new();
$scroll->set_policy('automatic', 'automatic');
$scroll->add($treeview);
$box_recorridos->pack_start($scroll, 1, 1, 5);

# Función para actualizar la tabla
sub actualizar_tabla {
    $modelo_tabla->clear();
    
    my $resultados = [];
    if ($recorrido_actual eq 'inorden') {
        $arbol->inorden($arbol->{raiz}, $resultados);
    } elsif ($recorrido_actual eq 'preorden') {
        $arbol->preorden($arbol->{raiz}, $resultados);
    } elsif ($recorrido_actual eq 'postorden') {
        $arbol->postorden($arbol->{raiz}, $resultados);
    }
    
    foreach my $dato (@$resultados) {
        my $iter = $modelo_tabla->append();
        $modelo_tabla->set($iter,
            0 => $dato->[0],
            1 => $dato->[1],
            2 => $dato->[2]
        );
    }
}

$ventana->show_all();
Gtk3->main();