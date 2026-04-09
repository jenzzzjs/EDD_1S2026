import { useState } from 'react'
import Header from '../componentes/Header'
import RegistrarRuta from '../vistas/RegistrarRuta'
import CaminoCorto from '../vistas/CaminoCorto'
import ListaRutas from '../vistas/ListaRutas'
import GestorGrafos from '../vistas/GestorGrafos'
import { PlusCircle, TrendingDown, List, FileImage } from 'lucide-react'

function Principal() {
  const [vistaActiva, setVistaActiva] = useState<'registrar' | 'camino' | 'lista' | 'grafos'>('registrar')
  const [mensaje, setMensaje] = useState<{ texto: string; tipo: 'exito' | 'error' } | null>(null)

  const mostrarMensaje = (texto: string, tipo: 'exito' | 'error') => {
    setMensaje({ texto, tipo })
    setTimeout(() => setMensaje(null), 3000)
  }

  const menuItems = [
    { id: 'registrar' as const, label: 'Registrar Ruta', icon: PlusCircle, color: 'blue' },
    { id: 'camino' as const, label: 'Camino Más Corto', icon: TrendingDown, color: 'green' },
    { id: 'lista' as const, label: 'Lista de Rutas', icon: List, color: 'purple' },
    { id: 'grafos' as const, label: 'Generar Grafo', icon: FileImage, color: 'orange' }
  ]

  return (
    <div className="relative min-h-screen overflow-hidden bg-gradient-to-br from-black via-gray-900 to-blue-900">
      <Header />
      
      <div className="relative container mx-auto px-4 py-8">
        {/* Botones de navegación */}
        <div className="flex justify-center gap-4 mb-8 flex-wrap">
          {menuItems.map((item) => (
            <button
              key={item.id}
              onClick={() => setVistaActiva(item.id)}
              className={`px-6 py-2 rounded-lg font-bold transition-all duration-300 flex items-center gap-2 ${
                vistaActiva === item.id
                  ? `bg-${item.color}-600 text-white shadow-lg transform scale-105`
                  : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
              }`}
            >
              <item.icon className="w-4 h-4" />
              {item.label}
            </button>
          ))}
        </div>

        {/* Mensaje de notificación */}
        {mensaje && (
          <div className={`fixed top-20 right-4 p-4 rounded-lg shadow-lg z-50 ${
            mensaje.tipo === 'exito' ? 'bg-green-500' : 'bg-red-500'
          } text-white`}>
            {mensaje.texto}
          </div>
        )}

        {/* Contenido según vista activa */}
        <div className="max-w-6xl mx-auto">
          {vistaActiva === 'registrar' && (
            <RegistrarRuta onMensaje={mostrarMensaje} />
          )}
          {vistaActiva === 'camino' && (
            <CaminoCorto onMensaje={mostrarMensaje} />
          )}
          {vistaActiva === 'lista' && (
            <ListaRutas onMensaje={mostrarMensaje} />
          )}
          {vistaActiva === 'grafos' && (
            <GestorGrafos onMensaje={mostrarMensaje} />
          )}
        </div>
      </div>
    </div>
  )
}

export default Principal