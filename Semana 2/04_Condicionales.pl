use strict;
use warnings;

print "Ingrese su nota: ";
my $nota = <STDIN>;
chomp($nota);

if ($nota >= 61) {
    print "Aprobado\n";
} else {
    print "Reprobado\n";
}
