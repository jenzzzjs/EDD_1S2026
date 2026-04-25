#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite -signatures;
use JSON;
use File::Temp qw(tempfile);


package Estudiante;
use Mojo::Base -base;

has 'carnet';
has 'nombre';
has 'edad';
has 'curso';
has 'semestre';
has 'creado' => sub { time() };

sub to_hash {
    my ($self) = @_;
    return {
        carnet => $self->carnet,
        nombre => $self->nombre,
        edad => $self->edad,
        curso => $self->curso,
        semestre => $self->semestre,
        creado => scalar(localtime($self->creado))
    };
}

1;

package NodoHash;
use Mojo::Base -base;

has 'estudiante';
has 'siguiente' => sub { undef };

1;

package SlotNodo;
use Mojo::Base -base;

has 'indice';
has 'curso';                    # Curso principal del slot
has 'cursos_lista' => sub { [] };  # Lista de cursos en este slot 
has 'lista_cabeza' => sub { undef };
has 'cantidad' => sub { 0 };
has 'colisiones' => sub { 0 };
has 'siguiente' => sub { undef };

sub esta_vacio {
    my ($self) = @_;
    return !defined($self->lista_cabeza);
}

1;

package TablaHashEstudiantes;
use Mojo::Base -base;

use constant CAPACIDAD => 10;

has 'cabeza_slots' => sub { undef };
has 'total_estudiantes' => sub { 0 };
has 'cursos_registrados' => sub { {} };  # curso -> indice

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new();
    
    my $ultimo = undef;
    for my $i (reverse 0 .. CAPACIDAD - 1) {
        my $slot = SlotNodo->new(
            indice => $i,
            curso => undef
        );
        $slot->siguiente($ultimo);
        $ultimo = $slot;
    }
    $self->cabeza_slots($ultimo);
    
    return $self;
}

sub _calcular_indice {
    my ($self, $curso) = @_;
    
    if (exists $self->cursos_registrados->{$curso}) {
        return $self->cursos_registrados->{$curso};
    }
    
    my $hash = 5381;
    for my $char (split //, $curso) {
        $hash = ($hash * 33 + ord($char)) % CAPACIDAD;
    }
    
    return $hash;
}

sub registrar_curso {
    my ($self, $curso) = @_;
    
    return { success => 0, message => "El curso ya está registrado" }
        if exists $self->cursos_registrados->{$curso};
    
    my $indice = $self->_calcular_indice($curso);
    my $slot = $self->_obtener_slot($indice);
    
    # Obtener lista de cursos en este slot
    my $cursos_slot = $slot->cursos_lista;
    
    # Verificar si el slot ya tiene cursos
    my $colision = scalar(@$cursos_slot) > 0;
    
    # Agregar el curso a la lista del slot
    push @$cursos_slot, $curso;
    $slot->cursos_lista($cursos_slot);
    
    # Si es el primer curso, también asignarlo como curso principal
    if (!$slot->curso) {
        $slot->curso($curso);
    }
    
    $self->cursos_registrados->{$curso} = $indice;
    
    my $total_cursos = scalar(@$cursos_slot);
    
    return { 
        success => 1, 
        message => $colision ? 
            "Curso registrado en Slot $indice (COLISIÓN - $total_cursos cursos en este slot)" :
            "Curso registrado en Slot $indice",
        slot => $indice,
        colision => $colision,
        total_en_slot => $total_cursos
    };
}

sub _obtener_slot {
    my ($self, $indice) = @_;
    my $actual = $self->cabeza_slots;
    while (defined $actual) {
        return $actual if $actual->indice == $indice;
        $actual = $actual->siguiente;
    }
    return undef;
}

sub insertar_estudiante {
    my ($self, $estudiante) = @_;
    
    my $curso = $estudiante->curso;
    
    unless (exists $self->cursos_registrados->{$curso}) {
        return { success => 0, message => "El curso '$curso' no está registrado. Regístralo primero." };
    }
    
    my $indice = $self->cursos_registrados->{$curso};
    my $slot = $self->_obtener_slot($indice);
    
    my $colision = 0;
    if (!$slot->esta_vacio) {
        $colision = 1;
        $slot->colisiones($slot->colisiones + 1);
    }
    
    my $nuevo_nodo = NodoHash->new(estudiante => $estudiante);
    
    if ($slot->esta_vacio) {
        $slot->lista_cabeza($nuevo_nodo);
    } else {
        $nuevo_nodo->siguiente($slot->lista_cabeza);
        $slot->lista_cabeza($nuevo_nodo);
    }
    
    $slot->cantidad($slot->cantidad + 1);
    $self->total_estudiantes($self->total_estudiantes + 1);
    
    return { 
        success => 1, 
        message => "Estudiante registrado en $curso",
        colision => $colision,
        slot => $indice
    };
}

