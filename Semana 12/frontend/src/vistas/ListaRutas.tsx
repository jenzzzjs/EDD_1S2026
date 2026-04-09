import { useState, useEffect } from 'react'
import { List, Trash2, RefreshCw } from 'lucide-react'
import ApiService from '../servicios/api'
import type { Ruta, ApiResponse } from '../servicios/api'

interface ListaRutasProps {
  onMensaje: (texto: string, tipo: 'exito' | 'error') => void
}

function ListaRutas({ onMensaje }: ListaRutasProps) {
  const [rutas, setRutas] = useState<Ruta[]>([])
  const [cargando, setCargando] = useState(false)

  const cargarRutas = async () => {
    setCargando(true)
    try {
      const response: ApiResponse = await ApiService.obtenerTodasRutas()
      
      if (response.success && response.rutas) {
        setRutas(response.rutas)
      } else {
        setRutas([])
      }
    } catch (error) {
      console.error('Error al cargar rutas:', error)
      onMensaje('Error de conexión con el servidor', 'error')
    }
    setCargando(false)
  }

  const eliminarTodasRutas = async () => {
    if (confirm('¿Estás seguro de que deseas eliminar todas las rutas?')) {
      setCargando(true)
      const response: ApiResponse = await ApiService.eliminarTodasRutas()
      
      if (response.success) {
        onMensaje(response.message || 'Todas las rutas han sido eliminadas', 'exito')
        await cargarRutas()
        window.dispatchEvent(new CustomEvent('rutaRegistrada'))
      } else {
        onMensaje(response.message || 'Error al eliminar rutas', 'error')
      }
      setCargando(false)
    }
  }

  useEffect(() => {
    cargarRutas()

    const handleActualizar = () => {
      cargarRutas()
    }
    
    window.addEventListener('ubicacionRegistrada', handleActualizar)
    window.addEventListener('rutaRegistrada', handleActualizar)
    
    return () => {
      window.removeEventListener('ubicacionRegistrada', handleActualizar)
      window.removeEventListener('rutaRegistrada', handleActualizar)
    }
  }, [])

  return (
    <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-white flex items-center gap-2">
          <List className="w-6 h-6" />
          Lista de Rutas Registradas
        </h2>
        <div className="flex gap-2">
          <button
            onClick={cargarRutas}
            disabled={cargando}
            className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 flex items-center gap-2"
          >
            <RefreshCw className={`w-4 h-4 ${cargando ? 'animate-spin' : ''}`} />
            Actualizar
          </button>
          <button
            onClick={eliminarTodasRutas}
            disabled={cargando || rutas.length === 0}
            className="bg-red-600 hover:bg-red-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 flex items-center gap-2"
          >
            <Trash2 className="w-4 h-4" />
            Eliminar Todas
          </button>
        </div>
      </div>
      
      {cargando ? (
        <p className="text-white text-center py-8">Cargando...</p>
      ) : rutas.length === 0 ? (
        <p className="text-gray-400 text-center py-8">No hay rutas registradas aún</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-gray-800">
              <tr>
                <th className="px-4 py-2 text-blue-300">Origen</th>
                <th className="px-4 py-2 text-blue-300">Destino</th>
                <th className="px-4 py-2 text-blue-300">Distancia (km)</th>
              </tr>
            </thead>
            <tbody>
              {rutas.map((ruta, idx) => (
                <tr key={idx} className="border-t border-gray-700">
                  <td className="px-4 py-2 text-gray-300">{ruta.origen}</td>
                  <td className="px-4 py-2 text-gray-300">{ruta.destino}</td>
                  <td className="px-4 py-2 text-gray-300">{ruta.distancia}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}

export default ListaRutas