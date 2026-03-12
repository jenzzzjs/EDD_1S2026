# ==============================================================================
# PAQUETE: avl::avl
# PROPOSITO: Implementacion completa del Arbol AVL (Adelson-Velsky y Landis).
#
# QUE ES UN ARBOL AVL?
#   Es un Arbol Binario de Busqueda (BST) auto-balanceado.
#   La propiedad adicional respecto al BST es:
#     Para CADA nodo, la diferencia de alturas entre su subarbol izquierdo
#     y su subarbol derecho (llamada FACTOR DE BALANCE) debe ser -1, 0 o 1.
#
#   Si tras una operacion ese factor queda en -2 o +2, el arbol realiza
#   una ROTACION para recuperar el balance. Esto garantiza que la altura
#   del arbol sea siempre O(log n), manteniendo busqueda/insercion/eliminacion
#   en tiempo logaritmico incluso en el peor caso.
#
# FACTOR DE BALANCE (bf) de un nodo:
#   bf = altura(subarbol_izquierdo) - altura(subarbol_derecho)
#   bf =  0  => perfectamente balanceado en ese nodo
#   bf =  1  => un nivel mas pesado a la izquierda  (OK)
#   bf = -1  => un nivel mas pesado a la derecha    (OK)
#   bf =  2  => DESBALANCE izquierda -> se necesita rotacion
#   bf = -2  => DESBALANCE derecha   -> se necesita rotacion
# ==============================================================================
package avl::avl;

use strict;
use warnings;

use avl::nodo;  # importa el paquete del nodo para poder crear instancias

# Constante que actua como alias: en lugar de escribir 'avl::nodo->new()'
# podemos escribir 'Nodo->new()' haciendo el codigo mas legible.
use constant Nodo => 'avl::nodo';

# ------------------------------------------------------------------------------
# CONSTRUCTOR: new()
# Crea un arbol AVL vacio.
#   root -> apunta al nodo raiz (undef = arbol vacio)
#   size -> contador de nodos actuales en el arbol
# ------------------------------------------------------------------------------
sub new {
    my ($class) = @_;
    my $self = {
        root => undef,  # sin raiz: el arbol comienza vacio
        size => 0,      # cero nodos al inicio
    };
    bless $self, $class;
    return $self;
}

# ------------------------------------------------------------------------------
# METODO: is_empty()
# Retorna 1 si el arbol esta vacio (root es undef), 0 si tiene al menos un nodo.
# ------------------------------------------------------------------------------
sub is_empty {
    my ($self) = @_;
    return !defined($self->{root}) ? 1 : 0;
}

# ------------------------------------------------------------------------------
# METODO: get_size()
# Retorna la cantidad de nodos que hay actualmente en el arbol.
# ------------------------------------------------------------------------------
sub get_size {
    my ($self) = @_;
    return $self->{size};
}

# ==============================================================================
# SECCION: UTILIDADES DE ALTURA Y BALANCE
# Estas funciones auxiliares son la base de todo el mecanismo AVL.
# ==============================================================================

# ------------------------------------------------------------------------------
# _get_height($nodo)
# Retorna la altura de un nodo de forma SEGURA:
#   - Si el nodo existe, devuelve su altura almacenada.
#   - Si el nodo es undef (no existe), devuelve 0.
# Esto evita tener que verificar defined() en cada llamada y simplifica el codigo.
# ------------------------------------------------------------------------------
sub _get_height {
    my ($self, $nodo) = @_;
    return defined($nodo) ? $nodo->get_height() : 0;
}

# ------------------------------------------------------------------------------
# _update_height($nodo)
# Recalcula y actualiza la altura de un nodo segun sus hijos actuales.
#
# Formula: altura = 1 + max(altura_hijo_izq, altura_hijo_der)
#
# CUANDO SE LLAMA: despues de cada insercion, eliminacion o rotacion,
# porque la estructura del arbol cambio y las alturas guardadas pueden
# haberse vuelto incorrectas.
# ------------------------------------------------------------------------------
sub _update_height {
    my ($self, $nodo) = @_;
    return unless defined($nodo);  # si el nodo no existe, no hay nada que actualizar

    my $h_izq = $self->_get_height($nodo->get_left());   # altura del subarbol izquierdo
    my $h_der = $self->_get_height($nodo->get_right());  # altura del subarbol derecho

    # la altura del nodo es 1 (el propio nivel) mas la mayor de las dos alturas hijas
    my $nueva_altura = 1 + ($h_izq > $h_der ? $h_izq : $h_der);
    $nodo->set_height($nueva_altura);
}

