// src/components/RegistrarCurso.tsx
import React, { useState } from 'react';
import { PlusCircle, Loader2, AlertCircle, CheckCircle } from 'lucide-react';
import { cursosService } from '../services/api';

interface RegistrarCursoProps {
  onCursoRegistrada: () => void;
}

const RegistrarCurso: React.FC<RegistrarCursoProps> = ({ onCursoRegistrada }) => {
  const [nombreCurso, setNombreCurso] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [slotAsignado, setSlotAsignado] = useState<number | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!nombreCurso.trim()) {
      setError('Ingrese el nombre del curso');
      return;
    }

    setLoading(true);
    setError('');
    setSuccess('');
    setSlotAsignado(null);

    try {
      const response = await cursosService.registrar(nombreCurso);
      
      if (response.data.success) {
        setSuccess(response.data.message);
        setSlotAsignado(response.data.slot);
        setNombreCurso('');
        onCursoRegistrada();
        setTimeout(() => setSuccess(''), 3000);
      } else {
        setError(response.data.message);
        setTimeout(() => setError(''), 5000);
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al registrar el curso');
      setTimeout(() => setError(''), 5000);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-gray-800/30 rounded-lg p-6 border border-green-500/30">
      <h3 className="text-xl font-bold mb-4 flex items-center">
        <PlusCircle className="w-6 h-6 mr-2 text-green-400" />
        Registrar Nuevo Curso
      </h3>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-gray-300 mb-2">Nombre del Curso</label>
          <input
            type="text"
            value={nombreCurso}
            onChange={(e) => setNombreCurso(e.target.value)}
            placeholder="Ej: Matemáticas, Física, Programación..."
            className="w-full px-4 py-2 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:border-green-500 text-white"
            disabled={loading}
          />
          <p className="text-xs text-gray-400 mt-1">
            La función hash asignará automáticamente este curso a un slot (0-9)
          </p>
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
            {slotAsignado !== null && (
              <p className="text-green-300 text-sm mt-2">
                📍 Asignado al Slot {slotAsignado} de la tabla hash
              </p>
            )}
          </div>
        )}

        <button
          type="submit"
          disabled={loading}
          className="w-full py-2 bg-gradient-to-r from-green-500 to-green-600 rounded-lg font-semibold hover:from-green-600 hover:to-green-700 transition-all disabled:opacity-50 flex items-center justify-center space-x-2"
        >
          {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : <PlusCircle className="w-5 h-5" />}
          <span>{loading ? 'Registrando...' : 'Registrar Curso'}</span>
        </button>
      </form>

      <div className="mt-4 p-3 bg-blue-500/10 rounded-lg border border-blue-500/30">
        <p className="text-sm text-blue-300">
           <strong>¿Cómo funciona?</strong>
        </p>
        <ul className="text-xs text-gray-300 mt-2 list-disc list-inside space-y-1">
          <li>Cada curso se asigna a un slot usando una función hash</li>
          <li>Si dos cursos caen en el mismo slot, se produce una colisión y ambos se guardan</li>
          <li>La tabla tiene capacidad para 10 slots (índices 0-9)</li>
          <li>Los estudiantes se registran después de registrar su curso</li>
        </ul>
      </div>
    </div>
  );
};

export default RegistrarCurso;