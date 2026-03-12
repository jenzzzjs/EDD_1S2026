use strict;
use warnings;
use feature 'say';
use File::Temp qw(tempfile);
use File::Spec;

# Definicion de la clase avion
package Avion;
sub new {
    my ($class, %args) = @_;
    my $self = {
    # manejamos los distintos atributos utilizados para la clase avion
        vuelo            => $args{vuelo}            // '',
        numero_registro  => $args{numero_registro}  // '',
        modelo           => $args{modelo}           // '',
        capacidad        => $args{capacidad}        // 0,
        aerolinea        => $args{aerolinea}        // '',
        ciudad_destino   => $args{ciudad_destino}   // '',
        estado           => $args{estado}           // '',
    };
    bless $self, $class;
    return $self;
}

sub get_numero_registro { return shift->{numero_registro}; }
sub get_vuelo { return shift->{vuelo}; }
sub get_ciudad_destino { return shift->{ciudad_destino}; }
sub get_estado { return shift->{estado}; }
sub set_estado { my ($self, $estado) = @_; $self->{estado} = $estado; }

sub imprimir {
    my $self = shift;
    printf "Vuelo: %s, Número de Registro: %s, Estado: %s\n",
           $self->{vuelo}, $self->{numero_registro}, $self->{estado};
}

sub to_string {
    my $self = shift;
    return sprintf("%s|%s|%s|%d|%s|%s|%s",
        $self->{vuelo}, $self->{numero_registro}, $self->{modelo},
        $self->{capacidad}, $self->{aerolinea}, $self->{ciudad_destino},
        $self->{estado});
}

sub from_string {
    my ($class, $str) = @_;
    my @parts = split /\|/, $str;
    return Avion->new(
        vuelo           => $parts[0],
        numero_registro => $parts[1],
        modelo          => $parts[2],
        capacidad       => $parts[3],
        aerolinea       => $parts[4],
        ciudad_destino  => $parts[5],
        estado          => $parts[6]
    );
}

# ============================================================================
# CLASE NODO DEL ÁRBOL B (ORDEN 4)
# ============================================================================
package BNode;
use constant ORDEN => 4;
use constant MIN_CLAVES => 1;  # Para orden 4, el mínimo es 1

sub new {
    my $class = shift;
    my $self = {
        claves     => [],      # Array de objetos Avion
        hijos      => [],      # Array de referencias a nodos hijos
        padre      => undef,   # Referencia al nodo padre
        hoja       => 1,       # 1 si es hoja, 0 si es interno
    };
    bless $self, $class;
    return $self;
}

# Métodos de acceso
sub es_hoja { return shift->{hoja}; }
sub set_hoja { my ($self, $valor) = @_; $self->{hoja} = $valor; }
sub get_claves { return shift->{claves}; }
sub get_hijos { return shift->{hijos}; }
sub get_padre { return shift->{padre}; }
sub set_padre { my ($self, $padre) = @_; $self->{padre} = $padre; }

sub num_claves { return scalar @{shift->{claves}}; }
sub num_hijos { return scalar @{shift->{hijos}}; }

sub esta_lleno {
    my $self = shift;
    return $self->num_claves() >= (ORDEN - 1);
}

sub tiene_minimo {
    my $self = shift;
    return $self->num_claves() >= MIN_CLAVES;
}

# Encontrar posición para insertar una clave
sub encontrar_posicion_insertar {
    my ($self, $numero_registro) = @_;
    my $claves = $self->{claves};
    my $i = 0;
    while ($i < @$claves && $claves->[$i]->get_numero_registro() lt $numero_registro) {
        $i++;
    }
    return $i;
}

# Buscar una clave en el nodo
sub buscar_clave {
    my ($self, $numero_registro) = @_;
    my $claves = $self->{claves};
    my $i = 0;
    while ($i < @$claves && $claves->[$i]->get_numero_registro() lt $numero_registro) {
        $i++;
    }
    return $i;
}