# ------------------------------------------------------------------------------
# _get_balance($nodo)
# Calcula el FACTOR DE BALANCE de un nodo:
#   bf = altura(izq) - altura(der)
#
# Interpretacion:
#   bf > 0  => el subarbol izquierdo es mas alto  (pesado a la izquierda)
#   bf < 0  => el subarbol derecho  es mas alto   (pesado a la derecha)
#   bf = 0  => ambos subarboles tienen la misma altura
# ------------------------------------------------------------------------------
sub _get_balance {
    my ($self, $nodo) = @_;
    return 0 unless defined($nodo);  # un nodo inexistente tiene balance 0
    return $self->_get_height($nodo->get_left()) - $self->_get_height($nodo->get_right());
}

# ==============================================================================
# SECCION: ROTACIONES
#
# Una rotacion es una reestructuracion local del arbol que:
#   1. Restaura la propiedad de balance (bf en [-1, 0, 1])
#   2. Mantiene la propiedad de orden del BST (izq < raiz < der)
#   3. NO pierde ningun nodo
#
# Existen 4 casos de desbalance, cada uno con su rotacion:
#   LL -> rotacion simple a la derecha
#   RR -> rotacion simple a la izquierda
#   LR -> rotacion doble: primero izquierda luego derecha
#   RL -> rotacion doble: primero derecha luego izquierda
# ==============================================================================

# ------------------------------------------------------------------------------
# _rotar_derecha($y)  [caso LL]
#
# Se aplica cuando el nodo $y tiene bf = +2 y su hijo izquierdo tiene bf >= 0
# (el desbalance esta en el subarbol izquierdo-izquierdo).
#
# Antes:               Despues:
#       y                  x
#      / \                / \
#     x   T3    =>      T1   y
#    / \                    / \
#   T1  T2                T2  T3
#
# El hijo izquierdo (x) SUBE a la posicion de y.
# y BAJA hacia la derecha de x.
# El subarbol T2 (que estaba a la derecha de x) pasa a ser el izquierdo de y,
# porque todos sus valores son mayores que x pero menores que y.
# ------------------------------------------------------------------------------
sub _rotar_derecha {
    my ($self, $y) = @_;

    my $x  = $y->get_left();   # x es el hijo izquierdo que va a subir
    my $T2 = $x->get_right();  # T2 es el subarbol que va a "reasignarse"

    # realizar la rotacion: x sube, y baja a la derecha
    $x->set_right($y);   # y pasa a ser hijo derecho de x
    $y->set_left($T2);   # T2 pasa a ser hijo izquierdo de y

    # IMPORTANTE: actualizar alturas en el orden correcto
    # primero y (que ahora es hijo) y luego x (que ahora es padre)
    $self->_update_height($y);
    $self->_update_height($x);

    my $val_y = $y->get_data();
    my $val_x = $x->get_data();
    print "  [Rotacion DERECHA] Nodo '$val_y' sube a la derecha de '$val_x'.\n";

    return $x;  # x es ahora la nueva raiz de este subarbol
}

# ------------------------------------------------------------------------------
# _rotar_izquierda($x)  [caso RR]
#
# Se aplica cuando el nodo $x tiene bf = -2 y su hijo derecho tiene bf <= 0
# (el desbalance esta en el subarbol derecho-derecho).
#
# Antes:               Despues:
#     x                    y
#    / \                  / \
#   T1   y      =>       x   T3
#       / \             / \
#      T2  T3          T1  T2
#
# El hijo derecho (y) SUBE a la posicion de x.
# x BAJA hacia la izquierda de y.
# T2 (subarbol izquierdo de y) pasa a ser el derecho de x.
# ------------------------------------------------------------------------------
sub _rotar_izquierda {
    my ($self, $x) = @_;

    my $y  = $x->get_right();  # y es el hijo derecho que va a subir
    my $T2 = $y->get_left();   # T2 es el subarbol que se va a reasignar

    # realizar la rotacion: y sube, x baja a la izquierda
    $y->set_left($x);    # x pasa a ser hijo izquierdo de y
    $x->set_right($T2);  # T2 pasa a ser hijo derecho de x

    # actualizar alturas: primero x (hijo) luego y (padre)
    $self->_update_height($x);
    $self->_update_height($y);

    my $val_x = $x->get_data();
    my $val_y = $y->get_data();
    print "  [Rotacion IZQUIERDA] Nodo '$val_x' sube a la izquierda de '$val_y'.\n";

    return $y;  # y es ahora la nueva raiz de este subarbol
}

