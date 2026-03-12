# ==============================================================================
# PAQUETE: avl::nodo
# PROPOSITO: Representa un nodo individual dentro del arbol AVL.
#
# Un nodo AVL es diferente a un nodo BST normal porque ademas de guardar
# el dato, izquierdo y derecho, tambien guarda su ALTURA dentro del arbol.
# La altura es lo que le permite al arbol AVL detectar y corregir desbalances.
# ==============================================================================
package avl::nodo;

use strict;    # obliga a declarar variables con my/our, evita errores silenciosos
use warnings;  # activa mensajes de advertencia en tiempo de ejecucion

# ------------------------------------------------------------------------------
# CONSTRUCTOR: new($class, $data)
#
# En Perl orientado a objetos:
#   - $class recibe el nombre del paquete ("avl::nodo")
#   - Se crea un hash anonimo $self con los campos del nodo
#   - bless($self, $class) convierte el hash en un objeto del paquete
#
# Campos del nodo:
#   data   -> el valor almacenado (numero entero en esta implementacion)
#   left   -> referencia al nodo hijo IZQUIERDO (undef si no tiene)
#   right  -> referencia al nodo hijo DERECHO   (undef si no tiene)
#   height -> altura del nodo dentro del arbol
#             Un nodo recien creado siempre tiene altura 1 (es una hoja)
# ------------------------------------------------------------------------------
sub new {
    my ($class, $data) = @_;

    my $self = {
        data   => $data,   # valor del nodo
        left   => undef,   # hijo izquierdo: inicialmente vacio
        right  => undef,   # hijo derecho:   inicialmente vacio
        height => 1,       # altura inicial = 1 (nodo hoja, sin hijos)
    };

    bless $self, $class;  # convierte el hash en objeto de tipo avl::nodo
    return $self;
}

# ------------------------------------------------------------------------------
# GETTER: get_data()
# Retorna el valor almacenado en el nodo.
# $_[0] es una forma compacta de escribir $self (primer argumento de la funcion)
# ------------------------------------------------------------------------------
sub get_data {
    return $_[0]->{data};
}

# ------------------------------------------------------------------------------
# SETTER: set_data($new_data)
# Cambia el valor del nodo. Se usa al eliminar un nodo con dos hijos:
# en vez de reestructurar punteros, se reemplaza el dato por el del sucesor.
# ------------------------------------------------------------------------------
sub set_data {
    my ($self, $new_data) = @_;
    $self->{data} = $new_data;
}

# ------------------------------------------------------------------------------
# GETTER: get_left()
# Retorna la referencia al hijo izquierdo (o undef si no existe).
# ------------------------------------------------------------------------------
sub get_left {
    return $_[0]->{left};
}

# ------------------------------------------------------------------------------
# SETTER: set_left($nodo_izq)
# Asigna el hijo izquierdo. Se llama cuando:
#   - Se inserta un nuevo nodo a la izquierda
#   - Se realiza una rotacion y cambian los enlaces
#   - Se elimina un nodo y hay que reconectar subarboles
# ------------------------------------------------------------------------------
sub set_left {
    my ($self, $nodo_izq) = @_;
    $self->{left} = $nodo_izq;
}

# ------------------------------------------------------------------------------
# GETTER: get_right()
# Retorna la referencia al hijo derecho (o undef si no existe).
# ------------------------------------------------------------------------------
sub get_right {
    return $_[0]->{right};
}

# ------------------------------------------------------------------------------
# SETTER: set_right($nodo_der)
# Asigna el hijo derecho. Mismos casos de uso que set_left.
# ------------------------------------------------------------------------------
sub set_right {
    my ($self, $nodo_der) = @_;
    $self->{right} = $nodo_der;
}

# ------------------------------------------------------------------------------
# GETTER: get_height()
# Retorna la altura actual del nodo.
#
# La ALTURA de un nodo se define como:
#   - 1 si el nodo es hoja (sin hijos)
#   - 1 + max(altura_izquierda, altura_derecha) si tiene hijos
#
# Esta propiedad se recalcula despues de cada insercion o eliminacion.
# ------------------------------------------------------------------------------
sub get_height {
    return $_[0]->{height};
}

# ------------------------------------------------------------------------------
# SETTER: set_height($h)
# Actualiza la altura del nodo. Es llamado por _update_height() en avl.pm
# despues de cualquier operacion que modifique la estructura del arbol.
# ------------------------------------------------------------------------------
sub set_height {
    my ($self, $h) = @_;
    $self->{height} = $h;
}

# ------------------------------------------------------------------------------
# METODO: es_hoja()
# Retorna 1 (verdadero) si el nodo NO tiene hijos, 0 (falso) si tiene al menos uno.
#
# Un nodo hoja es el caso mas simple de eliminacion: solo se desconecta.
# Condicion: ambos punteros (left Y right) deben ser undef.
# ------------------------------------------------------------------------------
sub es_hoja {
    my ($self) = @_;
    return (!defined($self->{left}) && !defined($self->{right})) ? 1 : 0;
}

# ------------------------------------------------------------------------------
# METODO: to_string()
# Genera una cadena descriptiva del nodo para mostrar en consola.
# Se usa principalmente en buscar() para imprimir el resultado encontrado.
# ------------------------------------------------------------------------------
sub to_string {
    my ($self) = @_;
    my $data      = $self->{data};
    my $tiene_izq = defined($self->{left})  ? "Si" : "No";  # verifica si hay hijo izq
    my $tiene_der = defined($self->{right}) ? "Si" : "No";  # verifica si hay hijo der
    return "Nodo[data=$data, altura=$self->{height}, hijo_izq=$tiene_izq, hijo_der=$tiene_der]\n";
}

# ------------------------------------------------------------------------------
# METODO: imprimir_nodo()
# Imprime en pantalla todos los campos del nodo de forma legible.
# Util para depuracion.
# ------------------------------------------------------------------------------
sub imprimir_nodo {
    my ($self) = @_;
    print "Dato:   $self->{data}\n";
    print "Altura: $self->{height}\n";
    print "Hijo izquierdo: " . (defined($self->{left})  ? "Si" : "No") . "\n";
    print "Hijo derecho:   " . (defined($self->{right}) ? "Si" : "No") . "\n\n";
}

1;  # Perl exige que los modulos terminen con un valor verdadero; 1 es la convencion
