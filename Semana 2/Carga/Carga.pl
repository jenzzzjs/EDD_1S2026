use strict;
use warnings;
use Text::CSV;  

my @datos;
my $cargado = 0;
my $csv;

print "\n \n";
print "===================================\n\n";


$csv = Text::CSV->new({
    binary    => 1,           
    auto_diag => 1,           
    sep_char  => ',',         
    quote_char => '"',        
    escape_char => '"',       
    allow_whitespace => 1,    
});

while (1) {
    print "\nMENU PRINCIPAL:\n";
    print "1. Cargar archivo CSV \n";
    print "2. Ver contenido\n";
    print "3. Mostrar contenido parseado\n";
    print "4. Salir\n";
    print "\nSeleccione opción (1-4): ";
    
    my $op = <STDIN>;
    chomp $op;
    
    if ($op == 1) {
        print "\nIngrese nombre del archivo CSV: ";
        my $archivo = <STDIN>;
        chomp $archivo;
        
        if (!-e $archivo) {
            print "Error: Archivo no encontrado.\n";
            next;
        }
        
        open(my $fh, '<:encoding(utf8)', $archivo) or do {
            print "Error al abrir archivo: $!\n";
            next;
        };
        
        @datos = ();
        my $linea_num = 0;
        
        while (my $fila = $csv->getline($fh)) {
            
            push @datos, $fila;
            $linea_num++;
        }
        
        
        if ($csv->error_diag()) {
            print "Advertencia: " . $csv->error_diag() . "\n";
        }
        
        close($fh);
        
        $cargado = 1;
        print "\n✓ Archivo cargadO\n";
        print "✓ Líneas procesadas: $linea_num\n";
        
        if (@datos > 0) {
            print "✓ Campos por línea: " . scalar(@{$datos[0]}) . "\n";
            print "✓ Ejemplo de primera línea:\n";
            print "  " . join(" | ", @{$datos[0]}) . "\n";
        }
    }
    elsif ($op == 2) {
        if (!$cargado) {
            print "\nPrimero cargue un archivo (opción 1)\n";
            next;
        }
        
        print "\n=== CONTENIDO DEL ARCHIVO ===\n";
        for my $i (0..$#datos) {
            my $num_campos = scalar(@{$datos[$i]});
            print "Línea $i ($num_campos campos): " . join(" | ", @{$datos[$i]}) . "\n";
        }
    }
    elsif ($op == 3) {
        if (!$cargado) {
            print "\nPrimero cargue un archivo (opción 1)\n";
            next;
        }
        
        print "\n=== DATOS PARSEADOS ===\n\n";
        
        my $inicio = 0;
        my $es_encabezado = 0;
        
        if (@datos > 0) {
            my $primer_valor = $datos[0][0] // '';
            if ($primer_valor =~ /^codigo|code|id$/i) {
                $es_encabezado = 1;
                $inicio = 1;
                print "(Mostrando datos, omitiendo encabezados)\n";
            }
        }
        
        print "\n";
        print "+----------+----------------------+---------+----------+--------------+\n";
        print "| Código   | Nombre               | Precio  | Cantidad | Distribuidor |\n";
        print "+----------+----------------------+---------+----------+--------------+\n";
        
        my $registros_validos = 0;
        
        for my $i ($inicio..$#datos) {
            my $fila = $datos[$i];
            my $num_campos = scalar(@$fila);
            
            if ($num_campos < 5) {
                print "| ⚠ Línea $i: Solo $num_campos campos" . " " x (53 - length($i) - length($num_campos)) . "|\n";
                next;
            }
            
            printf "| %-9s| %-21s| %-8s| %-9s| %-13s|\n",
                   $fila->[0] // '', 
                   $fila->[1] // '', 
                   $fila->[2] // '', 
                   $fila->[3] // '', 
                   $fila->[4] // '';
            
            $registros_validos++;
        }
        
        print "+----------+----------------------+---------+----------+--------------+\n";
        
        print "\n" . "=" x 65 . "\n";
        print "ESTADÍSTICAS:\n";
        print "  - Total de líneas: " . scalar(@datos) . "\n";
        print "  - Registros mostrados: $registros_validos\n";
        if ($es_encabezado) {
            print "  - Encabezado: 1 línea\n";
        }
    }
    elsif ($op == 4) {
        print "\n¡Gracias por usar el sistema!\n";
        exit;
    }
    else {
        print "\nOpción inválida. Intente de nuevo.\n";
    }
}