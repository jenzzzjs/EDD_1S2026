#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite -signatures;
use JSON;

# Función simple de hash (no es criptográficamente segura, pero funciona para el ejemplo)
sub simple_hash {
    my ($password) = @_;
    my $hash = 0;
    for my $char (split //, $password) {
        $hash = ($hash * 31 + ord($char)) % 2**32;
    }
    return sprintf("%08x", $hash);
}

# CLASE VERTICE (USUARIO)
package Vertice;
use Mojo::Base -base;

has 'nombre';
has 'password_hash';
has 'creado' => sub { time() };
has 'adyacentes' => sub { [] };

sub agregar_adyacente {
    my ($self, $arista) = @_;
    push @{$self->adyacentes}, $arista;
}

sub obtener_adyacentes {
    my ($self) = @_;
    return @{$self->adyacentes};
}

sub verificar_password {
    my ($self, $password) = @_;
    # Llamar a la función simple_hash del paquete main
    my $hash = main::simple_hash($password);
    return $self->password_hash eq $hash;
}

1;

# CLASE ARISTA (AMISTAD)
package Arista;
use Mojo::Base -base;

has 'usuario1';
has 'usuario2';
has 'creado' => sub { time() };
has 'estado';
has 'fecha_aceptacion';

sub to_hash {
    my ($self) = @_;
    return {
        usuario1 => $self->usuario1->nombre,
        usuario2 => $self->usuario2->nombre,
        estado => $self->estado,
        creado => scalar(localtime($self->creado)),
        fecha_aceptacion => $self->fecha_aceptacion ? scalar(localtime($self->fecha_aceptacion)) : undef
    };
}

sub equals {
    my ($self, $usuario1_nombre, $usuario2_nombre) = @_;
    return ($self->usuario1->nombre eq $usuario1_nombre && 
            $self->usuario2->nombre eq $usuario2_nombre);
}

sub tiene_usuario {
    my ($self, $usuario_nombre) = @_;
    return ($self->usuario1->nombre eq $usuario_nombre || 
            $self->usuario2->nombre eq $usuario_nombre);
}

sub obtener_amigo {
    my ($self, $usuario_nombre) = @_;
    if ($self->usuario1->nombre eq $usuario_nombre) {
        return $self->usuario2;
    } elsif ($self->usuario2->nombre eq $usuario_nombre) {
        return $self->usuario1;
    }
    return undef;
}

1;

# CLASE GRAFO NO DIRIGIDO
package GrafoAmistades;
use Mojo::Base -base;

has 'vertices' => sub { {} };
has 'aristas'  => sub { [] };
has 'solicitudes' => sub { [] };

sub registrar_usuario {
    my ($self, $nombre, $password) = @_;
    
    return { success => 0, message => "El usuario ya existe" }
        if exists $self->vertices->{$nombre};
    
    return { success => 0, message => "Nombre de usuario inválido" }
        if $nombre !~ /^[a-zA-Z0-9_]{3,20}$/;
    
    return { success => 0, message => "Contraseña debe tener al menos 4 caracteres" }
        if length($password) < 4;
    
    my $password_hash = main::simple_hash($password);
    my $vertice = Vertice->new(
        nombre => $nombre,
        password_hash => $password_hash
    );
    
    $self->vertices->{$nombre} = $vertice;
    $self->_guardar_usuarios();
    
    return { success => 1, message => "Usuario registrado exitosamente", usuario => $nombre };
}

sub iniciar_sesion {
    my ($self, $nombre, $password) = @_;
    
    my $usuario = $self->vertices->{$nombre};
    
    return { success => 0, message => "Usuario no existe" }
        unless $usuario;
    
    return { success => 0, message => "Contraseña incorrecta" }
        unless $usuario->verificar_password($password);
    
    return { success => 1, message => "Inicio de sesión exitoso", usuario => $nombre };
}

