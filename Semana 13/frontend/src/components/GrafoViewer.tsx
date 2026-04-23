import React, { useState, useEffect } from 'react';
import { Download, Trash2, Eye, Loader2, Image as ImageIcon, FileText } from 'lucide-react';
import { grafoService } from '../services/api';
import type { GrafoGenerado } from '../services/api';

interface GrafoViewerProps {
  usuario: string;
}

const GrafoViewer: React.FC<GrafoViewerProps> = ({ usuario }) => {
  const [grafos, setGrafos] = useState<GrafoGenerado[]>([]);
  const [loading, setLoading] = useState(false);
  const [generando, setGenerando] = useState(false);
  const [imagenActual, setImagenActual] = useState<string | null>(null);
  const [nombreGrafo, setNombreGrafo] = useState('');

  const cargarGrafos = async () => {
    setLoading(true);
    try {
      const response = await grafoService.listarGrafos();
      if (response.data.success) {
        setGrafos(response.data.grafos);
      }
    } catch (error) {
      console.error('Error cargando grafos:', error);
    } finally {
      setLoading(false);
    }
  };

  const generarGrafo = async () => {
    if (!nombreGrafo.trim()) {
      alert('Ingresa un nombre para el grafo');
      return;
    }
    setGenerando(true);
    try {
      const response = await grafoService.generarGrafo(usuario, nombreGrafo);
      if (response.data.success) {
        alert('Grafo generado exitosamente');
        setNombreGrafo('');
        cargarGrafos();
      } else {
        alert(response.data.message);
      }
    } catch (error) {
      alert('Error al generar el grafo');
    } finally {
      setGenerando(false);
    }
  };

  const verImagen = async (nombre: string) => {
    try {
      const response = await grafoService.descargarGrafo(nombre, 'png');
      const url = URL.createObjectURL(response.data);
      setImagenActual(url);
    } catch (error) {
      alert('Error al cargar la imagen');
    }
  };

  const descargar = async (nombre: string, formato: 'png' | 'dot') => {
    try {
      const response = await grafoService.descargarGrafo(nombre, formato);
      const url = URL.createObjectURL(response.data);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${nombre}.${formato}`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    } catch (error) {
      alert('Error al descargar el archivo');
    }
  };

  const eliminarGrafo = async (nombre: string) => {
    if (confirm(`¿Eliminar el grafo "${nombre}"?`)) {
      try {
        await grafoService.eliminarGrafo(nombre);
        cargarGrafos();
        alert('Grafo eliminado');
      } catch (error) {
        alert('Error al eliminar');
      }
    }
  };

  useEffect(() => {
    cargarGrafos();
  }, []);

  return (
    <div className="space-y-6">
      {/* Modal de imagen */}
      {imagenActual && (
        <div className="fixed inset-0 bg-black/80 z-50 flex items-center justify-center p-4" onClick={() => setImagenActual(null)}>
          <div className="max-w-4xl max-h-full" onClick={(e) => e.stopPropagation()}>
            <img src={imagenActual} alt="Grafo" className="max-w-full max-h-screen rounded-lg" />
            <button
              onClick={() => setImagenActual(null)}
              className="absolute top-4 right-4 bg-red-500 text-white p-2 rounded-full"
            >
              Cerrar
            </button>
          </div>
        </div>
      )}

      {/* Generar nuevo grafo */}
      <div className="bg-gray-800/30 rounded-lg p-6 border border-purple-500/30">
        <h3 className="text-xl font-bold mb-4">Generar Grafo de Amistades</h3>
        <div className="flex gap-4">
          <input
            type="text"
            placeholder="Nombre del grafo"
            value={nombreGrafo}
            onChange={(e) => setNombreGrafo(e.target.value)}
            className="flex-1 px-4 py-2 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:border-purple-500 text-white"
          />
          <button
            onClick={generarGrafo}
            disabled={generando}
            className="px-6 py-2 bg-purple-500 rounded-lg hover:bg-purple-600 transition-colors disabled:opacity-50 flex items-center gap-2"
          >
            {generando ? <Loader2 className="w-4 h-4 animate-spin" /> : <Eye className="w-4 h-4" />}
            {generando ? 'Generando...' : 'Generar Grafo'}
          </button>
        </div>
        <p className="text-xs text-gray-400 mt-2">El grafo muestra todas las amistades aceptadas como un grafo no dirigido</p>
      </div>

      {/* Lista de grafos generados */}
      <div className="bg-gray-800/30 rounded-lg p-6 border border-blue-500/30">
        <h3 className="text-xl font-bold mb-4">Grafos Generados</h3>
        
        {loading ? (
          <div className="flex justify-center py-8">
            <Loader2 className="w-8 h-8 animate-spin text-blue-400" />
          </div>
        ) : grafos.length === 0 ? (
          <div className="text-center py-8 text-gray-400">
            <ImageIcon className="w-16 h-16 mx-auto mb-4 opacity-50" />
            <p>No hay grafos generados aún</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {grafos.map((grafo) => (
              <div key={grafo.nombre} className="bg-gray-900 rounded-lg p-4 border border-gray-700">
                <div className="flex items-center justify-between mb-3">
                  <h4 className="font-semibold text-lg">{grafo.nombre}</h4>
                  <span className="text-xs text-gray-400">{grafo.modificado}</span>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => verImagen(grafo.nombre)}
                    className="flex-1 px-3 py-2 bg-blue-500 rounded-lg hover:bg-blue-600 transition-colors flex items-center justify-center gap-2"
                  >
                    <Eye className="w-4 h-4" />
                    Ver
                  </button>
                  <button
                    onClick={() => descargar(grafo.nombre, 'png')}
                    className="px-3 py-2 bg-green-500 rounded-lg hover:bg-green-600 transition-colors"
                    title="Descargar PNG"
                  >
                    <ImageIcon className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => descargar(grafo.nombre, 'dot')}
                    className="px-3 py-2 bg-yellow-500 rounded-lg hover:bg-yellow-600 transition-colors"
                    title="Descargar DOT"
                  >
                    <FileText className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => eliminarGrafo(grafo.nombre)}
                    className="px-3 py-2 bg-red-500 rounded-lg hover:bg-red-600 transition-colors"
                    title="Eliminar"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default GrafoViewer;