# ------------------------------------------------------------------------------
# _balancear($nodo)
# Funcion central del AVL: decide que rotacion aplicar segun el factor de balance.
#
# Se llama al REGRESAR la recursion despues de insertar o eliminar,
# es decir, se aplica de abajo hacia arriba en el camino de vuelta.
#
# Los 4 casos:
#
#   LL (bf =  2, bf_hijo_izq >= 0): desbalance izquierda-izquierda
#      -> rotacion simple a la DERECHA
#
#   LR (bf =  2, bf_hijo_izq <  0): desbalance izquierda-derecha
#      -> rotar hijo izquierdo a la izquierda primero (convierte en LL)
#      -> luego rotar el nodo a la derecha
#
#   RR (bf = -2, bf_hijo_der <= 0): desbalance derecha-derecha
#      -> rotacion simple a la IZQUIERDA
#
#   RL (bf = -2, bf_hijo_der >  0): desbalance derecha-izquierda
#      -> rotar hijo derecho a la derecha primero (convierte en RR)
#      -> luego rotar el nodo a la izquierda
# ------------------------------------------------------------------------------
sub _balancear {
    my ($self, $nodo) = @_;

    $self->_update_height($nodo);           # recalcular altura con la nueva estructura
    my $balance = $self->_get_balance($nodo);  # calcular factor de balance
    my $valor   = $nodo->get_data();

    # --- CASO LL: pesado a la izquierda, hijo izquierdo tambien pesado a la izquierda ---
    if ($balance > 1 && $self->_get_balance($nodo->get_left()) >= 0) {
        print "  [Balance=$balance en '$valor'] Caso LL -> Rotacion simple DERECHA.\n";
        return $self->_rotar_derecha($nodo);
    }

    # --- CASO LR: pesado a la izquierda, pero hijo izquierdo es pesado a la derecha ---
    # Primero se convierte al caso LL rotando el hijo izquierdo hacia la izquierda.
    if ($balance > 1 && $self->_get_balance($nodo->get_left()) < 0) {
        print "  [Balance=$balance en '$valor'] Caso LR -> Rotacion doble (IZQUIERDA + DERECHA).\n";
        $nodo->set_left($self->_rotar_izquierda($nodo->get_left()));  # paso 1: rotar hijo izq
        return $self->_rotar_derecha($nodo);                          # paso 2: rotar nodo
    }

    # --- CASO RR: pesado a la derecha, hijo derecho tambien pesado a la derecha ---
    if ($balance < -1 && $self->_get_balance($nodo->get_right()) <= 0) {
        print "  [Balance=$balance en '$valor'] Caso RR -> Rotacion simple IZQUIERDA.\n";
        return $self->_rotar_izquierda($nodo);
    }

    # --- CASO RL: pesado a la derecha, pero hijo derecho es pesado a la izquierda ---
    # Primero se convierte al caso RR rotando el hijo derecho hacia la derecha.
    if ($balance < -1 && $self->_get_balance($nodo->get_right()) > 0) {
        print "  [Balance=$balance en '$valor'] Caso RL -> Rotacion doble (DERECHA + IZQUIERDA).\n";
        $nodo->set_right($self->_rotar_derecha($nodo->get_right()));  # paso 1: rotar hijo der
        return $self->_rotar_izquierda($nodo);                        # paso 2: rotar nodo
    }

    # Si bf esta en {-1, 0, 1}: el nodo ya esta balanceado, no se hace nada
    return $nodo;
}

