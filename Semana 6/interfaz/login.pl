use strict;
use warnings;
use Gtk3 '-init';

# credenciales para el uso del login
my $USUARIO_VALIDO = "jens";
my $PASSWORD_VALIDO = "202102771";

# creamos la ventana principal del login
my $ventana_login = Gtk3::Window->new('toplevel');
$ventana_login->set_title('L O G I N'); #este sera el titulo que le vamos a colocar a la pestaña
$ventana_login->set_default_size(350, 250); #aca definimos el tamaño que le vamos a dar a la ventana
$ventana_login->set_border_width(20); #esto es el margen inferior al rededor del contenido
$ventana_login->set_position('center'); #con esto centramos la pantalla en el centro
$ventana_login->signal_connect('destroy' => sub { Gtk3->main_quit(); });

# Creamos un contenedor principal de forma vertical, en el cual es una caja
# que organiza los widgets de forma vertical siendo de parametro 10 que es el espacio entre los elementos hijos
my $contenedor = Gtk3::Box->new('vertical', 10);

# titulo
my $titulo = Gtk3::Label->new(); #creamos una etiqueta vacia
$titulo->set_markup('<span size="x-large" weight="bold"> Iniciar sesion</span>');#caracteristicas del texto, tamaño, texto en si
$contenedor->pack_start($titulo, 0, 0, 10); #agregamos el titulo al contenedor principal

# frame para los campos
my $frame = Gtk3::Frame->new(' Credenciales '); #creamos un marco o frame para el titulo de credenciales
$frame->set_shadow_type('etched-in'); #cuestiones esteticas de sombreado nada mas
$contenedor->pack_start($frame, 0, 0, 5); #agregamos al contenedor principal 

# Grid para organizar campos
my $grid = Gtk3::Grid->new(); #esto crea una cuadricula para organizar los widgets tanto en filas como en columnas
$grid->set_row_spacing(10); #es el espacio entre filas
$grid->set_column_spacing(10); #es el espacio entre columnas
$grid->set_border_width(15); #es el espacio alrededor de la cuadricula
$frame->add($grid); #agrega la cuadricula dentro del marco

# etiqueta y campo de usuario
my $label_usuario = Gtk3::Label->new('Usuario:');
$label_usuario->set_xalign(1.0);  # alineamos a la derecha
$grid->attach($label_usuario, 0, 0, 1, 1);

my $entry_usuario = Gtk3::Entry->new();
$entry_usuario->set_placeholder_text('Ingresa tu usuario');
$grid->attach($entry_usuario, 1, 0, 1, 1);

# etiqueta y campo de contrasenia
my $label_password = Gtk3::Label->new('contrasenia:');
$label_password->set_xalign(1.0);
$grid->attach($label_password, 0, 1, 1, 1);

my $entry_password = Gtk3::Entry->new();
$entry_password->set_placeholder_text('Ingresa tu contrasenia');
$entry_password->set_visibility(0);  # ocultamos los caracteres cuando se ingresa la contraseña
$grid->attach($entry_password, 1, 1, 1, 1);

# etiqueta para el manejo tanto de errores como de exito
my $mensaje = Gtk3::Label->new('');
$mensaje->set_markup('<span foreground="red"></span>');
$contenedor->pack_start($mensaje, 0, 0, 5);

# caja para botones
my $caja_botones = Gtk3::Box->new('horizontal', 10);
$contenedor->pack_start($caja_botones, 0, 0, 10);

# boton de login
my $boton_login = Gtk3::Button->new('Iniciar Sesion');
$boton_login->set_size_request(120, 35);
$caja_botones->pack_start($boton_login, 1, 1, 0);

# boton para limpiar los campos 
my $boton_limpiar = Gtk3::Button->new('Limpiar');
$boton_limpiar->set_size_request(100, 35);
$caja_botones->pack_start($boton_limpiar, 1, 1, 0);

# agregamos todo a la ventana 
$ventana_login->add($contenedor);

