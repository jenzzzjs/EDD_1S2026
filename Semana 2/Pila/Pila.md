# Pilas

Una pila es una estructura de datos lineal que almacena elementos siguiendo el principio **LIFO** (*Last In, First Out*), es decir, el último elemento que se inserta es el primero en salir.

Las pilas permiten el acceso únicamente al elemento que se encuentra en la parte superior, por lo que no es posible acceder directamente a elementos intermedios.

## Características principales

Acceso restringido al elemento superior

Inserción y eliminación en un solo extremo (tope)

Funcionamiento bajo el principio LIFO

Puede implementarse con arreglos o listas enlazadas

## Operaciones básicas

Push: inserta un elemento en la parte superior de la pila

Pop: elimina el elemento superior de la pila

Peek o Top: obtiene el elemento superior sin eliminarlo

IsEmpty: verifica si la pila está vacía

## Tipos de pilas

Pila estática: tamaño fijo definido al inicio

Pila dinámica: tamaño variable durante la ejecución

Pila implementada con arreglos

Pila implementada con listas enlazadas

## ¿Dónde se utilizan?

Las pilas se utilizan cuando:

Se requiere controlar el orden de ejecución

Se necesita revertir información

Se manejan procesos de forma jerárquica

Son comunes en:

Llamadas a funciones (pila de ejecución)

Deshacer y rehacer acciones (Undo / Redo)

Evaluación de expresiones matemáticas

Conversión de expresiones (infija a postfija)

Navegación entre páginas

## Ventajas

Implementación sencilla

Inserción y eliminación eficientes

Buen control del flujo de ejecución

## Desventajas

Acceso limitado a los datos

No permiten acceso aleatorio

Posible desbordamiento si se usa una pila estática