# ==============================================================================
# SECCION: INSERTAR
# ==============================================================================

# ------------------------------------------------------------------------------
# insertar($data)
# Punto de entrada publico para insertar un valor en el arbol.
#
# Delega la logica recursiva a _insertar_recursivo y actualiza el contador
# de tamano solo si el valor fue realmente insertado (no era duplicado).
# ------------------------------------------------------------------------------
sub insertar {
    my ($self, $data) = @_;

    my $era_vacio = $self->is_empty();  # guardamos si estaba vacio para el mensaje de raiz
    my $insertado = 0;

    # _insertar_recursivo retorna dos valores: la nueva raiz del subarbol y un flag
    ($self->{root}, $insertado) = $self->_insertar_recursivo($self->{root}, $data);

    if ($insertado) {
        $self->{size}++;
        if ($era_vacio) {
            print "Insertado '$data' como RAIZ del arbol.\n";
        }
    }
}

# ------------------------------------------------------------------------------
# _insertar_recursivo($nodo_actual, $data)
# Recorre el arbol siguiendo las reglas del BST para encontrar el lugar correcto.
#
# Logica:
#   1. Si $nodo_actual es undef: llegamos al lugar -> crear el nuevo nodo
#   2. Si $data < valor_actual:  ir al subarbol IZQUIERDO
#   3. Si $data > valor_actual:  ir al subarbol DERECHO
#   4. Si $data == valor_actual: duplicado, no insertar
#
# Al REGRESAR la recursion (de vuelta hacia la raiz), se llama a _balancear()
# en cada nodo del camino para corregir cualquier desbalance generado.
#
# Retorna: ($nodo_resultado, $flag_insertado)
# ------------------------------------------------------------------------------
sub _insertar_recursivo {
    my ($self, $nodo_actual, $data) = @_;

    # CASO BASE: posicion libre encontrada -> crear nuevo nodo hoja
    if (!defined($nodo_actual)) {
        my $nuevo = Nodo->new($data);  # nuevo nodo con altura=1, sin hijos
        return ($nuevo, 1);            # retorna el nodo y flag=1 (si fue insertado)
    }

    my $valor_actual = $nodo_actual->get_data();
    my $insertado    = 0;

    if ($data < $valor_actual) {
        # el valor es menor: debe ir en el subarbol IZQUIERDO
        my $nuevo_izq;
        ($nuevo_izq, $insertado) = $self->_insertar_recursivo($nodo_actual->get_left(), $data);
        $nodo_actual->set_left($nuevo_izq);  # reconectar el subarbol (puede haber rotado)
        if ($insertado && defined($nodo_actual->get_left())) {
            print "Insertado '$data' a la IZQUIERDA de '$valor_actual'.\n";
        }
    } elsif ($data > $valor_actual) {
        # el valor es mayor: debe ir en el subarbol DERECHO
        my $nuevo_der;
        ($nuevo_der, $insertado) = $self->_insertar_recursivo($nodo_actual->get_right(), $data);
        $nodo_actual->set_right($nuevo_der);  # reconectar el subarbol
        if ($insertado && defined($nodo_actual->get_right())) {
            print "Insertado '$data' a la DERECHA de '$valor_actual'.\n";
        }
    } else {
        # el valor ya existe: los arboles AVL (como BST) no permiten duplicados
        print "Advertencia: El valor '$data' ya existe en el arbol. No se insertaron duplicados.\n";
        return ($nodo_actual, 0);  # retorna el nodo sin cambios y flag=0
    }

    if ($insertado) {
        # al regresar de la recursion, balancear este nodo si es necesario.
        # _balancear tambien actualiza la altura del nodo.
        $nodo_actual = $self->_balancear($nodo_actual);
    }

    return ($nodo_actual, $insertado);
}

# ==============================================================================
# SECCION: BUSCAR
# ==============================================================================

