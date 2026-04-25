// src/components/EstudianteCard.tsx
import React from 'react';
import { User, BookOpen, Hash, Calendar, GraduationCap } from 'lucide-react';
import type { Estudiante } from '../services/api';

interface EstudianteCardProps {
  estudiante: Estudiante;
  onEliminar?: () => void;
}

const EstudianteCard: React.FC<EstudianteCardProps> = ({ estudiante, onEliminar }) => {
  const getColorByCurso = (curso: string) => {
    const colores: Record<string, string> = {
      'Matemáticas': 'border-blue-500 bg-blue-500/10',
      'Física': 'border-green-500 bg-green-500/10',
      'Programación': 'border-purple-500 bg-purple-500/10',
      'Bases de Datos': 'border-yellow-500 bg-yellow-500/10',
      'Redes': 'border-orange-500 bg-orange-500/10',
      'Inglés': 'border-pink-500 bg-pink-500/10',
    };
    return colores[curso] || 'border-gray-500 bg-gray-500/10';
  };

  return (
    <div className={`rounded-lg p-4 border-2 ${getColorByCurso(estudiante.curso)} hover:scale-105 transition-all`}>
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="flex items-center space-x-3 mb-2">
            <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center">
              <User className="w-6 h-6 text-white" />
            </div>
            <div>
              <h3 className="font-bold text-lg">{estudiante.nombre}</h3>
              <div className="flex items-center space-x-2 text-sm text-gray-400">
                <Hash className="w-3 h-3" />
                <span>Carnet: {estudiante.carnet}</span>
              </div>
            </div>
          </div>
          
          <div className="grid grid-cols-2 gap-2 mt-3 text-sm">
            <div className="flex items-center space-x-2">
              <BookOpen className="w-4 h-4 text-blue-400" />
              <span>{estudiante.curso}</span>
            </div>
            <div className="flex items-center space-x-2">
              <GraduationCap className="w-4 h-4 text-green-400" />
              <span>{estudiante.semestre}° Semestre</span>
            </div>
            <div className="flex items-center space-x-2">
              <Calendar className="w-4 h-4 text-yellow-400" />
              <span>{estudiante.creado}</span>
            </div>
          </div>
        </div>
        
        {onEliminar && (
          <button
            onClick={onEliminar}
            className="px-3 py-1 bg-red-500/20 text-red-400 rounded-lg hover:bg-red-500/30 transition-colors"
          >
            Eliminar
          </button>
        )}
      </div>
    </div>
  );
};

export default EstudianteCard;