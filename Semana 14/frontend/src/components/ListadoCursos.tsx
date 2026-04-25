// src/components/ListadoCursos.tsx
import React, { useState, useEffect } from 'react';
import { BookOpen, Hash, Loader2 } from 'lucide-react';
import { cursosService } from '../services/api';
import type { Curso } from '../services/api';

const ListadoCursos: React.FC = () => {
  const [cursos, setCursos] = useState<Curso[]>([]);
  const [loading, setLoading] = useState(true);

  const cargarCursos = async () => {
    try {
      const response = await cursosService.listar();
      if (response.data.success) {
        setCursos(response.data.cursos);
      }
    } catch (error) {
      console.error('Error cargando cursos:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    cargarCursos();
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center py-4">
        <Loader2 className="w-6 h-6 animate-spin text-blue-400" />
      </div>
    );
  }

  if (cursos.length === 0) {
    return (
      <div className="text-center py-8 text-gray-400">
        <BookOpen className="w-12 h-12 mx-auto mb-2 opacity-50" />
        <p>No hay cursos registrados</p>
        <p className="text-sm">Registra un curso para comenzar</p>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      <h4 className="font-semibold text-gray-300 mb-3">Cursos Registrados:</h4>
      {cursos.map((curso) => (
        <div key={curso.nombre} className="flex items-center justify-between bg-gray-900 rounded-lg p-3">
          <div className="flex items-center space-x-3">
            <BookOpen className="w-5 h-5 text-blue-400" />
            <span className="font-medium">{curso.nombre}</span>
          </div>
          <div className="flex items-center space-x-2 text-sm">
            <Hash className="w-4 h-4 text-gray-400" />
            <span className="text-gray-400">Slot {curso.slot}</span>
          </div>
        </div>
      ))}
    </div>
  );
};

export default ListadoCursos;