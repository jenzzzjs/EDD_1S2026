// src/pages/VisualizarHash.tsx
import React, { useState } from 'react';
import { RefreshCw, Image as ImageIcon } from 'lucide-react';
import { estudiantesService } from '../services/api';

const VisualizarHash: React.FC = () => {
  const [imagenUrl, setImagenUrl] = useState<string>('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const generarGrafo = async () => {
    setLoading(true);
    setError('');
    setImagenUrl('');
    
    try {
      // Limpiar URL anterior si existe
      if (imagenUrl) {
        URL.revokeObjectURL(imagenUrl);
      }
      
      const response = await estudiantesService.visualizarHash();
      const blob = response.data;
      const url = URL.createObjectURL(blob);
      setImagenUrl(url);
    } catch (err: any) {
      console.error('Error generando grafo:', err);
      setError(err.response?.data?.message || 'Error al generar el grafo. Asegúrate que GraphViz esté instalado.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="bg-gray-800/30 rounded-lg p-6 border border-blue-500/30">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-xl font-bold">Visualización de la Tabla Hash</h3>
          <button
            onClick={generarGrafo}
            disabled={loading}
            className="px-4 py-2 bg-blue-500 rounded-lg hover:bg-blue-600 transition-colors flex items-center space-x-2 disabled:opacity-50"
          >
            {loading ? (
              <RefreshCw className="w-4 h-4 animate-spin" />
            ) : (
              <ImageIcon className="w-4 h-4" />
            )}
            <span>{loading ? 'Generando...' : 'Generar Grafo'}</span>
          </button>
        </div>
        
        {error && (
          <div className="p-4 bg-red-500/20 border border-red-500 rounded-lg text-red-400">
            <p className="font-semibold">Error:</p>
            <p className="text-sm">{error}</p>
            <p className="text-sm mt-2">
              💡 Para solucionarlo, instala GraphViz:<br/>
              <code className="bg-gray-900 px-2 py-1 rounded">sudo apt-get install graphviz</code> (Linux)<br/>
              <code className="bg-gray-900 px-2 py-1 rounded">brew install graphviz</code> (Mac)
            </p>
          </div>
        )}
        
        {imagenUrl && (
          <div className="mt-4 p-4 bg-gray-900 rounded-lg overflow-x-auto">
            <img 
              src={imagenUrl} 
              alt="Tabla Hash - Grafo" 
              className="max-w-full mx-auto"
            />
          </div>
        )}
        
        <div className="mt-4 p-3 bg-blue-500/20 rounded-lg">
          <p className="text-sm text-blue-300">
             El grafo muestra la estructura completa de la Tabla Hash:
          </p>
          <ul className="text-sm text-gray-300 mt-2 list-disc list-inside">
            <li>Cada <strong>Slot</strong> representa una curso (Ingenieria, Medicina, Derecho, Arquitectura)</li>
            <li>Las <strong>colisiones</strong> ocurren cuando múltiples estudiantes están en el mismo slot</li>
            <li>El <strong>encadenamiento separado</strong> resuelve las colisiones usando listas enlazadas</li>
            <li>Los estudiantes se muestran conectados a su slot correspondiente</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default VisualizarHash;