sub enviar_solicitud {
    my ($self, $solicitante, $destinatario) = @_;
    
    return { success => 0, message => "Solicitante no existe" }
        unless exists $self->vertices->{$solicitante};
    
    return { success => 0, message => "Destinatario no existe" }
        unless exists $self->vertices->{$destinatario};
    
    return { success => 0, message => "No puedes enviarte solicitud a ti mismo" }
        if $solicitante eq $destinatario;
    
    my $amistad_existente = $self->buscar_amistad($solicitante, $destinatario);
    if ($amistad_existente && $amistad_existente->estado eq 'aceptada') {
        return { success => 0, message => "Ya son amigos" };
    }
    
    if ($amistad_existente && $amistad_existente->estado eq 'pendiente') {
        return { success => 0, message => "Ya hay una solicitud pendiente" };
    }
    
    my $origen = $self->vertices->{$solicitante};
    my $destino = $self->vertices->{$destinatario};
    
    my $arista = Arista->new(
        usuario1 => $origen,
        usuario2 => $destino,
        estado => 'pendiente'
    );
    
    push @{$self->aristas}, $arista;
    push @{$self->solicitudes}, $arista;
    
    $origen->agregar_adyacente($arista);
    $destino->agregar_adyacente($arista);
    
    $self->_guardar_datos();
    
    return { success => 1, message => "Solicitud de amistad enviada",
             solicitante => $solicitante, destinatario => $destinatario };
}

sub aceptar_solicitud {
    my ($self, $usuario, $solicitante) = @_;
    
    return { success => 0, message => "Usuario no existe" }
        unless exists $self->vertices->{$usuario};
    
    return { success => 0, message => "Solicitante no existe" }
        unless exists $self->vertices->{$solicitante};
    
    my $amistad = $self->buscar_amistad($solicitante, $usuario);
    
    return { success => 0, message => "No hay solicitud pendiente" }
        unless $amistad && $amistad->estado eq 'pendiente';
    
    $amistad->estado('aceptada');
    $amistad->fecha_aceptacion(time());
    
    @{$self->solicitudes} = grep { $_ != $amistad } @{$self->solicitudes};
    
    $self->_guardar_datos();
    
    return { success => 1, message => "Solicitud de amistad aceptada",
             usuario => $usuario, amigo => $solicitante };
}

sub rechazar_solicitud {
    my ($self, $usuario, $solicitante) = @_;
    
    my $amistad = $self->buscar_amistad($solicitante, $usuario);
    
    return { success => 0, message => "No hay solicitud pendiente" }
        unless $amistad && $amistad->estado eq 'pendiente';
    
    @{$self->aristas} = grep { $_ != $amistad } @{$self->aristas};
    @{$self->solicitudes} = grep { $_ != $amistad } @{$self->solicitudes};
    
    my $usuario_vertice = $self->vertices->{$usuario};
    my $solicitante_vertice = $self->vertices->{$solicitante};
    
    @{$usuario_vertice->adyacentes} = grep { $_ != $amistad } @{$usuario_vertice->adyacentes};
    @{$solicitante_vertice->adyacentes} = grep { $_ != $amistad } @{$solicitante_vertice->adyacentes};
    
    $self->_guardar_datos();
    
    return { success => 1, message => "Solicitud rechazada" };
}

sub buscar_amistad {
    my ($self, $usuario1, $usuario2) = @_;
    
    foreach my $arista (@{$self->aristas}) {
        if ($arista->equals($usuario1, $usuario2)) {
            return $arista;
        }
    }
    
    return undef;
}

sub obtener_amigos {
    my ($self, $usuario_nombre) = @_;
    
    my $usuario = $self->vertices->{$usuario_nombre};
    return [] unless $usuario;
    
    my @amigos = ();
    foreach my $arista ($usuario->obtener_adyacentes()) {
        next unless $arista->estado eq 'aceptada';
        my $amigo = $arista->obtener_amigo($usuario_nombre);
        push @amigos, {
            nombre => $amigo->nombre,
            desde => scalar(localtime($arista->fecha_aceptacion))
        };
    }
    
    return \@amigos;
}

