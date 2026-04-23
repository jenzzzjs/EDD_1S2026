import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, Search, UserPlus, TrendingUp, Network } from 'lucide-react';
import Navbar from '../components/Navbar';
import AmigoCard from '../components/AmigoCard';
import SugerenciaCard from '../components/SugerenciaCard';
import GrafoViewer from '../components/GrafoViewer';
import type { Amigo, Sugerencia, Estadisticas } from '../services/api';
import { amistadService, grafoService } from '../services/api';

const Amistades: React.FC = () => {
  const navigate = useNavigate();
  const [usuario] = useState(localStorage.getItem('usuario') || '');
  const [amigos, setAmigos] = useState<Amigo[]>([]);
  const [sugerencias, setSugerencias] = useState<Sugerencia[]>([]);
  const [estadisticas, setEstadisticas] = useState<Estadisticas | null>(null);
  const [searchUsuario, setSearchUsuario] = useState('');
  const [loading, setLoading] = useState(true);
  const [enviando, setEnviando] = useState<string | null>(null);
  const [mostrarGrafo, setMostrarGrafo] = useState(false);

  useEffect(() => {
    if (!usuario) {
      navigate('/login');
      return;
    }
    cargarDatos();
  }, [usuario]);

  const cargarDatos = async () => {
    try {
      const [amigosRes, sugerenciasRes, statsRes] = await Promise.all([
        amistadService.obtenerAmigos(usuario),
        amistadService.obtenerSugerencias(usuario),
        grafoService.obtenerEstadisticas(),
      ]);

      if (amigosRes.data.success) {
        setAmigos(amigosRes.data.amigos);
      }
      if (sugerenciasRes.data.success) {
        setSugerencias(sugerenciasRes.data.sugerencias);
      }
      if (statsRes.data.success) {
        setEstadisticas(statsRes.data.estadisticas);
      }
    } catch (error) {
      console.error('Error cargando datos:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleEnviarSolicitud = async (destinatario: string) => {
    setEnviando(destinatario);
    try {
      const response = await amistadService.enviarSolicitud(usuario, destinatario);
      if (response.data.success) {
        alert(`Solicitud enviada a ${destinatario}`);
        setSugerencias(sugerencias.filter(s => s.usuario !== destinatario));
      } else {
        alert(response.data.message || 'Error al enviar solicitud');
      }
    } catch (err: any) {
      alert(err.response?.data?.message || 'Error al enviar solicitud');
    } finally {
      setEnviando(null);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('usuario');
    navigate('/login');
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-black via-gray-900 to-blue-900 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-blue-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-blue-400">Cargando...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-black via-gray-900 to-blue-900">
      <Navbar usuario={usuario} onLogout={handleLogout} />

      <div className="container mx-auto px-4 py-8">
        {/* Botón para mostrar/ocultar grafo */}
        <div className="flex justify-end mb-4">
          <button
            onClick={() => setMostrarGrafo(!mostrarGrafo)}
            className="flex items-center gap-2 px-4 py-2 bg-purple-500/20 border border-purple-500 rounded-lg hover:bg-purple-500/30 transition-colors"
          >
            <Network className="w-5 h-5" />
            {mostrarGrafo ? 'Ocultar Grafo' : 'Ver Grafo de Amistades'}
          </button>
        </div>

        {/* Visor del grafo */}
        {mostrarGrafo && (
          <div className="mb-8">
            <GrafoViewer usuario={usuario} />
          </div>
        )}

        {/* Estadísticas */}
        {estadisticas && (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
            <div className="bg-gray-800/50 rounded-lg p-4 border border-blue-500/30">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-gray-400 text-sm">Usuarios</p>
                  <p className="text-2xl font-bold">{estadisticas.total_usuarios}</p>
                </div>
                <Users className="w-8 h-8 text-blue-400" />
              </div>
            </div>
            <div className="bg-gray-800/50 rounded-lg p-4 border border-blue-500/30">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-gray-400 text-sm">Amistades</p>
                  <p className="text-2xl font-bold">{estadisticas.total_amistades}</p>
                </div>
                <UserPlus className="w-8 h-8 text-green-400" />
              </div>
            </div>
            <div className="bg-gray-800/50 rounded-lg p-4 border border-blue-500/30">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-gray-400 text-sm">Solicitudes</p>
                  <p className="text-2xl font-bold">{estadisticas.total_solicitudes_pendientes}</p>
                </div>
                <TrendingUp className="w-8 h-8 text-yellow-400" />
              </div>
            </div>
            <div className="bg-gray-800/50 rounded-lg p-4 border border-blue-500/30">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-gray-400 text-sm">Grado Promedio</p>
                  <p className="text-2xl font-bold">{estadisticas.grado_promedio}</p>
                </div>
                <Users className="w-8 h-8 text-purple-400" />
              </div>
            </div>
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Lista de Amigos */}
          <div className="lg:col-span-2">
            <div className="bg-gray-800/30 rounded-lg p-6 border border-blue-500/30">
              <h2 className="text-2xl font-bold mb-4 flex items-center">
                <Users className="w-6 h-6 mr-2 text-blue-400" />
                Mis Amigos ({amigos.length})
              </h2>

              {amigos.length === 0 ? (
                <div className="text-center py-8 text-gray-400">
                  <p>No tienes amigos aún. Envía solicitudes para conectar.</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {amigos.map((amigo, index) => (
                    <AmigoCard key={index} nombre={amigo.nombre} desde={amigo.desde} />
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Sugerencias */}
          <div>
            <div className="bg-gray-800/30 rounded-lg p-6 border border-purple-500/30">
              <h2 className="text-2xl font-bold mb-4 flex items-center">
                <TrendingUp className="w-6 h-6 mr-2 text-purple-400" />
                Sugerencias
              </h2>

              <div className="mb-4">
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                  <input
                    type="text"
                    placeholder="Buscar usuario..."
                    value={searchUsuario}
                    onChange={(e) => setSearchUsuario(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:border-blue-500 text-white"
                  />
                </div>
              </div>

              {searchUsuario && (
                <div className="mb-4">
                  <button
                    onClick={() => handleEnviarSolicitud(searchUsuario)}
                    disabled={enviando === searchUsuario}
                    className="w-full py-2 bg-blue-500 rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50"
                  >
                    {enviando === searchUsuario ? 'Enviando...' : `Enviar solicitud a ${searchUsuario}`}
                  </button>
                </div>
              )}

              {sugerencias.length === 0 && !searchUsuario ? (
                <div className="text-center py-8 text-gray-400">
                  <p>No hay sugerencias por ahora.</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {sugerencias.map((sugerencia, index) => (
                    <SugerenciaCard
                      key={index}
                      usuario={sugerencia.usuario}
                      amigosEnComun={sugerencia.amigos_en_comun}
                      onEnviarSolicitud={() => handleEnviarSolicitud(sugerencia.usuario)}
                    />
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Amistades;