# Insertar clave en el nodo (asume que no está lleno)
sub insertar_clave {
    my ($self, $avion) = @_;
    my $numero_registro = $avion->get_numero_registro();
    my $pos = $self->encontrar_posicion_insertar($numero_registro);
    
    splice(@{$self->{claves}}, $pos, 0, $avion);
    return 1;
}

# Dividir nodo cuando está lleno
sub dividir {
    my ($self) = @_;
    
    my $mid = int($self->num_claves() / 2);
    my $mediana = $self->{claves}->[$mid];
    
    my $nuevo_nodo = BNode->new();
    $nuevo_nodo->set_hoja($self->{hoja});
    
    # Mover claves superiores al nuevo nodo
    for (my $i = $mid + 1; $i < $self->num_claves(); $i++) {
        push @{$nuevo_nodo->{claves}}, $self->{claves}->[$i];
    }
    
    # Si no es hoja, mover también los hijos correspondientes
    if (!$self->{hoja}) {
        for (my $i = $mid + 1; $i <= $self->num_hijos(); $i++) {
            push @{$nuevo_nodo->{hijos}}, $self->{hijos}->[$i];
            if (defined $self->{hijos}->[$i]) {
                $self->{hijos}->[$i]->set_padre($nuevo_nodo);
            }
        }
        splice(@{$self->{hijos}}, $mid + 1);
    }
    
    # Eliminar claves movidas del nodo original
    splice(@{$self->{claves}}, $mid);
    
    return ($nuevo_nodo, $mediana);
}

# ============================================================================
# MÉTODOS PARA ELIMINACIÓN EN NODO
# ============================================================================

# Encontrar el predecesor (máximo del subárbol izquierdo)
sub obtener_predecesor {
    my ($self, $idx) = @_;
    my $actual = $self->{hijos}->[$idx];
    while (!$actual->es_hoja()) {
        $actual = $actual->{hijos}->[-1];
    }
    return $actual->{claves}->[-1];
}

# Encontrar el sucesor (mínimo del subárbol derecho)
sub obtener_sucesor {
    my ($self, $idx) = @_;
    my $actual = $self->{hijos}->[$idx + 1];
    while (!$actual->es_hoja()) {
        $actual = $actual->{hijos}->[0];
    }
    return $actual->{claves}->[0];
}

# Tomar prestado del hermano izquierdo
sub tomar_prestado_izquierdo {
    my ($self, $idx) = @_;
    my $hijo = $self->{hijos}->[$idx];
    my $hermano = $self->{hijos}->[$idx - 1];
    
    # Mover todas las claves del hijo una posición a la derecha
    unshift @{$hijo->{claves}}, $self->{claves}->[$idx - 1];
    
    # Si no es hoja, mover el último hijo del hermano al principio del hijo
    if (!$hijo->es_hoja()) {
        unshift @{$hijo->{hijos}}, pop @{$hermano->{hijos}};
        if (defined $hijo->{hijos}->[0]) {
            $hijo->{hijos}->[0]->set_padre($hijo);
        }
    }
    
    # La clave del padre ahora es la última clave del hermano
    $self->{claves}->[$idx - 1] = pop @{$hermano->{claves}};
}

# Tomar prestado del hermano derecho
sub tomar_prestado_derecho {
    my ($self, $idx) = @_;
    my $hijo = $self->{hijos}->[$idx];
    my $hermano = $self->{hijos}->[$idx + 1];
    
    # Añadir clave del padre al final del hijo
    push @{$hijo->{claves}}, $self->{claves}->[$idx];
    
    # Si no es hoja, mover el primer hijo del hermano al final del hijo
    if (!$hijo->es_hoja()) {
        push @{$hijo->{hijos}}, shift @{$hermano->{hijos}};
        if (defined $hijo->{hijos}->[-1]) {
            $hijo->{hijos}->[-1]->set_padre($hijo);
        }
    }
    
    # La clave del padre ahora es la primera clave del hermano
    $self->{claves}->[$idx] = shift @{$hermano->{claves}};
}

