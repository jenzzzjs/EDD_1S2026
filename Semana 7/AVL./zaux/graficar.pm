# ==============================================================================
# PAQUETE: avl::graficar
# PROPOSITO: Genera una representacion visual del arbol AVL usando Graphviz.
#
# QUE ES GRAPHVIZ?
#   Es una herramienta de codigo abierto para visualizar grafos.
#   Recibe un archivo de texto en formato DOT y genera una imagen (PNG, SVG, etc.).
#
# FLUJO DE TRABAJO:
#   1. Este modulo genera un archivo .dot (texto con la descripcion del grafo)
#   2. Llama al programa externo "dot" (parte de Graphviz) para convertirlo a PNG
#   3. El PNG queda en la carpeta reportes/
#
# FORMATO DOT:
#   digraph AVL {          <- grafo dirigido llamado AVL
#       node [...]         <- estilo por defecto para todos los nodos
#       n20 [label="..."]  <- declaracion de un nodo
#       n20 -> n10         <- arista de n20 a n10 (flecha)
#   }
#
# COLORES DE LOS NODOS:
#   Verde  (#A5D6A7) -> bf =  0, perfectamente balanceado
#   Amarillo(#FFF59D)-> bf = +/-1, ligeramente desbalanceado (pero valido en AVL)
#   Rojo   (#EF9A9A) -> bf = +/-2 o mas, DESBALANCEADO (no deberia ocurrir en AVL)
# ==============================================================================
package avl::graficar;

use strict;
use warnings;

use avl::avl;  # necesitamos acceso al arbol para recorrerlo

# ------------------------------------------------------------------------------
# METODO: graficar($class, $arbol, $basename)
#
# Parametros:
#   $class    -> nombre del paquete (Perl OO orientado a clase)
#   $arbol    -> instancia del arbol AVL que se va a graficar
#   $basename -> nombre base del archivo (sin extension), ej: "mi_arbol_avl"
#
# Genera:
#   reportes/$basename.dot  <- descripcion textual del grafo
#   reportes/$basename.png  <- imagen visual del arbol
# ------------------------------------------------------------------------------
sub graficar {
    my ($class, $arbol, $basename) = @_;

    my $dot_file = "reportes/$basename.dot";  # ruta del archivo DOT a crear
    my $png_file = "reportes/$basename.png";  # ruta de la imagen de salida

    # crear la carpeta reportes/ si aun no existe
    # "2>nul" redirige los errores a null en Windows (equivale a 2>/dev/null en Linux)
    system("mkdir reportes 2>nul") unless -d "reportes";

    # abrir el archivo DOT en modo escritura ('>')
    # si falla (disco lleno, permisos, etc.) die detiene el programa con el mensaje
    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    # --- ENCABEZADO DEL ARCHIVO DOT ---
    print $fh "digraph AVL {\n";        # grafo dirigido (flechas)
    print $fh "    rankdir=TB;\n";      # TB = Top to Bottom (raiz arriba, hojas abajo)
    print $fh "    node [\n";
    print $fh "        shape=record,\n";    # shape=record permite etiquetas con secciones '{}'
    print $fh "        style=filled,\n";    # activar relleno de color
    print $fh "        fontname=\"Arial\"\n";
    print $fh "    ];\n\n";

    if ($arbol->is_empty()) {
        # arbol vacio: mostrar un nodo especial de aviso
        print $fh "    empty [label=\"ARBOL VACIO\", shape=box];\n";
    } else {
        # generar las declaraciones de nodos (con estilo y etiqueta)
        $class->_generar_nodos($fh, $arbol->{root}, $arbol);
        # generar las aristas (flechas entre nodos padre e hijo)
        $class->_generar_aristas($fh, $arbol->{root});
    }

    print $fh "}\n";  # cerrar el bloque digraph
    close($fh);       # cerrar el archivo para asegurar que se escriba al disco

    # --- LLAMAR A GRAPHVIZ PARA CONVERTIR DOT -> PNG ---
    # backticks `` en Perl ejecutan el comando y capturan su salida estandar
    # "2>&1" redirige stderr a stdout para capturar tambien los errores
    my $command = "dot -Tpng \"$dot_file\" -o \"$png_file\" 2>&1";
    my $output  = `$command`;

    # $? contiene el codigo de salida del ultimo proceso externo
    # se hace >> 8 para obtener el byte alto (codigo de salida real en Unix/Windows)
    my $exit    = $? >> 8;

    if ($exit == 0) {
        print "Imagen generada correctamente: $png_file\n";
        return 1;  # exito
    } else {
        print "Error al generar imagen.\n$output\n";
        return 0;  # fallo
    }
}

