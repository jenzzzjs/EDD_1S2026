#!/usr/bin/perl
# ==============================================================================
# ARCHIVO: main.pl  (version comentada en zaux/)
# PROPOSITO: Demostracion completa del Arbol AVL con explicaciones paso a paso.
#
# NOTA: Este archivo esta pensado para APRENDIZAJE.
#       La version de produccion (sin comentarios) esta en Semana7/main.pl
#
# PARA EJECUTAR (desde la carpeta Semana7/):
#   perl main.pl
# ==============================================================================

use strict;
use warnings;

# "use lib '.'" le dice a Perl que busque modulos en el directorio actual.
# Sin esto, "use avl::avl" fallaria porque Perl no encontraria el archivo AVL/avl.pm.
use lib '.';

# Importar los dos modulos que usaremos en este script.
# Perl busca avl/avl.pm y avl/graficar.pm dentro de los directorios en @INC.
use avl::avl;
use avl::graficar;

print "=" x 60 . "\n";
print "  DEMOSTRACION: Arbol AVL (Adelson-Velsky y Landis)\n";
print "=" x 60 . "\n\n";

# ------------------------------------------------------------------------------
# CREACION DEL ARBOL
# avl::avl->new() llama al constructor del paquete avl::avl.
# Retorna un objeto (referencia a hash bendecido) almacenado en $arbol.
# Al crearse, el arbol esta vacio: root=undef, size=0.
# ------------------------------------------------------------------------------
my $arbol = avl::avl->new();
print "Arbol creado. Esta vacio? " . ($arbol->is_empty() ? "Si" : "No") . "\n\n";

# ==============================================================================
# BLOQUE 1: INSERCION
# Se insertan valores que intencionalmente provocan los 4 tipos de rotacion.
# Observa los mensajes de consola para entender que rotacion se aplica.
# ==============================================================================
print "-" x 60 . "\n";
print "INSERTANDO VALORES (observar rotaciones automaticas):\n";
print "-" x 60 . "\n";

# La secuencia 10, 20, 30, 50, 40, 5, 1, 25 fue elegida para demostrar los 4 casos:
#
#   10, 20, 30   -> Caso RR: se insertan en orden creciente hacia la derecha
#                  el nodo 10 queda con bf=-2 (dos niveles mas a la derecha)
#                  SOLUCION: rotacion simple IZQUIERDA en el nodo 10
#
#   50, 40       -> Caso RL: 40 se inserta a la izquierda del hijo derecho (50)
#                  el nodo 30 queda con un desbalance tipo RL
#                  SOLUCION: rotar 50 a la derecha, luego 30 a la izquierda
#
#   5, 1         -> Caso LL: se insertan en orden decreciente hacia la izquierda
#                  el nodo 10 queda con bf=+2 (dos niveles mas a la izquierda)
#                  SOLUCION: rotacion simple DERECHA en el nodo 10
#
#   25           -> Caso LR: 25 se inserta a la derecha del hijo izquierdo
#                  SOLUCION: rotar hijo izquierdo a la izquierda, luego rotar nodo a la derecha

foreach my $val (10, 20, 30, 50, 40, 5, 1, 25) {
    print "\n>> Insertando $val:\n";
    $arbol->insertar($val);
    # cada llamada a insertar() internamente:
    # 1. busca la posicion correcta (reglas BST)
    # 2. crea el nuevo nodo
    # 3. al regresar la recursion, recalcula alturas
    # 4. si hay desbalance, aplica la rotacion correspondiente
}

print "\nTamano del arbol: " . $arbol->get_size() . " nodos\n";

# ==============================================================================
# BLOQUE 2: INTENTO DE DUPLICADO
# El AVL (como el BST) no permite valores repetidos.
# El metodo insertar detecta esto y muestra una advertencia sin modificar el arbol.
# ==============================================================================
print "\n" . "-" x 60 . "\n";
print "INTENTANDO INSERTAR DUPLICADO (20):\n";
print "-" x 60 . "\n";
$arbol->insertar(20);  # ya existe, no hace nada, solo avisa

# ==============================================================================
# BLOQUE 3: ESTRUCTURA VISUAL EN CONSOLA
# imprimir_arbol() muestra el arbol rotado 90 grados a la izquierda.
# La raiz aparece al extremo izquierdo, las hojas al extremo derecho.
# Cada nodo muestra: [valor | h=altura | bf=factor_de_balance]
#
# LECTURA: para leerlo como arbol normal (raiz arriba), 
# gira la pantalla 90 grados en sentido antihorario.
# ==============================================================================
print "\n" . "-" x 60 . "\n";
print "ESTRUCTURA ACTUAL DEL ARBOL:\n";
print "-" x 60 . "\n";
print "(cada nodo muestra: [valor | h=altura | bf=factor_de_balance])\n";
$arbol->imprimir_arbol();