# Fusionar hijo con hermano derecho
sub fusionar {
    my ($self, $idx) = @_;
    my $hijo = $self->{hijos}->[$idx];
    my $hermano = $self->{hijos}->[$idx + 1];
    
    # Añadir la clave del padre al hijo
    push @{$hijo->{claves}}, $self->{claves}->[$idx];
    
    # Añadir todas las claves del hermano
    push @{$hijo->{claves}}, @{$hermano->{claves}};
    
    # Si no son hojas, añadir todos los hijos del hermano
    if (!$hijo->es_hoja()) {
        push @{$hijo->{hijos}}, @{$hermano->{hijos}};
        foreach my $hijo_hermano (@{$hermano->{hijos}}) {
            if (defined $hijo_hermano) {
                $hijo_hermano->set_padre($hijo);
            }
        }
    }
    
    # Eliminar la clave del padre y el puntero al hermano
    splice(@{$self->{claves}}, $idx, 1);
    splice(@{$self->{hijos}}, $idx + 1, 1);
}

# Eliminar clave de nodo hoja
sub eliminar_clave_hoja {
    my ($self, $idx) = @_;
    splice(@{$self->{claves}}, $idx, 1);
    return 1;
}

# Eliminar clave de nodo interno - VERSIÓN CORREGIDA
sub eliminar_clave_interna {
    my ($self, $idx) = @_;
    
    # Caso 1: El hijo izquierdo tiene suficientes claves (> mínimo)
    if ($self->{hijos}->[$idx]->num_claves() > MIN_CLAVES) {
        # Obtener el predecesor (máximo del subárbol izquierdo)
        my $predecesor = $self->obtener_predecesor($idx);
        # Reemplazar la clave actual con el predecesor
        $self->{claves}->[$idx] = $predecesor;
        # Eliminar el predecesor del subárbol izquierdo
        return $self->{hijos}->[$idx]->eliminar_clave($predecesor->get_numero_registro());
    }
    # Caso 2: El hijo derecho tiene suficientes claves (> mínimo)
    elsif ($self->{hijos}->[$idx + 1]->num_claves() > MIN_CLAVES) {
        # Obtener el sucesor (mínimo del subárbol derecho)
        my $sucesor = $self->obtener_sucesor($idx);
        # Reemplazar la clave actual con el sucesor
        $self->{claves}->[$idx] = $sucesor;
        # Eliminar el sucesor del subárbol derecho
        return $self->{hijos}->[$idx + 1]->eliminar_clave($sucesor->get_numero_registro());
    }
    # Caso 3: Ambos hijos tienen mínimo de claves, hay que fusionar
    else {
        # Fusionar el hijo izquierdo con el derecho
        $self->fusionar($idx);
        # Después de fusionar, la clave a eliminar está en el hijo fusionado
        # Llamar recursivamente para eliminar la clave del hijo fusionado
        return $self->{hijos}->[$idx]->eliminar_clave($self->{claves}->[$idx]->get_numero_registro());
    }
}

# Método principal de eliminación en el nodo
sub eliminar_clave {
    my ($self, $numero_registro) = @_;
    
    my $idx = $self->buscar_clave($numero_registro);
    
    # CASO 1: La clave está en este nodo
    if ($idx < $self->num_claves() && 
        $self->{claves}->[$idx]->get_numero_registro() eq $numero_registro) {
        
        if ($self->es_hoja()) {
            # Si es hoja, simplemente eliminar
            return $self->eliminar_clave_hoja($idx);
        }
        else {
            # Si es nodo interno, usar el método especial
            return $self->eliminar_clave_interna($idx);
        }
    }
    
    # CASO 2: La clave no está en este nodo (debe estar en un subárbol)
    if ($self->es_hoja()) {
        return 0;  # Clave no encontrada
    }
    
    # Determinar en qué hijo podría estar la clave
    my $hijo_idx = $idx;
    my $ultimo_hijo = ($idx == $self->num_claves());
    
    # Verificar si el hijo tiene el mínimo de claves y necesita rebalanceo
    if (!$self->{hijos}->[$hijo_idx]->tiene_minimo()) {
        $self->rebalancear($hijo_idx);
        # Ajustar índice si se realizó una fusión
        if ($ultimo_hijo && $hijo_idx > $self->num_claves()) {
            $hijo_idx--;
        }
        elsif (!$ultimo_hijo && $hijo_idx < $idx) {
            $hijo_idx = $idx - 1;
        }
    }
    
    # Continuar la eliminación en el hijo apropiado
    return $self->{hijos}->[$hijo_idx]->eliminar_clave($numero_registro);
}

