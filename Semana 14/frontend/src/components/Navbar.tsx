// src/components/Navbar.tsx
import React from 'react';
import { BookOpen, PlusCircle, Users, BarChart3, Hash } from 'lucide-react';

interface NavbarProps {
  activeTab: 'cursos' | 'registro' | 'listado' | 'estadisticas' | 'visualizar';
  onTabChange: (tab: 'cursos' | 'registro' | 'listado' | 'estadisticas' | 'visualizar') => void;
}

const Navbar: React.FC<NavbarProps> = ({ activeTab, onTabChange }) => {
  const tabs = [
    { id: 'cursos', label: 'Cursos', icon: BookOpen },
    { id: 'registro', label: 'Registrar', icon: PlusCircle },
    { id: 'listado', label: 'Estudiantes', icon: Users },
    { id: 'estadisticas', label: 'Estadísticas', icon: BarChart3 },
    { id: 'visualizar', label: 'Tabla Hash', icon: Hash },
  ];

  return (
    <nav className="bg-gradient-to-r from-blue-900 to-black shadow-lg border-b border-blue-500/30">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center space-x-2">
            <Hash className="w-8 h-8 text-blue-400" />
            <span className="text-xl font-bold bg-gradient-to-r from-blue-400 to-blue-600 bg-clip-text text-transparent">
              Tabla Hash - Registro de Estudiantes
            </span>
          </div>
          
          <div className="flex space-x-1">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              return (
                <button
                  key={tab.id}
                  onClick={() => onTabChange(tab.id as any)}
                  className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-all ${
                    activeTab === tab.id
                      ? 'bg-blue-500 text-white'
                      : 'text-gray-300 hover:bg-blue-500/20'
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  <span>{tab.label}</span>
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;