# ------------------------------------------------------------------------------
# buscar($data)
# Busca un valor en el arbol y retorna el NODO que lo contiene (o undef).
#
# Como el AVL es un BST, la busqueda es identica a la del BST:
# en cada nodo, comparamos y decidimos ir a izquierda, derecha o retornar.
# La complejidad es O(log n) gracias al balance garantizado.
# ------------------------------------------------------------------------------
sub buscar {
    my ($self, $data) = @_;

    if ($self->is_empty()) {
        print "El arbol esta vacio. No hay nada que buscar.\n";
        return undef;
    }

    return $self->_buscar_recursivo($self->{root}, $data);
}

# ------------------------------------------------------------------------------
# _buscar_recursivo($nodo_actual, $data)
# Recorre el arbol recursivamente comparando el dato buscado con cada nodo.
#
# Tres casos:
#   1. $nodo_actual es undef: el valor no existe en el arbol
#   2. $data == valor: ENCONTRADO, retornar el nodo
#   3. $data <  valor: buscar en el subarbol izquierdo
#   4. $data >  valor: buscar en el subarbol derecho
# ------------------------------------------------------------------------------
sub _buscar_recursivo {
    my ($self, $nodo_actual, $data) = @_;

    return undef unless defined($nodo_actual);  # caso base: no encontrado

    my $valor_actual = $nodo_actual->get_data();

    if ($data == $valor_actual) {
        return $nodo_actual;  # encontrado: retornar referencia al nodo
    } elsif ($data < $valor_actual) {
        return $self->_buscar_recursivo($nodo_actual->get_left(), $data);
    } else {
        return $self->_buscar_recursivo($nodo_actual->get_right(), $data);
    }
}

# ==============================================================================
# SECCION: ELIMINAR
# ==============================================================================

# ------------------------------------------------------------------------------
# eliminar($data)
# Punto de entrada publico para eliminar un valor del arbol.
#
# Primero verifica que el valor exista (con buscar) para dar un mensaje claro.
# Luego delega la eliminacion a _eliminar_recursivo y reduce el contador.
# ------------------------------------------------------------------------------
sub eliminar {
    my ($self, $data) = @_;

    if ($self->is_empty()) {
        print "El arbol esta vacio. No hay nada que eliminar.\n";
        return;
    }

    my $existe = $self->buscar($data);  # verificacion previa: existe el valor?
    if (!defined($existe)) {
        print "El valor '$data' no existe en el arbol.\n";
        return;
    }

    $self->{root} = $self->_eliminar_recursivo($self->{root}, $data);
    $self->{size}--;
    print "Valor '$data' eliminado exitosamente.\n";
}

# ------------------------------------------------------------------------------
# _eliminar_recursivo($nodo_actual, $data)
# Busca el nodo a eliminar y lo quita segun su caso:
#
# CASO 1 - Nodo hoja (sin hijos):
#   Simplemente se retorna undef para que el padre lo desconecte.
#
# CASO 2 - Nodo con UN solo hijo:
#   Se retorna ese hijo directamente, "saltando" el nodo eliminado.
#
# CASO 3 - Nodo con DOS hijos (el mas complejo):
#   No se puede eliminar directamente sin romper la estructura.
#   Solucion: encontrar el SUCESOR INORDEN (el menor valor del subarbol derecho),
#   copiar su dato en el nodo actual, y luego eliminar ese sucesor del subarbol derecho.
#   El sucesor siempre tiene como maximo UN hijo derecho, por lo que
#   su eliminacion cae en el caso 1 o 2 (mas simples).
#
# Despues de cada eliminacion, se llama a _balancear() al regresar la recursion.
# ------------------------------------------------------------------------------
sub _eliminar_recursivo {
    my ($self, $nodo_actual, $data) = @_;

    return undef unless defined($nodo_actual);  # caso base: nodo no encontrado

    my $valor_actual = $nodo_actual->get_data();

    if ($data < $valor_actual) {
        # el valor a eliminar esta en el subarbol izquierdo
        $nodo_actual->set_left(
            $self->_eliminar_recursivo($nodo_actual->get_left(), $data)
        );
    } elsif ($data > $valor_actual) {
        # el valor a eliminar esta en el subarbol derecho
        $nodo_actual->set_right(
            $self->_eliminar_recursivo($nodo_actual->get_right(), $data)
        );
    } else {
        # ENCONTRADO: este es el nodo a eliminar
        if ($nodo_actual->es_hoja()) {
            # CASO 1: sin hijos -> simplemente desconectar
            print "Eliminando hoja con valor '$valor_actual'.\n";
            return undef;

        } elsif (!defined($nodo_actual->get_left())) {
            # CASO 2a: solo tiene hijo derecho -> el hijo sube a esta posicion
            print "Eliminando nodo '$valor_actual' (solo tiene hijo derecho).\n";
            return $nodo_actual->get_right();

        } elsif (!defined($nodo_actual->get_right())) {
            # CASO 2b: solo tiene hijo izquierdo -> el hijo sube a esta posicion
            print "Eliminando nodo '$valor_actual' (solo tiene hijo izquierdo).\n";
            return $nodo_actual->get_left();

        } else {
            # CASO 3: tiene dos hijos -> usar sucesor inorden
            print "Eliminando nodo '$valor_actual' (tiene dos hijos).\n";
            print "Buscando sucesor inorden en el subarbol derecho...\n";

            # el sucesor inorden es el MENOR valor en el subarbol derecho
            # (siempre es mayor que el nodo actual, pero el mas pequeno de los mayores)
            my $sucesor        = $self->_encontrar_minimo($nodo_actual->get_right());
            my $valor_sucesor  = $sucesor->get_data();

            print "Sucesor inorden encontrado: '$valor_sucesor'. Reemplazando...\n";

            # copiar el valor del sucesor en el nodo actual
            $nodo_actual->set_data($valor_sucesor);

            # eliminar el sucesor del subarbol derecho (cae en caso 1 o 2)
            $nodo_actual->set_right(
                $self->_eliminar_recursivo($nodo_actual->get_right(), $valor_sucesor)
            );
        }
    }

    # al regresar, rebalancear este nodo (puede haberse desbalanceado con la eliminacion)
    return $self->_balancear($nodo_actual);
}