# funcion para limpiar los campos
sub limpiar_campos {
    $entry_usuario->set_text('');
    $entry_password->set_text('');
    $mensaje->set_markup('');
    $entry_usuario->grab_focus();
}

# funcion para crear la nueva ventana luego de ingresar las credenciales correctas
sub ventana_2 {
    # creamos la ventana con el contenido correspondiente
    my $ventana_dos = Gtk3::Window->new('toplevel');
    $ventana_dos->set_title('Bienvenido');
    $ventana_dos->set_default_size(300, 150);
    $ventana_dos->set_position('center');
    $ventana_dos->set_border_width(20);
    
    # la ventana 2 siempre estara por encima
    $ventana_dos->set_keep_above(1);
    
    # si se cierra esta ventana el programa seguira funcionando de forma normal
    $ventana_dos->signal_connect('destroy' => sub {
        # No hacer nada, solo cerrar esta ventana
    });
    
    # Contenedor vertical
    my $box = Gtk3::Box->new('vertical', 15);
    
    # Mensaje de exito
    my $label_exito = Gtk3::Label->new();
    $label_exito->set_markup('<span¡Bienvenido!</span>');
    $box->pack_start($label_exito, 1, 1, 10);
    
    # etiqueta principal de la ventana
    my $label_edd = Gtk3::Label->new();
    $label_edd->set_markup('<span size="large" foreground="blue">ya no sale edd</span>'); #el mensaje que deberia de aparecer
    $box->pack_start($label_edd, 1, 1, 5);
    
    # mensaje con el usuario iniciado
    my $usuario = $entry_usuario->get_text();
    my $label_usuario_bienvenida = Gtk3::Label->new("Has iniciado sesion como: $usuario");
    $box->pack_start($label_usuario_bienvenida, 0, 0, 5);
    
    # boton para cerrar
    my $boton_cerrar = Gtk3::Button->new('Cerrar');
    $boton_cerrar->signal_connect('clicked' => sub { $ventana_dos->destroy(); });
    $box->pack_start($boton_cerrar, 0, 0, 10);
    
    $ventana_dos->add($box);
    $ventana_dos->show_all();
}

# funcion para validar login
sub validar_login {
    #obtenemos las credenciales de los campos del frame
    my $usuario = $entry_usuario->get_text();
    my $password = $entry_password->get_text();
    
    # Eliminar espacios en blanco al inicio y final
    $usuario =~ s/^\s+|\s+$//g;
    $password =~ s/^\s+|\s+$//g;
    
    # Validar credenciales
    if ($usuario eq $USUARIO_VALIDO && $password eq $PASSWORD_VALIDO) {
        $mensaje->set_markup(' ¡Login exitoso!');
        
        # Pequeña pausa para mostrar el mensaje de éxito
        Glib::Timeout->add(500, sub {
            ventana_2();
            return 0;  # No repetir
        });
        
        #si queremos limpiar los campos luego de iniciar sesion unicamente llamamos la funcion para limpiar los campos
        #limpiar_campos();
        
    } else {
        $mensaje->set_markup('<span foreground="red"> Usuario o contrasenia incorrectos</span>');
        $entry_password->set_text('');  # Limpiar solo la contraseña
        $entry_password->grab_focus();  # nos enfocamos solo en la contraseña
        $entry_usuario->set_text('');   # limpiamos el campo de usuario
        $entry_usuario->grab_focus();   # ahora si nos enfocamos en ambos campos
        

    }
}

# Conectar señales
$boton_login->signal_connect('clicked' => \&validar_login);
$boton_limpiar->signal_connect('clicked' => \&limpiar_campos);

# Permitir presionar Enter para iniciar sesion
$entry_usuario->signal_connect('activate' => \&validar_login);
$entry_password->signal_connect('activate' => \&validar_login);

# Mostrar todo
$ventana_login->show_all();

# Iniciar el bucle principal de GTK
Gtk3->main();

print "Programa finalizado\n";