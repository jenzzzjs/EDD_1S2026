use strict;
use warnings;

sub evaluar_nota {
    my ($nota) = @_;

    if ($nota >= 61) {
        return "Aprobado";
    } else {
        return "Reprobado";
    }
}

print "Ingrese su nombre: ";
my $nombre = <STDIN>;
chomp($nombre);

print "Ingrese su nota: ";
my $nota = <STDIN>;
chomp($nota);

my $resultado = evaluar_nota($nota);

print "Estudiante: $nombre\n";
print "Resultado: $resultado\n";
