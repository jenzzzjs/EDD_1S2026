package Vertice;
use strict;
use warnings;
use Mojo::Base -base;

has 'nombre' => (is => 'rw', required => 1);
has 'creado' => (is => 'rw', default => sub { time() });
has 'adyacentes' => (is => 'rw', default => sub { [] });

sub agregar_adyacente {
    my ($self, $arista) = @_;
    push @{$self->adyacentes}, $arista;
}

sub obtener_adyacentes {
    my ($self) = @_;
    return @{$self->adyacentes};
}

sub to_string {
    my ($self) = @_;
    return $self->nombre;
}

1;