# Rebalancear un hijo que no tiene el mínimo de claves
sub rebalancear {
    my ($self, $idx) = @_;
    
    # Intentar tomar prestado del hermano izquierdo
    if ($idx > 0 && $self->{hijos}->[$idx - 1]->num_claves() > MIN_CLAVES) {
        $self->tomar_prestado_izquierdo($idx);
    }
    # Intentar tomar prestado del hermano derecho
    elsif ($idx < $self->num_hijos() - 1 && 
           $self->{hijos}->[$idx + 1]->num_claves() > MIN_CLAVES) {
        $self->tomar_prestado_derecho($idx);
    }
    # Si no se puede tomar prestado, fusionar
    else {
        if ($idx > 0) {
            $self->fusionar($idx - 1);
        }
        else {
            $self->fusionar($idx);
        }
    }
}

# ============================================================================
# CLASE ÁRBOL B DE AVIONES (ORDEN 4)
# ============================================================================
package BTree;
use constant ORDEN => 4;

sub new {
    my $class = shift;
    my $self = {
        raiz => BNode->new(),
    };
    bless $self, $class;
    return $self;
}

sub get_raiz { return shift->{raiz}; }

# Buscar un avión por número de registro
sub buscar {
    my ($self, $numero_registro) = @_;
    return _buscar_nodo($self->{raiz}, $numero_registro);
}

sub _buscar_nodo {
    my ($nodo, $numero_registro) = @_;
    return undef unless $nodo;
    
    my $idx = $nodo->buscar_clave($numero_registro);
    
    if ($idx < $nodo->num_claves() && 
        $nodo->{claves}->[$idx]->get_numero_registro() eq $numero_registro) {
        return $nodo->{claves}->[$idx];
    }
    
    if ($nodo->es_hoja()) {
        return undef;
    }
    
    return _buscar_nodo($nodo->{hijos}->[$idx], $numero_registro);
}

# Insertar un avión en el árbol
sub insertar {
    my ($self, $avion) = @_;
    
    my $raiz = $self->{raiz};
    
    if ($raiz->esta_lleno()) {
        my $nueva_raiz = BNode->new();
        $nueva_raiz->set_hoja(0);
        $nueva_raiz->{hijos}->[0] = $raiz;
        $raiz->set_padre($nueva_raiz);
        
        my ($nuevo_nodo, $mediana) = $raiz->dividir();
        
        $nueva_raiz->{claves}->[0] = $mediana;
        $nueva_raiz->{hijos}->[1] = $nuevo_nodo;
        $nuevo_nodo->set_padre($nueva_raiz);
        
        $self->{raiz} = $nueva_raiz;
        
        if ($avion->get_numero_registro() lt $mediana->get_numero_registro()) {
            _insertar_no_lleno($nueva_raiz->{hijos}->[0], $avion);
        }
        else {
            _insertar_no_lleno($nueva_raiz->{hijos}->[1], $avion);
        }
    }
    else {
        _insertar_no_lleno($raiz, $avion);
    }
}

