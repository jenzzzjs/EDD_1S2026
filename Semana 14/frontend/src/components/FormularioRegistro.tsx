// src/components/FormularioRegistro.tsx
import React, { useState, useEffect } from 'react';
import { Save, Loader2, AlertCircle, CheckCircle } from 'lucide-react';
import { estudiantesService, cursosService } from '../services/api';
import type { Curso } from '../services/api';

interface FormularioRegistroProps {
  onRegistroExitoso: () => void;
}

const FormularioRegistro: React.FC<FormularioRegistroProps> = ({ onRegistroExitoso }) => {
  const [cursos, setCursos] = useState<Curso[]>([]);
  const [formData, setFormData] = useState({
    carnet: '',
    nombre: '',
    edad: '',
    curso: '',
    semestre: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [hashInfo, setHashInfo] = useState<{ slot: number; colision: boolean } | null>(null);

  useEffect(() => {
    cargarCursos();
  }, []);

  const cargarCursos = async () => {
    try {
      const response = await cursosService.listar();
      if (response.data.success) {
        setCursos(response.data.cursos);
      }
    } catch (error) {
      console.error('Error cargando cursos:', error);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setHashInfo(null);
    setLoading(true);

    try {
      const response = await estudiantesService.registrar({
        carnet: formData.carnet,
        nombre: formData.nombre,
        edad: parseInt(formData.edad),
        curso: formData.curso,
        semestre: parseInt(formData.semestre)
      });

      if (response.data.success) {
        setSuccess('Estudiante registrado exitosamente');
        setHashInfo({
          slot: response.data.hash_info.slot,
          colision: response.data.hash_info.colision
        });
        setFormData({ carnet: '', nombre: '', edad: '', curso: '', semestre: '' });
        onRegistroExitoso();
        setTimeout(() => setSuccess(''), 3000);
      } else {
        setError(response.data.message);
        setTimeout(() => setError(''), 5000);
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al registrar');
      setTimeout(() => setError(''), 5000);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-gray-300 mb-2">Carnet</label>
          <input
            type="text"
            value={formData.carnet}
            onChange={(e) => setFormData({ ...formData, carnet: e.target.value })}
            className="w-full px-4 py-2 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:border-blue-500 text-white"
            placeholder="Ej: 20240001"
            required
          />
        </div>
        
        <div>
          <label className="block text-gray-300 mb-2">Nombre Completo</label>
          <input
            type="text"
            value={formData.nombre}
            onChange={(e) => setFormData({ ...formData, nombre: e.target.value })}
            className="w-full px-4 py-2 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:border-blue-500 text-white"
            placeholder="Ej: Juan Pérez"
            required
          />
        </div>
        
        <div>
          <label className="block text-gray-300 mb-2">Edad</label>
          <input
            type="number"
            value={formData.edad}
            onChange={(e) => setFormData({ ...formData, edad: e.target.value })}
            className="w-full px-4 py-2 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:border-blue-500 text-white"
            placeholder="Ej: 20"
            required
          />
        </div>
        
        <div>
          <label className="block text-gray-300 mb-2">Semestre</label>
          <input
            type="number"
            value={formData.semestre}
            onChange={(e) => setFormData({ ...formData, semestre: e.target.value })}
            className="w-full px-4 py-2 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:border-blue-500 text-white"
            placeholder="Ej: 5"
            required
          />
        </div>
        
        <div className="col-span-2">
          <label className="block text-gray-300 mb-2">Curso</label>
          <select
            value={formData.curso}
            onChange={(e) => setFormData({ ...formData, curso: e.target.value })}
            className="w-full px-4 py-2 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:border-blue-500 text-white"
            required
          >
            <option value="">Seleccionar curso</option>
            {cursos.map(curso => (
              <option key={curso.nombre} value={curso.nombre}>
                {curso.nombre} (Slot {curso.slot})
              </option>
            ))}
          </select>
          {cursos.length === 0 && (
            <p className="text-xs text-yellow-400 mt-1">
              ⚠️ Primero debes registrar un curso
            </p>
          )}
        </div>
      </div>

      {error && (
        <div className="p-3 bg-red-500/20 border border-red-500 rounded-lg flex items-center space-x-2">
          <AlertCircle className="w-5 h-5 text-red-400" />
          <span className="text-red-400 text-sm">{error}</span>
        </div>
      )}

      {success && (
        <div className="p-3 bg-green-500/20 border border-green-500 rounded-lg">
          <div className="flex items-center space-x-2">
            <CheckCircle className="w-5 h-5 text-green-400" />
            <span className="text-green-400 text-sm">{success}</span>
          </div>
          {hashInfo && (
            <div className="mt-2 text-sm space-y-1">
              <p className="text-green-300">📍 Asignado al Slot {hashInfo.slot}</p>
              {hashInfo.colision && (
                <p className="text-yellow-400">⚠️ Colisión detectada - Encadenamiento LIFO aplicado</p>
              )}
            </div>
          )}
        </div>
      )}

      <button
        type="submit"
        disabled={loading || cursos.length === 0}
        className="w-full py-3 bg-gradient-to-r from-blue-500 to-blue-600 rounded-lg font-semibold hover:from-blue-600 hover:to-blue-700 transition-all disabled:opacity-50 flex items-center justify-center space-x-2"
      >
        {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : <Save className="w-5 h-5" />}
        <span>{loading ? 'Registrando...' : 'Registrar Estudiante'}</span>
      </button>
    </form>
  );
};

export default FormularioRegistro;