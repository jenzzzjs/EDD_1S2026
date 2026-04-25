// src/pages/EstadisticasHash.tsx
import React, { useState, useEffect } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Database, AlertTriangle, TrendingUp, Layers, BookOpen } from 'lucide-react';
import { estudiantesService } from '../services/api';
import type { EstadisticasHash as EstadisticasHashType, SlotInfo } from '../services/api';

// IMPORTANTE: El componente debe ser exportado como valor, no como tipo
const EstadisticasHash: React.FC = () => {
  const [estadisticas, setEstadisticas] = useState<EstadisticasHashType | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    cargarEstadisticas();
  }, []);

  const cargarEstadisticas = async () => {
    try {
      const response = await estudiantesService.obtenerEstadisticas();
      if (response.data.success) {
        setEstadisticas(response.data.estadisticas);
      }
    } catch (error) {
      console.error('Error cargando estadísticas:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <div className="w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  if (!estadisticas) return null;

  const datosGrafico = estadisticas.slots.map(slot => ({
    nombre: slot.cursos.split(',')[0] || `Slot ${slot.indice}`,
    estudiantes: slot.cantidad_estudiantes,
    colisiones: slot.colisiones_estudiantes,
    cursos: slot.cantidad_cursos
  }));

  const totalColisiones = estadisticas.slots.reduce((sum, slot) => sum + slot.colisiones_estudiantes, 0);

  return (
    <div className="space-y-6">
      {/* Tarjetas de resumen */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-gradient-to-r from-blue-900/50 to-black rounded-lg p-4 border border-blue-500/30">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-400 text-sm">Total Estudiantes</p>
              <p className="text-3xl font-bold">{estadisticas.total_estudiantes}</p>
            </div>
            <Database className="w-8 h-8 text-blue-400" />
          </div>
        </div>
        
        <div className="bg-gradient-to-r from-green-900/50 to-black rounded-lg p-4 border border-green-500/30">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-400 text-sm">Total Cursos</p>
              <p className="text-3xl font-bold">{estadisticas.total_cursos}</p>
            </div>
            <BookOpen className="w-8 h-8 text-green-400" />
          </div>
        </div>
        
        <div className="bg-gradient-to-r from-yellow-900/50 to-black rounded-lg p-4 border border-yellow-500/30">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-400 text-sm">Capacidad (Slots)</p>
              <p className="text-3xl font-bold">{estadisticas.capacidad}</p>
            </div>
            <Layers className="w-8 h-8 text-yellow-400" />
          </div>
        </div>
        
        <div className="bg-gradient-to-r from-purple-900/50 to-black rounded-lg p-4 border border-purple-500/30">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-400 text-sm">Factor de Carga</p>
              <p className="text-3xl font-bold">{estadisticas.factor_carga}</p>
            </div>
            <TrendingUp className="w-8 h-8 text-purple-400" />
          </div>
        </div>
      </div>

      {/* Gráfico de distribución */}
      <div className="bg-gray-800/30 rounded-lg p-6 border border-blue-500/30">
        <h3 className="text-xl font-bold mb-4">Distribución por Slot</h3>
        <ResponsiveContainer width="100%" height={400}>
          <BarChart data={datosGrafico}>
            <CartesianGrid strokeDasharray="3 3" stroke="#333" />
            <XAxis dataKey="nombre" stroke="#888" />
            <YAxis stroke="#888" />
            <Tooltip contentStyle={{ backgroundColor: '#1a1a2e', border: '1px solid #333' }} />
            <Legend />
            <Bar dataKey="estudiantes" fill="#3b82f6" name="Estudiantes" />
            <Bar dataKey="colisiones" fill="#ef4444" name="Colisiones" />
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Detalle de slots */}
      <div className="bg-gray-800/30 rounded-lg p-6 border border-purple-500/30">
        <h3 className="text-xl font-bold mb-4">Detalle de Slots (Tabla Hash)</h3>
        <div className="space-y-3">
          {estadisticas.slots.map((slot) => (
            <div key={slot.indice} className="bg-gray-900 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <div>
                  <span className="font-mono text-sm text-gray-400">Slot {slot.indice}</span>
                  <span className="ml-3 font-bold text-lg">{slot.cursos}</span>
                </div>
                <div className="flex space-x-4">
                  <span className="text-blue-400">📚 {slot.cantidad_estudiantes} estudiantes</span>
                  <span className="text-green-400">📖 {slot.cantidad_cursos} cursos</span>
                  {slot.colisiones_estudiantes > 0 && (
                    <span className="text-yellow-400">⚠️ {slot.colisiones_estudiantes} colisiones</span>
                  )}
                </div>
              </div>
              <div className="w-full bg-gray-700 rounded-full h-2">
                <div 
                  className="bg-blue-500 rounded-full h-2 transition-all"
                  style={{ width: `${estadisticas.total_estudiantes > 0 ? (slot.cantidad_estudiantes / estadisticas.total_estudiantes) * 100 : 0}%` }}
                />
              </div>
              {slot.esta_vacio && (
                <p className="text-gray-500 text-sm mt-2">Slot vacío</p>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Explicación de la Tabla Hash */}
      <div className="bg-gradient-to-r from-purple-900/20 to-black rounded-lg p-6 border border-purple-500/30">
        <h3 className="text-xl font-bold mb-3">📖 ¿Cómo funciona la Tabla Hash?</h3>
        <div className="space-y-2 text-gray-300">
          <p><strong>Función Hash:</strong> Curso → Índice (0-9)</p>
          <p><strong>Colisiones:</strong> Cuando múltiples cursos caen en el mismo slot</p>
          <p><strong>Solución:</strong> Encadenamiento separado - múltiples cursos por slot</p>
          <p><strong>Estudiantes:</strong> Se almacenan con LIFO (pila) dentro de cada curso</p>
          <p><strong>Complejidad:</strong> O(1) promedio, O(n) peor caso</p>
        </div>
      </div>
    </div>
  );
};

// Exportación por defecto del componente (valor, no tipo)
export default EstadisticasHash;