sub _insertar_no_lleno {
    my ($nodo, $avion) = @_;
    
    if ($nodo->es_hoja()) {
        $nodo->insertar_clave($avion);
    }
    else {
        my $pos = $nodo->encontrar_posicion_insertar($avion->get_numero_registro());
        
        if ($nodo->{hijos}->[$pos]->esta_lleno()) {
            my ($nuevo_nodo, $mediana) = $nodo->{hijos}->[$pos]->dividir();
            
            my $insert_pos = $nodo->encontrar_posicion_insertar($mediana->get_numero_registro());
            splice(@{$nodo->{claves}}, $insert_pos, 0, $mediana);
            
            splice(@{$nodo->{hijos}}, $insert_pos + 1, 0, $nuevo_nodo);
            $nuevo_nodo->set_padre($nodo);
            
            if ($avion->get_numero_registro() gt $mediana->get_numero_registro()) {
                $pos = $insert_pos + 1;
            }
            else {
                $pos = $insert_pos;
            }
        }
        
        _insertar_no_lleno($nodo->{hijos}->[$pos], $avion);
    }
}

# Eliminar un avión del árbol
sub eliminar {
    my ($self, $numero_registro) = @_;
    
    my $raiz = $self->{raiz};
    if (!$raiz || $raiz->num_claves() == 0) {
        print "El árbol está vacío\n";
        return 0;
    }
    
    my $resultado = $raiz->eliminar_clave($numero_registro);
    
    # Si la raíz se queda sin claves y no es hoja, su único hijo se convierte en la nueva raíz
    if ($raiz->num_claves() == 0 && !$raiz->es_hoja()) {
        $self->{raiz} = $raiz->{hijos}->[0];
        $self->{raiz}->set_padre(undef);
    }
    
    return $resultado;
}

# Recorrido in-orden
sub inorden {
    my ($self) = @_;
    if (!$self->{raiz} || $self->{raiz}->num_claves() == 0) {
        print "El árbol está vacío\n";
        return;
    }
    _inorden_nodo($self->{raiz});
    print "\n";
}

sub _inorden_nodo {
    my ($nodo) = @_;
    return unless $nodo;
    
    my $i;
    for ($i = 0; $i < $nodo->num_claves(); $i++) {
        if (!$nodo->es_hoja()) {
            _inorden_nodo($nodo->{hijos}->[$i]);
        }
        my $avion = $nodo->{claves}->[$i];
        printf "Registro: %s | Vuelo: %s | Destino: %s\n",
               $avion->get_numero_registro(),
               $avion->get_vuelo(),
               $avion->get_ciudad_destino();
    }
    if (!$nodo->es_hoja()) {
        _inorden_nodo($nodo->{hijos}->[$i]);
    }
}

# Generar gráfico con Graphviz
sub graficar {
    my ($self, $nombre_archivo) = @_;
    $nombre_archivo //= "arbol_b_aviones";
    
    my $dot_content = $self->_generar_dot();
    
    my $dot_file = "${nombre_archivo}.dot";
    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";
    print $fh $dot_content;
    close $fh;
    
    system("dot -Tpng $dot_file -o ${nombre_archivo}.png");
    
    if ($^O eq 'MSWin32') {
        system("start ${nombre_archivo}.png");
    }
    else {
        system("xdg-open ${nombre_archivo}.png 2>/dev/null &");
    }
    
    print "Gráfico generado: ${nombre_archivo}.png\n";
}

sub _generar_dot {
    my ($self) = @_;
    my $dot = "digraph ArbolBAviones {\n";
    $dot .= "  bgcolor=lightblue;\n";
    $dot .= "  node [shape=record, style=filled, fillcolor=beige, fontcolor=black];\n";
    $dot .= "  edge [color=black];\n";
    
    if (!$self->{raiz} || $self->{raiz}->num_claves() == 0) {
        $dot .= "  nodo_vacio [label=\"Árbol Vacío\", shape=box, fillcolor=lightgray];\n";
    }
    else {
        my $null_counter = 0;
        $self->_nodo_a_dot($self->{raiz}, \$dot, \$null_counter);
    }
    
    $dot .= "}\n";
    return $dot;
}