sub obtener_solicitudes_pendientes {
    my ($self, $usuario_nombre) = @_;
    
    my @solicitudes = ();
    foreach my $arista (@{$self->solicitudes}) {
        if ($arista->estado eq 'pendiente' && $arista->tiene_usuario($usuario_nombre)) {
            my $solicitante = $arista->obtener_amigo($usuario_nombre);
            push @solicitudes, {
                usuario => $solicitante->nombre,
                desde => scalar(localtime($arista->creado))
            };
        }
    }
    
    return \@solicitudes;
}

sub obtener_sugerencias {
    my ($self, $usuario_nombre) = @_;
    
    my $usuario = $self->vertices->{$usuario_nombre};
    return [] unless $usuario;
    
    my %amigos_directos = ();
    my %sugerencias = ();
    
    foreach my $arista ($usuario->obtener_adyacentes()) {
        next unless $arista->estado eq 'aceptada';
        my $amigo = $arista->obtener_amigo($usuario_nombre);
        $amigos_directos{$amigo->nombre} = 1;
    }
    
    foreach my $arista ($usuario->obtener_adyacentes()) {
        next unless $arista->estado eq 'aceptada';
        my $amigo = $arista->obtener_amigo($usuario_nombre);
        
        foreach my $arista2 ($amigo->obtener_adyacentes()) {
            next unless $arista2->estado eq 'aceptada';
            my $sugerencia = $arista2->obtener_amigo($amigo->nombre);
            
            next if $sugerencia->nombre eq $usuario_nombre;
            next if exists $amigos_directos{$sugerencia->nombre};
            
            $sugerencias{$sugerencia->nombre}++;
        }
    }
    
    my @sugerencias_lista = ();
    foreach my $nombre (keys %sugerencias) {
        push @sugerencias_lista, {
            usuario => $nombre,
            amigos_en_comun => $sugerencias{$nombre}
        };
    }
    
    @sugerencias_lista = sort { $b->{amigos_en_comun} <=> $a->{amigos_en_comun} } @sugerencias_lista;
    
    return \@sugerencias_lista;
}

sub obtener_estadisticas {
    my ($self) = @_;
    
    my $total_usuarios = keys %{$self->vertices};
    my $total_amistades = 0;
    my $total_solicitudes = 0;
    
    foreach my $arista (@{$self->aristas}) {
        if ($arista->estado eq 'aceptada') {
            $total_amistades++;
        } else {
            $total_solicitudes++;
        }
    }
    
    my $grado_total = 0;
    foreach my $nombre (keys %{$self->vertices}) {
        my $amigos = $self->obtener_amigos($nombre);
        $grado_total += scalar(@$amigos);
    }
    
    my $grado_promedio = $total_usuarios > 0 ? $grado_total / $total_usuarios : 0;
    
    return {
        total_usuarios => $total_usuarios,
        total_amistades => $total_amistades,
        total_solicitudes_pendientes => $total_solicitudes,
        grado_promedio => sprintf("%.2f", $grado_promedio)
    };
}

sub generar_dot {
    my ($self, $resaltar_usuario) = @_;
    
    my $dot = "graph G {\n";
    $dot .= "  rankdir=TB;\n";
    $dot .= "  node [shape=circle, style=filled, fillcolor=\"#1877F2\", fontcolor=\"white\", fontname=\"Arial\", fontsize=10];\n";
    $dot .= "  edge [color=\"#E4E6EB\", penwidth=2];\n";
    $dot .= "  bgcolor=\"#1a1a2e\";\n\n";
    
    foreach my $nombre (keys %{$self->vertices}) {
        my $estilo = "";
        if ($resaltar_usuario && $nombre eq $resaltar_usuario) {
            $estilo = ', fillcolor="#00ff88", fontcolor="black"';
        }
        $dot .= "  \"$nombre\" [label=\"$nombre\"$estilo];\n";
    }
    
    $dot .= "\n";
    
    my %procesadas;
    foreach my $arista (@{$self->aristas}) {
        next unless $arista->estado eq 'aceptada';
        my $u1 = $arista->usuario1->nombre;
        my $u2 = $arista->usuario2->nombre;
        my $key = "$u1-$u2";
        next if $procesadas{$key};
        $procesadas{$key} = 1;
        $dot .= "  \"$u1\" -- \"$u2\";\n";
    }
    
    $dot .= "}\n";
    return $dot;
}

