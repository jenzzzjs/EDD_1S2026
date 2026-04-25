// src/App.tsx
import React, { useState } from 'react';
import { BookOpen } from 'lucide-react';
import './App.css';
import Navbar from './components/Navbar';
import RegistrarCurso from './components/RegistrarCurso';
import ListadoCursos from './components/ListadoCursos';
import FormularioRegistro from './components/FormularioRegistro';
import ListadoEstudiantes from './pages/ListadoEstudiantes';
import EstadisticasHash from './pages/EstadisticasHash';
import VisualizarHash from './pages/VisualizarHash';

function App() {
  const [activeTab, setActiveTab] = useState<'cursos' | 'registro' | 'listado' | 'estadisticas' | 'visualizar'>('cursos');
  const [refreshKey, setRefreshKey] = useState(0);

  const handleCursoRegistrada = () => {
    setRefreshKey(prev => prev + 1);
  };

  const handleRegistroExitoso = () => {
    setRefreshKey(prev => prev + 1);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-black via-gray-900 to-blue-900">
      <Navbar activeTab={activeTab} onTabChange={setActiveTab} />
      
      <div className="container mx-auto px-4 py-8">
        {activeTab === 'cursos' && (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <RegistrarCurso onCursoRegistrada={handleCursoRegistrada} />
            <div className="bg-gray-800/30 rounded-lg p-6 border border-blue-500/30">
              <h3 className="text-xl font-bold mb-4 flex items-center">
                <BookOpen className="w-6 h-6 mr-2 text-blue-400" />
                Cursos Registrados
              </h3>
              <ListadoCursos key={refreshKey} />
            </div>
          </div>
        )}
        
        {activeTab === 'registro' && (
          <div className="max-w-2xl mx-auto">
            <div className="bg-gray-800/30 rounded-lg p-6 border border-blue-500/30">
              <h2 className="text-2xl font-bold mb-6 text-center">Registrar Nuevo Estudiante</h2>
              <FormularioRegistro onRegistroExitoso={handleRegistroExitoso} />
            </div>
          </div>
        )}
        
        {activeTab === 'listado' && <ListadoEstudiantes key={refreshKey} />}
        {activeTab === 'estadisticas' && <EstadisticasHash />}
        {activeTab === 'visualizar' && <VisualizarHash />}
      </div>
    </div>
  );
}

export default App;