sub _nodo_a_dot {
    my ($self, $nodo, $dot_ref, $null_counter_ref) = @_;
    return unless $nodo;
    
    my $nodo_id = "nodo_" . int(rand(1000000));
    
    my $label = "";
    my $claves = $nodo->{claves};
    for (my $i = 0; $i < @$claves; $i++) {
        $label .= "<f$i> " . $claves->[$i]->get_numero_registro();
        if ($i < @$claves - 1) {
            $label .= " | ";
        }
    }
    
    $$dot_ref .= "  $nodo_id [label=\"$label\"];\n";
    
    if (!$nodo->es_hoja()) {
        my $hijos = $nodo->{hijos};
        for (my $i = 0; $i <= @$claves; $i++) {
            if (defined $hijos->[$i] && $hijos->[$i]->num_claves() > 0) {
                my $hijo_id = $self->_nodo_a_dot($hijos->[$i], $dot_ref, $null_counter_ref);
                $$dot_ref .= "  $nodo_id -> $hijo_id;\n";
            }
            else {
                my $null_id = "null_$$null_counter_ref";
                $$dot_ref .= "  $null_id [shape=point];\n";
                $$dot_ref .= "  $nodo_id -> $null_id;\n";
                $$null_counter_ref++;
            }
        }
    }
    
    return $nodo_id;
}

# Guardar árbol a archivo (persistencia en formato nativo)
sub guardar {
    my ($self, $filename) = @_;
    open(my $fh, '>', $filename) or die "No se pudo abrir $filename: $!";
    $self->_guardar_nodo($fh, $self->{raiz});
    close $fh;
    print "Árbol guardado en $filename\n";
}

sub _guardar_nodo {
    my ($self, $fh, $nodo) = @_;
    return unless $nodo;
    
    print $fh $nodo->num_claves() . "|" . ($nodo->es_hoja() ? "1" : "0") . "\n";
    
    foreach my $avion (@{$nodo->{claves}}) {
        print $fh $avion->to_string() . "\n";
    }
    
    if (!$nodo->es_hoja()) {
        foreach my $hijo (@{$nodo->{hijos}}) {
            $self->_guardar_nodo($fh, $hijo);
        }
    }
}

# Cargar árbol desde archivo (formato nativo)
sub cargar {
    my ($self, $filename) = @_;
    open(my $fh, '<', $filename) or die "No se pudo abrir $filename: $!";
    $self->{raiz} = $self->_cargar_nodo($fh);
    close $fh;
    print "Árbol cargado desde $filename\n";
}

sub _cargar_nodo {
    my ($self, $fh) = @_;
    
    my $line = <$fh>;
    chomp $line;
    return undef unless $line && $line ne '';
    
    my ($num_claves, $es_hoja) = split /\|/, $line;
    
    my $nodo = BNode->new();
    $nodo->set_hoja($es_hoja);
    
    for (my $i = 0; $i < $num_claves; $i++) {
        $line = <$fh>;
        chomp $line;
        my $avion = Avion->from_string($line);
        push @{$nodo->{claves}}, $avion;
    }
    
    if (!$es_hoja) {
        for (my $i = 0; $i <= $num_claves; $i++) {
            my $hijo = $self->_cargar_nodo($fh);
            if ($hijo) {
                push @{$nodo->{hijos}}, $hijo;
                $hijo->set_padre($nodo);
            }
        }
    }
    
    return $nodo;
}

