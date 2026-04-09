package Arista;
use strict;
use warnings;
use Mojo::Base -base;

has 'origen' => (is => 'rw', required => 1);
has 'destino' => (is => 'rw', required => 1);
has 'distancia' => (is => 'rw', required => 1);
has 'creado' => (is => 'rw', default => sub { time() });

sub to_hash {
    my ($self) = @_;
    return {
        origen => $self->origen->nombre,
        destino => $self->destino->nombre,
        distancia => $self->distancia
    };
}

sub equals {
    my ($self, $origen_nombre, $destino_nombre) = @_;
    return ($self->origen->nombre eq $origen_nombre && 
            $self->destino->nombre eq $destino_nombre);
}

1;