sub buscar_por_curso {
    my ($self, $curso) = @_;
    
    return [] unless exists $self->cursos_registrados->{$curso};
    
    my $indice = $self->cursos_registrados->{$curso};
    my $slot = $self->_obtener_slot($indice);
    return [] unless $slot;
    
    my @estudiantes = ();
    my $nodo = $slot->lista_cabeza;
    while (defined $nodo) {
        push @estudiantes, $nodo->estudiante->to_hash;
        $nodo = $nodo->siguiente;
    }
    
    return \@estudiantes;
}

sub buscar_por_carnet {
    my ($self, $carnet) = @_;
    
    my $slot = $self->cabeza_slots;
    while (defined $slot) {
        my $nodo = $slot->lista_cabeza;
        while (defined $nodo) {
            if ($nodo->estudiante->carnet eq $carnet) {
                return $nodo->estudiante->to_hash;
            }
            $nodo = $nodo->siguiente;
        }
        $slot = $slot->siguiente;
    }
    
    return undef;
}

sub eliminar_estudiante {
    my ($self, $carnet, $curso) = @_;
    
    return { success => 0, message => "Curso no registrado" }
        unless exists $self->cursos_registrados->{$curso};
    
    my $indice = $self->cursos_registrados->{$curso};
    my $slot = $self->_obtener_slot($indice);
    
    my $previo = undef;
    my $actual = $slot->lista_cabeza;
    
    while (defined $actual) {
        if ($actual->estudiante->carnet eq $carnet) {
            if (!defined $previo) {
                $slot->lista_cabeza($actual->siguiente);
            } else {
                $previo->siguiente($actual->siguiente);
            }
            $slot->cantidad($slot->cantidad - 1);
            $self->total_estudiantes($self->total_estudiantes - 1);
            
            return { success => 1, message => "Estudiante eliminado" };
        }
        $previo = $actual;
        $actual = $actual->siguiente;
    }
    
    return { success => 0, message => "Estudiante no encontrado" };
}

sub obtener_estadisticas {
    my ($self) = @_;
    
    my @slots_info = ();
    my $slot = $self->cabeza_slots;
    
    while (defined $slot) {
        my $cursos_text = scalar(@{$slot->cursos_lista}) > 0 ? 
            join(", ", @{$slot->cursos_lista}) : "(vacío)";
        
        push @slots_info, {
            indice => $slot->indice,
            cursos => $cursos_text,
            cantidad_cursos => scalar(@{$slot->cursos_lista}),
            cantidad_estudiantes => $slot->cantidad,
            colisiones_estudiantes => $slot->colisiones,
            esta_vacio => $slot->esta_vacio
        };
        $slot = $slot->siguiente;
    }
    
    return {
        total_estudiantes => $self->total_estudiantes,
        total_cursos => scalar(keys %{$self->cursos_registrados}),
        capacidad => CAPACIDAD,
        slots => \@slots_info,
        factor_carga => sprintf("%.2f", $self->total_estudiantes / CAPACIDAD),
        cursos_registrados => $self->cursos_registrados
    };
}

sub obtener_todos_estudiantes {
    my ($self) = @_;
    
    my @estudiantes = ();
    my $slot = $self->cabeza_slots;
    
    while (defined $slot) {
        my $nodo = $slot->lista_cabeza;
        while (defined $nodo) {
            push @estudiantes, $nodo->estudiante->to_hash;
            $nodo = $nodo->siguiente;
        }
        $slot = $slot->siguiente;
    }
    
    return \@estudiantes;
}

sub obtener_todos_cursos {
    my ($self) = @_;
    return [keys %{$self->cursos_registrados}];
}