# ==============================================================================
# BLOQUE 4: RECORRIDOS
# Los tres recorridos DFS clasicos.
# El inorden deberia mostrar todos los valores en orden ascendente,
# lo que sirve como verificacion de que el arbol AVL mantiene la propiedad BST.
# ==============================================================================
print "-" x 60 . "\n";
print "RECORRIDOS:\n";
print "-" x 60 . "\n";
$arbol->recorrido_inorden();    # izq -> raiz -> der  (orden ascendente)
$arbol->recorrido_preorden();   # raiz -> izq -> der  (util para copiar el arbol)
$arbol->recorrido_postorden();  # izq -> der -> raiz  (util para borrar el arbol)

# ==============================================================================
# BLOQUE 5: BUSQUEDA
# buscar() retorna el NODO que contiene el valor (o undef si no existe).
# Se retorna el nodo y no solo el valor para poder acceder a sus metodos (to_string).
# Complejidad: O(log n) gracias al balance del AVL.
# ==============================================================================
print "\n" . "-" x 60 . "\n";
print "BUSQUEDA:\n";
print "-" x 60 . "\n";

my $encontrado = $arbol->buscar(40);
# el operador ? : es el operador ternario: condicion ? valor_si_true : valor_si_false
print "Buscar 40: " . (defined($encontrado) ? "ENCONTRADO -> " . $encontrado->to_string() : "NO encontrado\n");

my $no_existe = $arbol->buscar(99);
print "Buscar 99: " . (defined($no_existe) ? "ENCONTRADO\n" : "NO encontrado\n");

# ==============================================================================
# BLOQUE 6: MINIMO Y MAXIMO
# En un BST/AVL:
#   - El MINIMO siempre esta en el extremo MAS A LA IZQUIERDA
#   - El MAXIMO siempre esta en el extremo MAS A LA DERECHA
# Ambos son O(log n) en un arbol balanceado.
# ==============================================================================
print "\n" . "-" x 60 . "\n";
print "MINIMO Y MAXIMO:\n";
print "-" x 60 . "\n";
print "Valor minimo: " . $arbol->encontrar_minimo() . "\n";
print "Valor maximo: " . $arbol->encontrar_maximo() . "\n";

# ==============================================================================
# BLOQUE 7: ELIMINACION
# La eliminacion en AVL tiene tres sub-casos (heredados del BST):
#   CASO 1 - Hoja:          simplemente se desconecta
#   CASO 2 - Un hijo:       el hijo sube a ocupar el lugar del eliminado
#   CASO 3 - Dos hijos:     se busca el sucesor inorden (menor del subarbol der),
#                           se copia su valor y se elimina a el en su lugar
#
# Despues de eliminar, al regresar la recursion se rebalancea el camino completo.
# Pueden ocurrir MULTIPLES rotaciones en una sola eliminacion.
# ==============================================================================
print "\n" . "-" x 60 . "\n";
print "ELIMINANDO NODOS (observar rebalanceo):\n";
print "-" x 60 . "\n";

print "\n>> Eliminando 10:\n";
$arbol->eliminar(10);  # caso 1: 10 es hoja (no tiene hijos)
print "\nEstructura tras eliminar 10:\n";
$arbol->imprimir_arbol();

print ">> Eliminando 50:\n";
$arbol->eliminar(50);  # puede causar rotacion al subir hacia la raiz
print "\nEstructura tras eliminar 50:\n";
$arbol->imprimir_arbol();

print ">> Intentando eliminar valor inexistente (99):\n";
$arbol->eliminar(99);  # avisa que no existe, no modifica el arbol

# ==============================================================================
# BLOQUE 8: ESTADO FINAL
# ==============================================================================
print "-" x 60 . "\n";
print "RECORRIDO FINAL:\n";
print "-" x 60 . "\n";
print "Tamano final: " . $arbol->get_size() . " nodos\n";
$arbol->recorrido_inorden();  # verificar que sigue ordenado despues de las eliminaciones

# ==============================================================================
# BLOQUE 9: GENERACION DE IMAGEN CON GRAPHVIZ
# graficar() genera dos archivos en reportes/:
#   mi_arbol_avl.dot -> descripcion textual del grafo (puedes abrirlo con un editor)
#   mi_arbol_avl.png -> imagen visual del arbol (abrir con cualquier visor de imagenes)
#
# REQUISITO: Graphviz instalado y "dot" disponible en el PATH del sistema.
# Descargar en: https://graphviz.org/download/
# ==============================================================================
print "\n" . "-" x 60 . "\n";
print "GENERANDO IMAGEN CON GRAPHVIZ:\n";
print "-" x 60 . "\n";
avl::graficar->graficar($arbol, "mi_arbol_avl");
# la imagen PNG mostrara cada nodo con:
#   - su valor, altura y factor de balance en la etiqueta
#   - color verde (bf=0), amarillo (bf=+-1) o rojo (bf=+-2) segun el balance
#   - flechas etiquetadas con "L" (izquierdo) o "R" (derecho)

print "\n" . "=" x 60 . "\n";
print "  FIN DE LA DEMOSTRACION\n";
print "=" x 60 . "\n";
