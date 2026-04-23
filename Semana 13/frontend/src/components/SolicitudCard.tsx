import React from 'react';
import { User, Check, X, Calendar } from 'lucide-react';

interface SolicitudCardProps {
  usuario: string;
  desde: string;
  onAceptar: () => void;
  onRechazar: () => void;
}

const SolicitudCard: React.FC<SolicitudCardProps> = ({ usuario, desde, onAceptar, onRechazar }) => {
  return (
    <div className="bg-gradient-to-r from-gray-800 to-gray-900 rounded-lg p-4 border border-yellow-500/30">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-yellow-500 rounded-full flex items-center justify-center">
            <User className="w-6 h-6 text-white" />
          </div>
          <div>
            <h3 className="font-semibold text-lg">{usuario}</h3>
            <div className="flex items-center space-x-1 text-xs text-gray-400">
              <Calendar className="w-3 h-3" />
              <span>Solicitado: {desde}</span>
            </div>
          </div>
        </div>
        <div className="flex space-x-2">
          <button
            onClick={onAceptar}
            className="p-2 bg-green-500 rounded-lg hover:bg-green-600 transition-colors"
          >
            <Check className="w-5 h-5" />
          </button>
          <button
            onClick={onRechazar}
            className="p-2 bg-red-500 rounded-lg hover:bg-red-600 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
};

export default SolicitudCard;
