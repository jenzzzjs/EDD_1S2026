import React from 'react';
import { UserPlus, Users } from 'lucide-react';

interface SugerenciaCardProps {
  usuario: string;
  amigosEnComun: number;
  onEnviarSolicitud: () => void;
}

const SugerenciaCard: React.FC<SugerenciaCardProps> = ({ usuario, amigosEnComun, onEnviarSolicitud }) => {
  return (
    <div className="bg-gradient-to-r from-gray-800 to-gray-900 rounded-lg p-4 border border-purple-500/30 hover:border-purple-500/60 transition-all">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-purple-500 rounded-full flex items-center justify-center">
            <Users className="w-6 h-6 text-white" />
          </div>
          <div>
            <h3 className="font-semibold text-lg">{usuario}</h3>
            <p className="text-xs text-gray-400">{amigosEnComun} amigos en común</p>
          </div>
        </div>
        <button
          onClick={onEnviarSolicitud}
          className="flex items-center space-x-1 px-3 py-2 bg-blue-500 rounded-lg hover:bg-blue-600 transition-colors"
        >
          <UserPlus className="w-4 h-4" />
          <span>Agregar</span>
        </button>
      </div>
    </div>
  );
};

export default SugerenciaCard;
