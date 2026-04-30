#!/usr/bin/perl
use strict;
use warnings;
use utf8;

# COMPRESIoN LZW
sub comprimir_lzw {
    my ($texto) = @_;
    
    # Inicializar diccionario con caracteres individuales
    my %diccionario;
    my $tamaño_dic = 256;
    
    # Agregar caracteres ASCII básicos que son del 0 al 255
    for my $i (0..255) {
        $diccionario{chr($i)} = $i;
    }
    
    my @salida;
    my $cadena_actual = "";
    
    # recorremos cada carácter del texto
    for my $caracter (split //, $texto) {
        my $nueva_cadena = $cadena_actual . $caracter;
        
        # Si la nueva cadena está en el diccionario, pues continuamos
        if (exists $diccionario{$nueva_cadena}) {
            $cadena_actual = $nueva_cadena;
        } else {
            # agregamos el codigo de la cadena actual a la salida
            push @salida, $diccionario{$cadena_actual};
            
            # Agregar nueva cadena al diccionario
            $diccionario{$nueva_cadena} = $tamaño_dic++;
            $cadena_actual = $caracter;
        }
    }
    
    # Agregar la última cadena
    push @salida, $diccionario{$cadena_actual} if $cadena_actual ne "";
    
    return @salida;
}

# DESCOMPRESIoN LZW
sub descomprimir_lzw {
    my @codigos = @_;
    
    # Inicializar diccionario inverso
    my @diccionario_inverso;
    
    # Agregar caracteres ASCII básicos
    for my $i (0..255) {
        $diccionario_inverso[$i] = chr($i);
    }
    
    my @salida;
    my $cadena_actual = $diccionario_inverso[$codigos[0]];
    push @salida, $cadena_actual;
    
    my $tamaño_dic = 256;
    
    # Procesar Codigos restantes
    for my $i (1..$#codigos) {
        my $codigo = $codigos[$i];
        my $entrada;
        
        if ($codigo < $tamaño_dic) {
            $entrada = $diccionario_inverso[$codigo];
        } else {
            $entrada = $cadena_actual . substr($cadena_actual, 0, 1);
        }
        
        push @salida, $entrada;
        
        # Agregar nueva entrada al diccionario
        $diccionario_inverso[$tamaño_dic++] = $cadena_actual . substr($entrada, 0, 1);
        $cadena_actual = $entrada;
    }
    
    return join "", @salida;
}

# Funcion para guardar Codigos en archivo binario
sub guardar_comprimido {
    my ($archivo, @codigos) = @_;
    open my $fh, '>:raw', $archivo or die "No se puede crear $archivo: $!";
    print $fh pack("N*", @codigos);  # Guardar como enteros de 32 bits
    close $fh;
}

# Funcion para cargar Codigos desde archivo binario
sub cargar_comprimido {
    my ($archivo) = @_;
    open my $fh, '<:raw', $archivo or die "No se puede abrir $archivo: $!";
    my $data = do { local $/; <$fh> };
    close $fh;
    return unpack("N*", $data);
}

# PROGRAMA PRINCIPAL
sub main {
    print "=== PROGRAMA DE COMPRESIoN LZW ===\n";
    print "1. Comprimir texto\n";
    print "2. Descomprimir archivo\n";
    print "3. Ejemplo demostrativo\n";
    print "Elige una opcion: ";
    
    my $opcion = <STDIN>;
    chomp $opcion;
    
    if ($opcion == 1) {
        print "\nIngresa el texto a comprimir: ";
        my $texto = <STDIN>;
        chomp $texto;
        
        my @comprimido = comprimir_lzw($texto);
        
        print "\n--- RESULTADOS ---\n";
        print "Texto original: '$texto'\n";
        print "Longitud original: " . length($texto) . " bytes\n";
        print "Codigos comprimidos: @comprimido\n";
        print "Longitud comprimida: " . scalar(@comprimido) * 4 . " bytes\n";
        print "Tasa de compresion: " . (scalar(@comprimido) * 4 / length($texto) * 100) . "%\n";
        
        # Guardar en archivo
        guardar_comprimido("compresion.lzw", @comprimido);
        print "\nArchivo guardado como 'compresion.lzw'\n";
        
    } elsif ($opcion == 2) {
        print "\nIngresa el archivo a descomprimir: ";
        my $archivo = <STDIN>;
        chomp $archivo;
        
        my @codigos = cargar_comprimido($archivo);
        my $texto = descomprimir_lzw(@codigos);
        
        print "\n--- RESULTADOS ---\n";
        print "Texto descomprimido: '$texto'\n";
        print "Longitud: " . length($texto) . " bytes\n";
        
    } elsif ($opcion == 3) {
        # Ejemplo demostrativo
        my $ejemplo = "ABABABABA";
        print "\nEjemplo con texto: '$ejemplo'\n\n";
        
        print "--- PROCESO DE COMPRESIoN ---\n";
        my @codigos = comprimir_lzw($ejemplo);
        print "Codigos generados: @codigos\n";
        
        print "\n--- PROCESO DE DESCOMPRESIoN ---\n";
        my $resultado = descomprimir_lzw(@codigos);
        print "Texto recuperado: '$resultado'\n";
        
        if ($ejemplo eq $resultado) {
            print "\n✓ COMPROBACIoN EXITOSA\n";
        }
    }
}

# Ejecutar programa
main();