# ============================================================================
# FUNCIÓN PARA CARGAR DESDE ARCHIVO CSV
# ============================================================================
sub cargar_desde_csv {
    my ($self, $filename) = @_;
    
    open(my $fh, '<', $filename) or die "No se pudo abrir $filename: $!";
    
    # Leer la primera línea (encabezados)
    my $cabecera = <$fh>;
    chomp $cabecera;
    my @columnas = split /,/, $cabecera;
    
    # Verificar que tenga las columnas correctas
    my %indices;
    for (my $i = 0; $i < @columnas; $i++) {
        $indices{$columnas[$i]} = $i;
    }
    
    # Verificar columnas requeridas
    my @requeridas = qw(vuelo numero_registro modelo capacidad aerolinea ciudad_destino estado);
    foreach my $req (@requeridas) {
        unless (exists $indices{$req}) {
            die "Error: Columna '$req' no encontrada en el archivo CSV";
        }
    }
    
    my $contador = 0;
    my $errores = 0;
    
    print "\n--- CARGANDO DESDE CSV ---\n";
    
    # Leer cada línea de datos
    while (my $linea = <$fh>) {
        chomp $linea;
        next if $linea =~ /^\s*$/;  # Saltar líneas vacías
        
        my @campos = split /,/, $linea;
        
        # Verificar que tenga suficientes campos
        if (@campos < @columnas) {
            warn "Línea mal formada (pocos campos): $linea";
            $errores++;
            next;
        }
        
        # Extraer datos usando los índices de las columnas
        my $vuelo = $campos[$indices{vuelo}];
        my $numero_registro = $campos[$indices{numero_registro}];
        my $modelo = $campos[$indices{modelo}];
        my $capacidad = $campos[$indices{capacidad}];
        my $aerolinea = $campos[$indices{aerolinea}];
        my $ciudad_destino = $campos[$indices{ciudad_destino}];
        my $estado = $campos[$indices{estado}];
        
        # Limpiar espacios en blanco
        $vuelo =~ s/^\s+|\s+$//g;
        $numero_registro =~ s/^\s+|\s+$//g;
        $modelo =~ s/^\s+|\s+$//g;
        $aerolinea =~ s/^\s+|\s+$//g;
        $ciudad_destino =~ s/^\s+|\s+$//g;
        $estado =~ s/^\s+|\s+$//g;
        
        # Verificar si ya existe
        my $existente = $self->buscar($numero_registro);
        if ($existente) {
            print "  - Advertencia: Ya existe un avión con registro $numero_registro, se omite\n";
            $errores++;
            next;
        }
        
        # Crear el avión
        my $avion = Avion->new(
            vuelo           => $vuelo,
            numero_registro => $numero_registro,
            modelo          => $modelo,
            capacidad       => $capacidad,
            aerolinea       => $aerolinea,
            ciudad_destino  => $ciudad_destino,
            estado          => $estado
        );
        
        # Insertar solo si está disponible
        if ($avion->get_estado() eq "Disponible") {
            $self->insertar($avion);
            $contador++;
            print "  + Insertado: $numero_registro ($vuelo)\n";
        }
        else {
            print "  - Omitido (no disponible): $numero_registro ($vuelo) - Estado: $estado\n";
        }
    }
    
    close $fh;
    
    print "\n=== RESULTADO DE CARGA ===\n";
    print "Aviones cargados exitosamente: $contador\n";
    print "Errores/omisiones: $errores\n" if $errores > 0;
    
    return $contador;
}

# ============================================================================
# MENÚ PRINCIPAL
# ============================================================================
package main;

sub mostrar_menu {
    print "\n" . "=" x 50 . "\n";
    print "          ÁRBOL B DE AVIONES - ORDEN 4\n";
    print "=" x 50 . "\n";
    print "1. Insertar avión\n";
    print "2. Eliminar avión\n";
    print "3. Generar gráfico con Graphviz\n";
    print "4. Mostrar todos los aviones (in-orden)\n";
    print "5. Buscar avión por número de registro\n";
    print "6. Guardar árbol en archivo (formato nativo)\n";
    print "7. Cargar desde archivo CSV\n";
    print "8. Salir\n";
    print "-" x 50 . "\n";
    print "Seleccione una opción: ";
}