sub generar_dot {
    my ($self) = @_;
    
    my $dot = "digraph TablaHash {\n";
    $dot .= "    rankdir=TB;\n";
    $dot .= "    node [shape=record, fontname=\"Arial\", style=filled, fillcolor=\"#1a1a2e\", fontcolor=\"white\"];\n";
    $dot .= "    edge [color=\"#6c63ff\"];\n";
    $dot .= "    bgcolor=\"#0a0a1a\";\n\n";
    
    $dot .= "    subgraph cluster_tabla {\n";
    $dot .= "        label=\"TABLA HASH - REGISTRO DE ESTUDIANTES POR CURSO (Capacidad: " . CAPACIDAD . " slots)\";\n";
    $dot .= "        style=filled;\n";
    $dot .= "        fillcolor=\"#0d0d1a\";\n";
    $dot .= "        color=\"#4A90D9\";\n\n";
    
    my $slot = $self->cabeza_slots;
    
    while (defined $slot) {
        my $color = $slot->esta_vacio ? "#333344" : "#4A90D9";
        my $cursos_label = scalar(@{$slot->cursos_lista}) > 0 ? 
            join("\\n", @{$slot->cursos_lista}) : "LIBRE";
        
        my $label = "{<slot> Slot " . $slot->indice . " | $cursos_label | {" . $slot->cantidad . " estudiantes}";
        
        if ($slot->colisiones > 0) {
            $label .= " | Colisiones: " . $slot->colisiones;
        }
        $label .= "}";
        
        $dot .= "        slot" . $slot->indice . " [label=\"$label\", fillcolor=\"$color\"];\n";
        
        my $nodo = $slot->lista_cabeza;
        my $prev = "slot" . $slot->indice;
        my $est_num = 0;
        
        while (defined $nodo) {
            my $est_label = $nodo->estudiante->nombre . "\\n(" . $nodo->estudiante->carnet . ")\\nSem: " . $nodo->estudiante->semestre;
            $dot .= "        est_" . $slot->indice . "_${est_num} [label=\"$est_label\", fillcolor=\"#2a2a4a\"];\n";
            $dot .= "        $prev -> est_" . $slot->indice . "_${est_num} [color=\"#00ff88\", label=\"LIFO\"];\n";
            $prev = "est_" . $slot->indice . "_${est_num}";
            $nodo = $nodo->siguiente;
            $est_num++;
        }
        
        if ($est_num == 0 && scalar(@{$slot->cursos_lista}) == 0) {
            $dot .= "        empty_" . $slot->indice . " [label=\"(slot libre)\", fillcolor=\"#333344\"];\n";
            $dot .= "        slot" . $slot->indice . " -> empty_" . $slot->indice . " [color=\"#666\", style=\"dashed\"];\n";
        }
        
        $dot .= "\n";
        $slot = $slot->siguiente;
    }
    
    $dot .= "    }\n";
    $dot .= "}\n";
    
    return $dot;
}

1;


package main;

my $tabla = TablaHashEstudiantes->new();

my $data_file = 'estudiantes_hash.json';
if (-f $data_file) {
    open my $fh, '<', $data_file;
    local $/;
    my $json_text = <$fh>;
    close $fh;
    
    eval {
        my $data = decode_json($json_text);
        
        if ($data->{cursos}) {
            foreach my $curso (keys %{$data->{cursos}}) {
                $tabla->registrar_curso($curso);
            }
        }
        
        if ($data->{estudiantes}) {
            foreach my $est (@{$data->{estudiantes}}) {
                my $estudiante = Estudiante->new(
                    carnet => $est->{carnet},
                    nombre => $est->{nombre},
                    edad => $est->{edad},
                    curso => $est->{curso},
                    semestre => $est->{semestre}
                );
                $tabla->insertar_estudiante($estudiante);
            }
        }
    };
}

sub guardar_datos {
    my $estudiantes = $tabla->obtener_todos_estudiantes();
    my $cursos = $tabla->cursos_registrados;
    
    my $data = {
        estudiantes => $estudiantes,
        cursos => $cursos
    };
    
    open my $fh, '>', $data_file;
    print $fh encode_json($data);
    close $fh;
}

app->hook(before_dispatch => sub ($c) {
    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
    $c->res->headers->header('Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS');
    $c->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type, Authorization');
    
    if ($c->req->method eq 'OPTIONS') {
        $c->rendered(200);
        return;
    }
});

# endpoiints a utilizar

get '/' => sub ($c) {
    $c->render(json => {
        mensaje => "API de Tabla Hash - Registro de Estudiantes por Curso",
        version => "3.0"
    });
};

# Registrar nuevo curso
post '/api/cursos/registrar' => sub ($c) {
    my $data = $c->req->json;
    my $curso = $data->{curso};
    
    unless ($curso) {
        $c->render(json => { success => 0, message => "Nombre del curso requerido" }, status => 400);
        return;
    }
    
    my $resultado = $tabla->registrar_curso($curso);
    guardar_datos();
    
    $c->render(json => $resultado);
};

# Listar cursos registrados
get '/api/cursos' => sub ($c) {
    my $cursos = $tabla->cursos_registrados;
    my @lista = map { { nombre => $_, slot => $cursos->{$_} } } keys %$cursos;
    
    $c->render(json => {
        success => 1,
        cursos => \@lista,
        total => scalar(@lista)
    });
};

