#!/bin/bash

# Instalar GraphViz si no está instalado
if ! command -v dot &> /dev/null; then
    echo "Instalando GraphViz..."
    sudo apt install -y graphviz
fi

# Limpiar el puerto si está en uso
PORT=${1:-3004}
echo "Usando puerto: $PORT"

# Matar cualquier proceso en el puerto
lsof -ti:$PORT | xargs kill -9 2>/dev/null

# Crear directorio lib si no existe
mkdir -p lib/Grafos

case "$1" in
    dev)
        echo "Iniciando servidor en modo desarrollo en puerto 3004..."
        MOJO_PORT=3004 morbo -l "http://*:3004" script/servidor
        ;;
    prod)
        echo "Iniciando servidor en modo producción en puerto 3004..."
        MOJO_PORT=3004 perl script/servidor
        ;;
    *)
        echo "Iniciando servidor en puerto 3004..."
        MOJO_PORT=3004 perl script/servidor
        ;;
esac