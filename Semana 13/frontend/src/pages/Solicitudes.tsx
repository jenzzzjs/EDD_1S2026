import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { UserPlus, CheckCircle, XCircle } from 'lucide-react';
import Navbar from '../components/Navbar';
import SolicitudCard from '../components/SolicitudCard';
import type { Solicitud } from '../services/api';
import { amistadService } from '../services/api';

const Solicitudes: React.FC = () => {
  const navigate = useNavigate();
  const [usuario] = useState(localStorage.getItem('usuario') || '');
  const [solicitudes, setSolicitudes] = useState<Solicitud[]>([]);
  const [loading, setLoading] = useState(true);
  const [mensaje, setMensaje] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    if (!usuario) {
      navigate('/login');
      return;
    }
    cargarSolicitudes();
  }, [usuario]);

  const cargarSolicitudes = async () => {
    try {
      const response = await amistadService.obtenerSolicitudes(usuario);
      if (response.data.success) {
        setSolicitudes(response.data.solicitudes);
      }
    } catch (error) {
      console.error('Error cargando solicitudes:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAceptar = async (solicitante: string) => {
    try {
      const response = await amistadService.aceptarSolicitud(usuario, solicitante);
      if (response.data.success) {
        setMensaje({ type: 'success', text: `Solicitud de ${solicitante} aceptada` });
        setSolicitudes(solicitudes.filter(s => s.usuario !== solicitante));
        setTimeout(() => setMensaje(null), 3000);
      } else {
        setMensaje({ type: 'error', text: response.data.message || 'Error al aceptar solicitud' });
        setTimeout(() => setMensaje(null), 3000);
      }
    } catch (err: any) {
      setMensaje({ type: 'error', text: err.response?.data?.message || 'Error al aceptar solicitud' });
      setTimeout(() => setMensaje(null), 3000);
    }
  };

  const handleRechazar = async (solicitante: string) => {
    try {
      const response = await amistadService.rechazarSolicitud(usuario, solicitante);
      if (response.data.success) {
        setMensaje({ type: 'success', text: `Solicitud de ${solicitante} rechazada` });
        setSolicitudes(solicitudes.filter(s => s.usuario !== solicitante));
        setTimeout(() => setMensaje(null), 3000);
      } else {
        setMensaje({ type: 'error', text: response.data.message || 'Error al rechazar solicitud' });
        setTimeout(() => setMensaje(null), 3000);
      }
    } catch (err: any) {
      setMensaje({ type: 'error', text: err.response?.data?.message || 'Error al rechazar solicitud' });
      setTimeout(() => setMensaje(null), 3000);
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
          <p className="text-blue-400">Cargando solicitudes...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-black via-gray-900 to-blue-900">
      <Navbar usuario={usuario} onLogout={handleLogout} />

      <div className="container mx-auto px-4 py-8">
        {mensaje && (
          <div className={`fixed top-20 right-4 z-50 p-4 rounded-lg shadow-lg ${
            mensaje.type === 'success' ? 'bg-green-500/90' : 'bg-red-500/90'
          } text-white animate-slide-in`}>
            <div className="flex items-center space-x-2">
              {mensaje.type === 'success' ? <CheckCircle className="w-5 h-5" /> : <XCircle className="w-5 h-5" />}
              <span>{mensaje.text}</span>
            </div>
          </div>
        )}

        <div className="max-w-2xl mx-auto">
          <div className="bg-gray-800/30 rounded-lg p-6 border border-yellow-500/30">
            <h2 className="text-2xl font-bold mb-4 flex items-center">
              <UserPlus className="w-6 h-6 mr-2 text-yellow-400" />
              Solicitudes de Amistad ({solicitudes.length})
            </h2>

            {solicitudes.length === 0 ? (
              <div className="text-center py-12">
                <UserPlus className="w-16 h-16 text-gray-600 mx-auto mb-4" />
                <p className="text-gray-400">No tienes solicitudes pendientes</p>
              </div>
            ) : (
              <div className="space-y-3">
                {solicitudes.map((solicitud, index) => (
                  <SolicitudCard
                    key={index}
                    usuario={solicitud.usuario}
                    desde={solicitud.desde}
                    onAceptar={() => handleAceptar(solicitud.usuario)}
                    onRechazar={() => handleRechazar(solicitud.usuario)}
                  />
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Solicitudes;