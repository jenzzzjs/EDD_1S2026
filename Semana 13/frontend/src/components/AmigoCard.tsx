import React from 'react';
import { User, Calendar } from 'lucide-react';

interface AmigoCardProps {
  nombre: string;
  desde: string;
}

const AmigoCard: React.FC<AmigoCardProps> = ({ nombre, desde }) => {
  return (
    <div className="bg-gradient-to-r from-gray-800 to-gray-900 rounded-lg p-4 border border-blue-500/30 hover:border-blue-500/60 transition-all hover:scale-105">
      <div className="flex items-center space-x-3">
        <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center">
          <User className="w-6 h-6 text-white" />
        </div>
        <div className="flex-1">
          <h3 className="font-semibold text-lg">{nombre}</h3>
          <div className="flex items-center space-x-1 text-xs text-gray-400">
            <Calendar className="w-3 h-3" />
            <span>Amigos desde: {desde}</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AmigoCard;