sub insertar_interactivo {
    my ($arbol) = @_;
    
    print "\n--- INSERTAR AVIÓN ---\n";
    print "Número de registro: ";
    chomp(my $registro = <STDIN>);
    
    my $existente = $arbol->buscar($registro);
    if ($existente) {
        print "Ya existe un avión con ese número de registro.\n";
        return;
    }
    
    print "Vuelo: ";
    chomp(my $vuelo = <STDIN>);
    
    print "Modelo: ";
    chomp(my $modelo = <STDIN>);
    
    print "Capacidad: ";
    chomp(my $capacidad = <STDIN>);
    
    print "Aerolínea: ";
    chomp(my $aerolinea = <STDIN>);
    
    print "Ciudad destino: ";
    chomp(my $ciudad = <STDIN>);
    
    print "Estado (Disponible/Mantenimiento): ";
    chomp(my $estado = <STDIN>);
    
    my $avion = Avion->new(
        vuelo           => $vuelo,
        numero_registro => $registro,
        modelo          => $modelo,
        capacidad       => $capacidad,
        aerolinea       => $aerolinea,
        ciudad_destino  => $ciudad,
        estado          => $estado
    );
    
    $arbol->insertar($avion);
    print "Avión insertado correctamente.\n";
}

sub eliminar_interactivo {
    my ($arbol) = @_;
    
    print "\n--- ELIMINAR AVIÓN ---\n";
    print "Número de registro: ";
    chomp(my $registro = <STDIN>);
    
    if ($arbol->eliminar($registro)) {
        print "Avión eliminado correctamente.\n";
    }
    else {
        print "No se encontró un avión con ese número de registro.\n";
    }
}

sub buscar_interactivo {
    my ($arbol) = @_;
    
    print "\n--- BUSCAR AVIÓN ---\n";
    print "Número de registro: ";
    chomp(my $registro = <STDIN>);
    
    my $avion = $arbol->buscar($registro);
    if ($avion) {
        print "Avión encontrado:\n";
        $avion->imprimir();
        print "  Vuelo: " . $avion->get_vuelo() . "\n";
        print "  Modelo: " . $avion->{modelo} . "\n";
        print "  Capacidad: " . $avion->{capacidad} . "\n";
        print "  Aerolínea: " . $avion->{aerolinea} . "\n";
        print "  Destino: " . $avion->get_ciudad_destino() . "\n";
    }
    else {
        print "No se encontró un avión con ese número de registro.\n";
    }
}

sub guardar_interactivo {
    my ($arbol) = @_;
    
    print "\n--- GUARDAR ÁRBOL ---\n";
    print "Nombre del archivo: ";
    chomp(my $archivo = <STDIN>);
    
    $arbol->guardar($archivo);
}

sub cargar_csv_interactivo {
    my ($arbol) = @_;
    
    print "\n--- CARGAR DESDE ARCHIVO CSV ---\n";
    print "Nombre del archivo CSV: ";
    chomp(my $archivo = <STDIN>);
    
    unless (-f $archivo) {
        print "El archivo no existe.\n";
        return;
    }
    
    eval {
        my $cantidad = $arbol->cargar_desde_csv($archivo);
        print "\nProceso completado. Se cargaron $cantidad aviones.\n";
    };
    if ($@) {
        print "Error al cargar el archivo CSV: $@\n";
    }
}

# ============================================================================
# PROGRAMA PRINCIPAL
# ============================================================================
my $arbol = BTree->new();

while (1) {
    mostrar_menu();
    chomp(my $opcion = <STDIN>);
    
    if ($opcion eq '1') {
        insertar_interactivo($arbol);
    }
    elsif ($opcion eq '2') {
        eliminar_interactivo($arbol);
    }
    elsif ($opcion eq '3') {
        print "Nombre para el archivo del gráfico [arbol_b_aviones]: ";
        chomp(my $nombre = <STDIN>);
        $nombre = "arbol_b_aviones" unless $nombre;
        $arbol->graficar($nombre);
    }
    elsif ($opcion eq '4') {
        print "\n--- AVIONES EN ORDEN ---\n";
        $arbol->inorden();
    }
    elsif ($opcion eq '5') {
        buscar_interactivo($arbol);
    }
    elsif ($opcion eq '6') {
        guardar_interactivo($arbol);
    }
    elsif ($opcion eq '7') {
        cargar_csv_interactivo($arbol);
    }
    elsif ($opcion eq '8') {
        print "Saliendo del programa...\n";
        last;
    }
    else {
        print "Opción no válida. Intente de nuevo.\n";
    }
}

print "Programa terminado.\n";