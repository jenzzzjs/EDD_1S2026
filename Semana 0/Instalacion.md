## SEMANA 1 

## QUE ES PERL?

Perl es un lenguaje de programación interpretado, de alto nivel y muy flexible.

Se creó para procesar texto y archivos, por eso es excelente para:

Manejo de strings

expresiones regulares

Lectura y escritura de archivos

Automatización de tareas

Perl se ejecuta directamente desde el código fuente (no se compila como C/C++) y es muy usado en:

scripts del sistema

análisis de datos

administración de servidores

procesamiento de logs

Es un lenguaje potente, práctico y expresivo, muy común en entornos Unix/Linux y en materias universitarias relacionadas con estructuras de datos y procesamiento de texto.


## Instalacion de Perl

como primer paso instalaremos Perl en linux

## 1. realizamos un update en la terminal


``` perl
sudo apt update
```

## 2. Realizamos la instalacion de perl

``` perl
sudo apt install -y perl
```
## 3. Verificamos que se haya instalado correctamente

``` perl
perl -v
```

deberia de retornarles algo como esto

```
➜  EDD_1S2026 git:(main) ✗ perl -v


This is perl 5, version 38, subversion 2 (v5.38.2) built for x86_64-linux-gnu-thread-multi
(with 51 registered patches, see perl -V for more detail)

Copyright 1987-2023, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at https://www.perl.org/, the Perl Home Page.

➜  EDD_1S2026 git:(main) ✗ 
```

## 4. Hola mundo en perl

para poder comprobar que se instalo correctamente procedemos a realizar un pequeño hola mundo y verificar la salida

4.1 nos ubicamos en la semana 1 del curso dentro de nuestro editor de codigo

4.2 unicamente colocamos el siguiente comando en la terminal

```
perl hola.pl
```

y listo, podemos observar el mensaje generado con perl, en este caso es un simple hola mundo

```
➜  Semana 1 git:(main) perl hola.pl                       
Hola mundo desde Perl
➜  Semana 1 git:(main) 
```