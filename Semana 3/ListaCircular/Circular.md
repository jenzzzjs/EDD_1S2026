# Listas Circulares

Una lista circular es una variante de la lista enlazada en la que el último nodo apunta nuevamente al primer nodo, formando un ciclo.
Esto elimina la noción de inicio y fin tradicionales, permitiendo recorrer la estructura de manera continua.

## Características principales

El último nodo enlaza con el primero

No existe un nodo final con valor NULL

Recorrido continuo de la estructura

Puede ser simple o doblemente enlazada

## Tipos de listas circulares

Lista circular simple: cada nodo apunta únicamente al siguiente

Lista circular doble: cada nodo apunta al siguiente y al anterior, formando un ciclo bidireccional

## ¿Dónde se utilizan?

Las listas circulares se emplean cuando se requiere un recorrido repetitivo o cíclico de los datos, por ejemplo:

Planificadores de procesos en sistemas operativos

Implementación de colas circulares

Algoritmos de round-robin

Juegos y aplicaciones con turnos rotativos

## Ventajas

Permiten recorrer la lista indefinidamente

Inserciones eficientes en cualquier posición

No se necesita verificar el final de la lista

Uso eficiente en estructuras cíclicas

## Desventajas

Mayor complejidad en su implementación

Riesgo de bucles infinitos si no se controlan los recorridos

Depuración más difícil que en listas simples