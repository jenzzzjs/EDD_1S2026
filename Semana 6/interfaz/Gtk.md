# ¿Qué es GTK? 

GTK (anteriormente conocido como GTK+, GIMP Toolkit) es una biblioteca multiplataforma y de código abierto para crear interfaces gráficas de usuario (GUI) . En términos más sencillos, es un conjunto de herramientas y elementos visuales (como ventanas, botones, cuadros de texto, barras de desplazamiento, etc.) que los programadores utilizan para construir el aspecto interactivo de sus aplicaciones .

Es uno de los toolkits más populares en el mundo Linux, ya que es la base del entorno de escritorio GNOME y de muchas aplicaciones conocidas como GIMP, Inkscape, y el reproductor VLC . Está escrito principalmente en C, pero se puede usar en otros lenguajes como Perl, C++, Python, Rust, y muchos más .

Para Perl, existen bindings (envoltorios) que nos permiten usar GTK directamente desde nuestro código Perl. El módulo principal se llama Gtk3 (para GTK versión 3) y Gtk4 (para GTK versión 4). Estos módulos son parte del proyecto Gtk2-Perl que ha evolucionado para soportar las versiones modernas de GTK.

Actualmente, GTK tiene dos versiones estables que se usan ampliamente: GTK3 y GTK4. GTK4 es la versión más moderna, pero GTK3 sigue siendo muy común en muchas aplicaciones y tiene un soporte más maduro en Perl. En una misma computadora, pueden coexistir ambas versiones sin problema .

Cómo Instalar GTK para Perl en Ubuntu
La instalación requiere dos pasos principales: primero instalar las bibliotecas C de GTK (como viste anteriormente) y luego instalar los módulos de Perl que conectan con esas bibliotecas.

## Paso 1: Preparar el Sistema 

Antes de instalar nuevas bibliotecas, es una buena práctica actualizar la lista de paquetes disponibles para asegurarte de obtener las versiones más recientes y estables. Abre una terminal (Ctrl+Alt+T) y ejecuta:

```perl 
sudo apt update
```

Si planeas programar, también necesitarás las herramientas de compilación básicas, como gcc, g++, make, etc. Puedes instalarlas con el siguiente comando :

```perl
sudo apt install build-essential
```

## Paso 2: Instalar las Bibliotecas de Desarrollo de GTK 

El paquete que necesitas instalar para poder crear aplicaciones con GTK es el que contiene los archivos de desarrollo (encabezados y bibliotecas de enlace). Para Perl, trabajaremos con GTK3 ya que tiene el soporte más estable y maduro.

Ejecuta este comando en tu terminal:

```perl
sudo apt install libgtk-3-dev
```

Este comando instalará no solo GTK 3, sino también todas sus dependencias necesarias, como GLib, Pango, Gdk-Pixbuf y ATK .

## Paso 3: Verificar la Instalación

Una vez finalizada la instalación, puedes comprobar que todo está correcto y ver qué versión se instaló usando la herramienta pkg-config, que es fundamental para compilar programas con GTK . En la terminal, escribe:

```perl
pkg-config --modversion gtk+-3.0
```

Si la instalación fue exitosa, el comando te devolverá el número de la versión instalada (por ejemplo, 3.24.33). Si ves un error, es posible que la instalación no se haya completado correctamente.