sub _guardar_usuarios {
    my ($self) = @_;
    
    open my $fh, '>', 'usuarios.dat';
    foreach my $nombre (keys %{$self->vertices}) {
        my $usuario = $self->vertices->{$nombre};
        print $fh "$nombre|$usuario->{password_hash}\n";
    }
    close $fh;
}

sub _guardar_aristas {
    my ($self) = @_;
    
    open my $fh, '>', 'amistades.dat';
    foreach my $arista (@{$self->aristas}) {
        print $fh $arista->usuario1->nombre . "|" . 
                  $arista->usuario2->nombre . "|" . 
                  $arista->estado . "|" .
                  $arista->creado . "|" .
                  ($arista->fecha_aceptacion // '') . "\n";
    }
    close $fh;
}

sub _guardar_datos {
    my ($self) = @_;
    $self->_guardar_usuarios();
    $self->_guardar_aristas();
}

sub cargar_datos {
    my ($self) = @_;
    
    if (-f 'usuarios.dat') {
        open my $fh, '<', 'usuarios.dat';
        while (my $linea = <$fh>) {
            chomp $linea;
            my ($nombre, $password_hash) = split /\|/, $linea;
            my $vertice = Vertice->new(
                nombre => $nombre,
                password_hash => $password_hash
            );
            $self->vertices->{$nombre} = $vertice;
        }
        close $fh;
    }
    
    if (-f 'amistades.dat') {
        open my $fh, '<', 'amistades.dat';
        while (my $linea = <$fh>) {
            chomp $linea;
            my ($u1, $u2, $estado, $creado, $fecha_aceptacion) = split /\|/, $linea;
            
            next unless exists $self->vertices->{$u1};
            next unless exists $self->vertices->{$u2};
            
            my $arista = Arista->new(
                usuario1 => $self->vertices->{$u1},
                usuario2 => $self->vertices->{$u2},
                estado => $estado,
                creado => $creado,
                fecha_aceptacion => $fecha_aceptacion || undef
            );
            
            push @{$self->aristas}, $arista;
            
            $self->vertices->{$u1}->agregar_adyacente($arista);
            $self->vertices->{$u2}->agregar_adyacente($arista);
            
            if ($estado eq 'pendiente') {
                push @{$self->solicitudes}, $arista;
            }
        }
        close $fh;
    }
}

1;


package main;

my $grafo = GrafoAmistades->new();
$grafo->cargar_datos();

app->hook(before_dispatch => sub ($c) {
    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
    $c->res->headers->header('Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS');
    $c->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type, Authorization');
    
    if ($c->req->method eq 'OPTIONS') {
        $c->rendered(200);
        return;
    }
});

get '/' => sub ($c) {
    $c->render(json => {
        mensaje => "API de Red Social - Grafo de Amistades",
        version => "1.0"
    });
};

post '/api/registro' => sub ($c) {
    my $data = $c->req->json;
    my $resultado = $grafo->registrar_usuario($data->{usuario}, $data->{password});
    
    if ($resultado->{success}) {
        $c->render(json => $resultado);
    } else {
        $c->render(json => $resultado, status => 400);
    }
};

post '/api/login' => sub ($c) {
    my $data = $c->req->json;
    my $resultado = $grafo->iniciar_sesion($data->{usuario}, $data->{password});
    
    if ($resultado->{success}) {
        $c->render(json => $resultado);
    } else {
        $c->render(json => $resultado, status => 401);
    }
};

post '/api/amistad/solicitar' => sub ($c) {
    my $data = $c->req->json;
    my $resultado = $grafo->enviar_solicitud($data->{solicitante}, $data->{destinatario});
    
    if ($resultado->{success}) {
        $c->render(json => $resultado);
    } else {
        $c->render(json => $resultado, status => 400);
    }
};

post '/api/amistad/aceptar' => sub ($c) {
    my $data = $c->req->json;
    my $resultado = $grafo->aceptar_solicitud($data->{usuario}, $data->{solicitante});
    
    if ($resultado->{success}) {
        $c->render(json => $resultado);
    } else {
        $c->render(json => $resultado, status => 400);
    }
};

post '/api/amistad/rechazar' => sub ($c) {
    my $data = $c->req->json;
    my $resultado = $grafo->rechazar_solicitud($data->{usuario}, $data->{solicitante});
    $c->render(json => $resultado);
};

get '/api/amigos/:usuario' => sub ($c) {
    my $usuario = $c->stash('usuario');
    my $amigos = $grafo->obtener_amigos($usuario);
    
    $c->render(json => {
        success => 1,
        usuario => $usuario,
        amigos => $amigos,
        total => scalar(@$amigos)
    });
};

get '/api/solicitudes/:usuario' => sub ($c) {
    my $usuario = $c->stash('usuario');
    my $solicitudes = $grafo->obtener_solicitudes_pendientes($usuario);
    
    $c->render(json => {
        success => 1,
        usuario => $usuario,
        solicitudes => $solicitudes,
        total => scalar(@$solicitudes)
    });
};

get '/api/sugerencias/:usuario' => sub ($c) {
    my $usuario = $c->stash('usuario');
    my $sugerencias = $grafo->obtener_sugerencias($usuario);
    
    $c->render(json => {
        success => 1,
        usuario => $usuario,
        sugerencias => $sugerencias,
        total => scalar(@$sugerencias)
    });
};

get '/api/grafo/:usuario' => sub ($c) {
    my $usuario = $c->stash('usuario');
    my $dot_content = $grafo->generar_dot($usuario);
    $c->render(text => $dot_content);
};

get '/api/estadisticas' => sub ($c) {
    my $estadisticas = $grafo->obtener_estadisticas();
    $c->render(json => { success => 1, estadisticas => $estadisticas });
};

# Generar grafo de amistades (formato DOT)
post '/api/grafo/generar' => sub ($c) {
    my $data = $c->req->json // {};
    my $usuario = $data->{usuario} // '';
    my $nombre_archivo = $data->{nombre} // 'grafo_amistades';
    
    my $dot_content = $grafo->generar_dot($usuario);
    
    my $dot_file = "$nombre_archivo.dot";
    open my $fh, '>', $dot_file;
    print $fh $dot_content;
    close $fh;
    
    my $png_file = "$nombre_archivo.png";
    my $comando = "dot -Tpng \"$dot_file\" -o \"$png_file\" 2>/dev/null";
    system($comando);
    
    if (-f $png_file) {
        $c->render(json => {
            success => 1,
            message => "Grafo de amistades generado exitosamente",
            archivos => {
                dot => $dot_file,
                png => $png_file
            }
        });
    } else {
        $c->render(json => {
            success => 0,
            message => "Error al generar el grafo. Asegúrate de tener GraphViz instalado"
        }, status => 500);
    }
};

# Obtener el grafo en formato DOT
get '/api/grafo/dot/:usuario' => sub ($c) {
    my $usuario = $c->stash('usuario');
    my $dot_content = $grafo->generar_dot($usuario);
    
    $c->res->headers->content_type('text/plain');
    $c->render(text => $dot_content);
};

# Obtener la imagen del grafo directamente
get '/api/grafo/imagen/:usuario' => sub ($c) {
    my $usuario = $c->stash('usuario');
    my $temp_nombre = "temp_grafo_" . time();
    my $dot_content = $grafo->generar_dot($usuario);
    
    my $dot_file = "$temp_nombre.dot";
    my $png_file = "$temp_nombre.png";
    
    open my $fh, '>', $dot_file;
    print $fh $dot_content;
    close $fh;
    
    system("dot -Tpng \"$dot_file\" -o \"$png_file\" 2>/dev/null");
    
    if (-f $png_file) {
        $c->res->headers->content_type('image/png');
        open my $img_fh, '<', $png_file;
        binmode $img_fh;
        local $/;
        my $imagen_data = <$img_fh>;
        close $img_fh;
        
        # Limpiar archivos temporales
        unlink $dot_file if -f $dot_file;
        unlink $png_file if -f $png_file;
        
        $c->render(data => $imagen_data);
    } else {
        $c->render(json => {
            success => 0,
            message => "Error al generar el grafo. Instala GraphViz: sudo apt-get install graphviz"
        }, status => 500);
    }
};

# Listar todos los grafos generados
get '/api/grafo/listar' => sub ($c) {
    my @archivos_png = glob("*.png");
    my @archivos_dot = glob("*.dot");
    
    my %grafos_map = ();
    
    foreach my $archivo (@archivos_png) {
        if ($archivo =~ /^(.*)\.png$/) {
            my $nombre = $1;
            next if $nombre =~ /^temp_grafo/;
            $grafos_map{$nombre}->{png} = $archivo;
            $grafos_map{$nombre}->{nombre} = $nombre;
            $grafos_map{$nombre}->{tamaño} = -s $archivo;
            $grafos_map{$nombre}->{modificado} = localtime((stat $archivo)[9]);
        }
    }
    
    foreach my $archivo (@archivos_dot) {
        if ($archivo =~ /^(.*)\.dot$/) {
            my $nombre = $1;
            next if $nombre =~ /^temp_grafo/;
            $grafos_map{$nombre}->{dot} = $archivo;
        }
    }
    
    my @grafos = ();
    foreach my $nombre (keys %grafos_map) {
        push @grafos, {
            nombre => $grafos_map{$nombre}->{nombre},
            png => $grafos_map{$nombre}->{png} // "",
            dot => $grafos_map{$nombre}->{dot} // "",
            tamaño => $grafos_map{$nombre}->{tamaño} // 0,
            modificado => $grafos_map{$nombre}->{modificado} // ""
        };
    }
    
    $c->render(json => {
        success => 1,
        grafos => \@grafos,
        total => scalar(@grafos)
    });
};

# Descargar grafo generado
get '/api/grafo/descargar/:nombre' => sub ($c) {
    my $nombre = $c->stash('nombre');
    my $formato = $c->req->param('formato') // 'png';
    
    my $archivo = "$nombre.$formato";
    
    if (-f $archivo) {
        my $content_type = $formato eq 'png' ? 'image/png' : 'text/plain';
        $c->res->headers->content_type($content_type);
        $c->res->headers->header('Content-Disposition', "attachment; filename=\"$archivo\"");
        
        open my $fh, '<', $archivo;
        binmode $fh;
        local $/;
        my $contenido = <$fh>;
        close $fh;
        
        $c->render(data => $contenido);
    } else {
        $c->render(json => {
            success => 0,
            message => "Archivo $archivo no encontrado"
        }, status => 404);
    }
};

# Eliminar grafo generado
del '/api/grafo/eliminar/:nombre' => sub ($c) {
    my $nombre = $c->stash('nombre');
    
    my $eliminados = 0;
    my $dot_file = "$nombre.dot";
    my $png_file = "$nombre.png";
    
    if (-f $dot_file) {
        unlink $dot_file;
        $eliminados++;
    }
    
    if (-f $png_file) {
        unlink $png_file;
        $eliminados++;
    }
    
    if ($eliminados > 0) {
        $c->render(json => {
            success => 1,
            message => "Se eliminaron $eliminados archivos del grafo '$nombre'"
        });
    } else {
        $c->render(json => {
            success => 0,
            message => "No se encontraron archivos del grafo '$nombre'"
        }, status => 404);
    }
};

get '/api/usuarios' => sub ($c) {
    my @usuarios = keys %{$grafo->vertices};
    my $usuarios_detalle = [];
    
    foreach my $nombre (@usuarios) {
        my $amigos = $grafo->obtener_amigos($nombre);
        push @$usuarios_detalle, {
            nombre => $nombre,
            amigos => scalar(@$amigos)
        };
    }
    
    $c->render(json => {
        success => 1,
        usuarios => $usuarios_detalle,
        total => scalar(@usuarios)
    });
};

my $port = $ENV{MOJO_PORT} // 3005;
say "=========================================";
say "  Red Social API - Servidor Corriendo";
say "=========================================";
say "  Puerto: $port";
say "  URL: http://localhost:$port";
say "=========================================";

app->start('daemon', '-l', "http://*:$port");