# ------------------------------------------------------------------------------
# _get_balance($class, $arbol, $nodo)
# Calcula el factor de balance de un nodo para colorear el grafico.
# bf = altura(hijo_izq) - altura(hijo_der)
# (replica la logica de avl.pm para no depender de su implementacion interna)
# ------------------------------------------------------------------------------
sub _get_balance {
    my ($class, $arbol, $nodo) = @_;
    return 0 unless defined($nodo);
    my $h_izq = defined($nodo->get_left())  ? $nodo->get_left()->get_height()  : 0;
    my $h_der = defined($nodo->get_right()) ? $nodo->get_right()->get_height() : 0;
    return $h_izq - $h_der;
}

# ------------------------------------------------------------------------------
# _fill_color($class, $balance)
# Retorna el color HEX del nodo segun su factor de balance:
#   Verde    -> bf =  0  (balanceado perfecto)
#   Amarillo -> bf = +-1 (balanceado valido en AVL)
#   Rojo     -> bf = +-2 (desbalanceado, no deberia pasar en AVL correcto)
# ------------------------------------------------------------------------------
sub _fill_color {
    my ($class, $balance) = @_;
    return "#EF9A9A" if abs($balance) > 1;   # rojo: desbalanceado
    return "#FFF59D" if abs($balance) == 1;  # amarillo: ligeramente inclinado
    return "#A5D6A7";                         # verde: perfectamente balanceado
}

# ------------------------------------------------------------------------------
# _generar_nodos($class, $fh, $nodo, $arbol)
# Recorre el arbol en preorden y escribe en el archivo DOT la declaracion
# de cada nodo con su etiqueta y color de fondo.
#
# La etiqueta usa formato "record" de Graphviz: {valor | h=altura | bf=balance}
# Las llaves {} dividen la caja del nodo en secciones visuales
# ------------------------------------------------------------------------------
sub _generar_nodos {
    my ($class, $fh, $nodo, $arbol) = @_;

    return unless defined($nodo);  # caso base: sin nodo, nada que hacer

    my $valor   = $nodo->get_data();
    my $altura  = $nodo->get_height();
    my $balance = $class->_get_balance($arbol, $nodo);
    my $id      = "n$valor";  # ID unico del nodo en DOT (nodos DOT no pueden empezar con numero)
    my $color   = $class->_fill_color($balance);

    # escribir la linea DOT: id [atributos]
    # la etiqueta usa '{' '}' para separar secciones en shape=record
    print $fh "    $id [label=\"{$valor | h=$altura | bf=$balance}\", fillcolor=\"$color\"];\n";

    # recorrer recursivamente los hijos
    $class->_generar_nodos($fh, $nodo->get_left(),  $arbol);
    $class->_generar_nodos($fh, $nodo->get_right(), $arbol);
}

# ------------------------------------------------------------------------------
# _generar_aristas($class, $fh, $nodo)
# Recorre el arbol y escribe en el archivo DOT las aristas (flechas)
# entre cada nodo padre y sus hijos.
#
# La etiqueta "L" o "R" en la flecha indica si el hijo es izquierdo o derecho.
# Esto hace que el grafico sea mas informativo y facil de leer.
# ------------------------------------------------------------------------------
sub _generar_aristas {
    my ($class, $fh, $nodo) = @_;

    return unless defined($nodo);  # caso base

    my $valor_padre = $nodo->get_data();
    my $id_padre    = "n$valor_padre";

    if (defined($nodo->get_left())) {
        my $valor_izq = $nodo->get_left()->get_data();
        my $id_izq    = "n$valor_izq";
        print $fh "    $id_padre -> $id_izq [label=\"L\"];\n";  # flecha con etiqueta "L"
        $class->_generar_aristas($fh, $nodo->get_left());  # continuar con el subarbol izquierdo
    }

    if (defined($nodo->get_right())) {
        my $valor_der = $nodo->get_right()->get_data();
        my $id_der    = "n$valor_der";
        print $fh "    $id_padre -> $id_der [label=\"R\"];\n";  # flecha con etiqueta "R"
        $class->_generar_aristas($fh, $nodo->get_right());  # continuar con el subarbol derecho
    }
}

1;  # valor verdadero requerido al final de todo modulo Perl