# ==============================================================================
# SECCION: MINIMO Y MAXIMO
# ==============================================================================

# ------------------------------------------------------------------------------
# _encontrar_minimo($nodo)  [PRIVADO]
# En un BST, el minimo siempre esta en el nodo mas a la IZQUIERDA.
# Baja recursivamente por los hijos izquierdos hasta llegar a uno sin hijo izquierdo.
# Se usa internamente para encontrar el sucesor inorden al eliminar.
# ------------------------------------------------------------------------------
sub _encontrar_minimo {
    my ($self, $nodo) = @_;
    return $nodo unless defined($nodo->get_left());  # caso base: ya no hay mas izquierda
    return $self->_encontrar_minimo($nodo->get_left());  # seguir bajando a la izquierda
}

# ------------------------------------------------------------------------------
# encontrar_minimo()  [PUBLICO]
# Retorna el VALOR del nodo con el dato mas pequeno del arbol.
# ------------------------------------------------------------------------------
sub encontrar_minimo {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "El arbol esta vacio.\n";
        return undef;
    }
    return $self->_encontrar_minimo($self->{root})->get_data();
}

# ------------------------------------------------------------------------------
# encontrar_maximo()  [PUBLICO]
# En un BST, el maximo siempre esta en el nodo mas a la DERECHA.
# Itera hacia la derecha hasta que no haya mas hijo derecho.
# (Version iterativa para variar respecto al minimo que es recursivo)
# ------------------------------------------------------------------------------
sub encontrar_maximo {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "El arbol esta vacio.\n";
        return undef;
    }
    my $nodo = $self->{root};
    while (defined($nodo->get_right())) {
        $nodo = $nodo->get_right();  # avanzar siempre hacia la derecha
    }
    return $nodo->get_data();
}

# ==============================================================================
# SECCION: RECORRIDOS
#
# Un recorrido visita todos los nodos del arbol exactamente una vez.
# El orden en que se visitan define el tipo de recorrido.
# Los tres recorridos clasicos son DFS (Depth-First Search).
# ==============================================================================

# ------------------------------------------------------------------------------
# recorrido_inorden()
# Orden de visita: IZQUIERDA -> RAIZ -> DERECHA
#
# Propiedad especial: en un BST/AVL, el inorden siempre produce los valores
# en orden ASCENDENTE. Es util para verificar que el arbol esta correcto.
# ------------------------------------------------------------------------------
sub recorrido_inorden {
    my ($self) = @_;
    print "Recorrido INORDEN (ascendente): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_inorden_recursivo($self->{root});
    print "\n";
}