# Registrar estudiante
post '/api/estudiantes' => sub ($c) {
    my $data = $c->req->json;
    
    my $carnet = $data->{carnet};
    my $nombre = $data->{nombre};
    my $edad = $data->{edad};
    my $curso = $data->{curso};
    my $semestre = $data->{semestre};
    
    if (!$carnet || !$nombre || !$edad || !$curso || !$semestre) {
        $c->render(json => { success => 0, message => "Faltan campos" }, status => 400);
        return;
    }
    
    my $existente = $tabla->buscar_por_carnet($carnet);
    if ($existente) {
        $c->render(json => { success => 0, message => "El carnet $carnet ya está registrado" }, status => 400);
        return;
    }
    
    my $estudiante = Estudiante->new(
        carnet => $carnet,
        nombre => $nombre,
        edad => $edad,
        curso => $curso,
        semestre => $semestre
    );
    
    my $resultado = $tabla->insertar_estudiante($estudiante);
    guardar_datos();
    
    $c->render(json => $resultado);
};

# Listar todos los estudiantes
get '/api/estudiantes' => sub ($c) {
    my $estudiantes = $tabla->obtener_todos_estudiantes();
    $c->render(json => {
        success => 1,
        total => scalar(@$estudiantes),
        estudiantes => $estudiantes
    });
};

# Buscar por carnet
get '/api/estudiantes/:carnet' => sub ($c) {
    my $carnet = $c->stash('carnet');
    my $estudiante = $tabla->buscar_por_carnet($carnet);
    
    if ($estudiante) {
        $c->render(json => { success => 1, estudiante => $estudiante });
    } else {
        $c->render(json => { success => 0, message => "No encontrado" }, status => 404);
    }
};

# Buscar por curso
get '/api/curso/:curso' => sub ($c) {
    my $curso = $c->stash('curso');
    my $estudiantes = $tabla->buscar_por_curso($curso);
    
    $c->render(json => {
        success => 1,
        curso => $curso,
        total => scalar(@$estudiantes),
        estudiantes => $estudiantes
    });
};

# Eliminar estudiante
del '/api/estudiantes/:carnet/:curso' => sub ($c) {
    my $carnet = $c->stash('carnet');
    my $curso = $c->stash('curso');
    
    my $resultado = $tabla->eliminar_estudiante($carnet, $curso);
    guardar_datos() if $resultado->{success};
    
    $c->render(json => $resultado);
};

# Estadísticas
get '/api/estadisticas' => sub ($c) {
    my $estadisticas = $tabla->obtener_estadisticas();
    $c->render(json => {
        success => 1,
        estadisticas => $estadisticas
    });
};

# Generar imagen PNG del grafo
get '/api/hash/grafo' => sub ($c) {
    my $dot_content = $tabla->generar_dot();
    
    my ($dot_fh, $dot_file) = tempfile("hash_XXXXXX", SUFFIX => '.dot', TMPDIR => 1);
    print $dot_fh $dot_content;
    close $dot_fh;
    
    my ($png_fh, $png_file) = tempfile("hash_XXXXXX", SUFFIX => '.png', TMPDIR => 1);
    close $png_fh;
    
    my $cmd = "dot -Tpng \"$dot_file\" -o \"$png_file\" 2>/dev/null";
    system($cmd);
    
    if (-f $png_file && -s $png_file > 0) {
        open my $img_fh, '<', $png_file;
        binmode $img_fh;
        local $/;
        my $imagen_data = <$img_fh>;
        close $img_fh;
        
        unlink $dot_file if -f $dot_file;
        unlink $png_file if -f $png_file;
        
        $c->res->headers->content_type('image/png');
        $c->render(data => $imagen_data);
    } else {
        unlink $dot_file if -f $dot_file;
        unlink $png_file if -f $png_file;
        
        $c->render(json => { success => 0, message => "Error al generar grafo. Instala GraphViz." }, status => 500);
    }
};

# Obtener DOT
get '/api/hash/dot' => sub ($c) {
    my $dot_content = $tabla->generar_dot();
    $c->render(text => $dot_content);
};

my $port = $ENV{MOJO_PORT} // 3006;
say "=" x 50;
say "  TABLA HASH - REGISTRO DE ESTUDIANTES POR CURSO";
say "=" x 50;
say "  Puerto: $port";
say "  URL: http://localhost:$port";
say "=" x 50;
say "  Capacidad: 10 slots";
say "  Método: Encadenamiento separado (LIFO)";
say "  Cursos: Matemáticas, Física, Programación, etc.";
say "=" x 50;

app->start('daemon', '-l', "http://*:$port");