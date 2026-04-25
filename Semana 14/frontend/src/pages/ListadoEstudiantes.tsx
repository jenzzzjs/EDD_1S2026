// src/pages/ListadoEstudiantes.tsx
import React, { useState, useEffect } from 'react';
import { Search, Filter } from 'lucide-react';
import EstudianteCard from '../components/EstudianteCard';
import { estudiantesService, cursosService } from '../services/api';
import type { Estudiante, Curso } from '../services/api';

const ListadoEstudiantes: React.FC = () => {
  const [estudiantes, setEstudiantes] = useState<Estudiante[]>([]);
  const [filtered, setFiltered] = useState<Estudiante[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [cursoFilter, setCursoFilter] = useState('');
  const [cursos, setCursos] = useState<string[]>([]);

  useEffect(() => {
    cargarDatos();
    cargarCursos();
  }, []);

  const cargarDatos = async () => {
    try {
      const response = await estudiantesService.listar();
      if (response.data.success) {
        setEstudiantes(response.data.estudiantes);
        setFiltered(response.data.estudiantes);
      }
    } catch (error) {
      console.error('Error cargando estudiantes:', error);
    } finally {
      setLoading(false);
    }
  };

  const cargarCursos = async () => {
    try {
      const response = await cursosService.listar();
      if (response.data.success) {
        const nombresCursos = response.data.cursos.map((curso: Curso) => curso.nombre);
        setCursos(nombresCursos);
      }
    } catch (error) {
      console.error('Error cargando cursos:', error);
    }
  };

  const handleEliminar = async (carnet: string, curso: string) => {
    if (confirm('¿Eliminar este estudiante?')) {
      try {
        await estudiantesService.eliminar(carnet, curso);
        cargarDatos();
      } catch (error) {
        alert('Error al eliminar');
      }
    }
  };

  useEffect(() => {
    let result = [...estudiantes];
    
    if (searchTerm) {
      result = result.filter(e => 
        e.nombre.toLowerCase().includes(searchTerm.toLowerCase()) ||
        e.carnet.includes(searchTerm)
      );
    }
    
    if (cursoFilter) {
      result = result.filter(e => e.curso === cursoFilter);
    }
    
    setFiltered(result);
  }, [searchTerm, cursoFilter, estudiantes]);

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <div className="w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="bg-gray-800/30 rounded-lg p-4 border border-blue-500/30">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar por nombre o carnet..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:border-blue-500 text-white"
            />
          </div>
          
          <div className="relative">
            <Filter className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
            <select
              value={cursoFilter}
              onChange={(e) => setCursoFilter(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:border-blue-500 text-white"
            >
              <option value="">Todos los cursos</option>
              {cursos.map(curso => (
                <option key={curso} value={curso}>{curso}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {filtered.map((estudiante) => (
          <EstudianteCard
            key={estudiante.carnet}
            estudiante={estudiante}
            onEliminar={() => handleEliminar(estudiante.carnet, estudiante.curso)}
          />
        ))}
      </div>

      {filtered.length === 0 && (
        <div className="text-center py-12 text-gray-400">
          <p>No hay estudiantes registrados</p>
        </div>
      )}
    </div>
  );
};

export default ListadoEstudiantes;