# Listas Enlazadas

Una lista enlazada es una estructura de datos lineal formada por una secuencia de nodos, donde cada nodo almacena dos elementos principales:
un dato y una referencia (enlace) al siguiente nodo de la lista.

A diferencia de los arreglos, las listas enlazadas no almacenan sus elementos en posiciones contiguas de memoria, sino que cada nodo puede encontrarse en cualquier ubicación, estando conectados entre sí mediante enlaces.

## Características principales

Acceso secuencial a los elementos

Tamaño dinámico

Inserción y eliminación eficientes

No requieren memoria contigua

## Tipos de listas enlazadas

Lista enlazada simple: cada nodo apunta al siguiente

Lista doblemente enlazada: cada nodo apunta al anterior y al siguiente

Lista circular: el último nodo apunta al primero

## ¿Dónde se utilizan?

Las listas enlazadas se utilizan cuando:

Se necesita insertar o eliminar elementos frecuentemente

El tamaño de la estructura cambia durante la ejecución

No se conoce de antemano la cantidad de elementos

Son comunes en:

Implementación de pilas y colas

Manejo de memoria dinámica

Sistemas operativos

Estructuras como listas de adyacencia en grafos

## Ventajas

Inserciones y eliminaciones rápidas

Uso eficiente de memoria dinámica

No requieren reorganizar elementos

## Desventajas

Acceso más lento que los arreglos

Mayor uso de memoria por los enlaces

No permiten acceso directo por índice