sub _inorden_recursivo {
    my ($self, $nodo_actual) = @_;
    return unless defined($nodo_actual);
    $self->_inorden_recursivo($nodo_actual->get_left());   # 1. visitar subarbol izquierdo
    print $nodo_actual->get_data() . " ";                  # 2. procesar raiz (imprimir)
    $self->_inorden_recursivo($nodo_actual->get_right());  # 3. visitar subarbol derecho
}

# ------------------------------------------------------------------------------
# recorrido_preorden()
# Orden de visita: RAIZ -> IZQUIERDA -> DERECHA
#
# Util para copiar/serializar la estructura del arbol,
# ya que al reinsertar en preorden se reconstruye el mismo arbol.
# ------------------------------------------------------------------------------
sub recorrido_preorden {
    my ($self) = @_;
    print "Recorrido PREORDEN (raiz primero): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_preorden_recursivo($self->{root});
    print "\n";
}

sub _preorden_recursivo {
    my ($self, $nodo_actual) = @_;
    return unless defined($nodo_actual);
    print $nodo_actual->get_data() . " ";                   # 1. procesar raiz
    $self->_preorden_recursivo($nodo_actual->get_left());   # 2. visitar izquierda
    $self->_preorden_recursivo($nodo_actual->get_right());  # 3. visitar derecha
}

# ------------------------------------------------------------------------------
# recorrido_postorden()
# Orden de visita: IZQUIERDA -> DERECHA -> RAIZ
#
# Util cuando necesitamos procesar los hijos antes que el padre,
# por ejemplo al liberar memoria (eliminar el arbol completo).
# ------------------------------------------------------------------------------
sub recorrido_postorden {
    my ($self) = @_;
    print "Recorrido POSTORDEN (raiz al final): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_postorden_recursivo($self->{root});
    print "\n";
}

sub _postorden_recursivo {
    my ($self, $nodo_actual) = @_;
    return unless defined($nodo_actual);
    $self->_postorden_recursivo($nodo_actual->get_left());   # 1. visitar izquierda
    $self->_postorden_recursivo($nodo_actual->get_right());  # 2. visitar derecha
    print $nodo_actual->get_data() . " ";                    # 3. procesar raiz
}

# ==============================================================================
# SECCION: IMPRESION EN CONSOLA
# ==============================================================================

# ------------------------------------------------------------------------------
# imprimir_arbol()
# Muestra el arbol de forma visual en la consola usando indentacion.
# Cada nivel de profundidad agrega 4 espacios de sangria.
#
# El truco es usar un recorrido "der -> raiz -> izq" con niveles:
# al girarlo 90 grados a la izquierda, la salida en pantalla
# se lee como el arbol visto de arriba hacia abajo.
#
# Cada nodo muestra: [valor | h=altura | bf=factor_de_balance]
# ------------------------------------------------------------------------------
sub imprimir_arbol {
    my ($self) = @_;
    print "\n=== Estructura del Arbol AVL ===\n";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
    } else {
        $self->_imprimir_recursivo($self->{root}, 0);  # nivel 0 = raiz
    }
    print "================================\n\n";
}

sub _imprimir_recursivo {
    my ($self, $nodo, $nivel) = @_;
    return unless defined($nodo);

    # primero imprimir la parte derecha (aparece arriba en la pantalla)
    $self->_imprimir_recursivo($nodo->get_right(), $nivel + 1);

    # calcular indentacion: 4 espacios por nivel de profundidad
    my $indentacion = "    " x $nivel;
    my $balance     = $self->_get_balance($nodo);

    # imprimir el nodo con su valor, altura y factor de balance
    print $indentacion . "[" . $nodo->get_data() . " | h=" . $nodo->get_height() . " | bf=" . $balance . "]\n";

    # luego imprimir la parte izquierda (aparece abajo en la pantalla)
    $self->_imprimir_recursivo($nodo->get_left(), $nivel + 1);
}

1;  # fin del modulo: valor verdadero requerido por Perl
