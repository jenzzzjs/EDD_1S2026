import { useState, useEffect } from 'react'
import { Search, Map, TrendingDown, Eye } from 'lucide-react'
import ApiService from '../servicios/api'
import type { RutaResultado, ApiResponse } from '../servicios/api'

interface CaminoCortoProps {
  onMensaje: (texto: string, tipo: 'exito' | 'error') => void
}

function CaminoCorto({ onMensaje }: CaminoCortoProps) {
  const [origenBusqueda, setOrigenBusqueda] = useState('')
  const [destinoBusqueda, setDestinoBusqueda] = useState('')
  const [vertices, setVertices] = useState<string[]>([])
  const [resultadoRuta, setResultadoRuta] = useState<RutaResultado | null>(null)
  const [imagenGrafo, setImagenGrafo] = useState<string | null>(null)
  const [cargando, setCargando] = useState(false)

  const cargarVertices = async () => {
    try {
      const response: ApiResponse = await ApiService.obtenerTodasRutas()
      if (response.success && response.vertices) {
        setVertices(response.vertices)
      }
    } catch (error) {
      console.error('Error al cargar vértices:', error)
    }
  }

  useEffect(() => {
    cargarVertices()

    const handleActualizar = () => {
      cargarVertices()
    }
    
    window.addEventListener('ubicacionRegistrada', handleActualizar)
    window.addEventListener('rutaRegistrada', handleActualizar)
    
    return () => {
      window.removeEventListener('ubicacionRegistrada', handleActualizar)
      window.removeEventListener('rutaRegistrada', handleActualizar)
    }
  }, [])

  const handleBuscarRuta = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!origenBusqueda || !destinoBusqueda) {
      onMensaje('Por favor seleccione origen y destino', 'error')
      return
    }
    
    setCargando(true)
    
    const response: ApiResponse = await ApiService.obtenerRutaMasCorta(origenBusqueda, destinoBusqueda)
    
    if (response.success && response.ruta) {
      setResultadoRuta(response.ruta)
      onMensaje(response.message || 'Ruta encontrada', 'exito')
      
      // Generar grafo con el camino resaltado
      const grafoResponse = await ApiService.generarGrafoConCamino('camino_temp', response.ruta.camino, 'pequeno')
      if (grafoResponse.success && grafoResponse.archivos?.png) {
        const imgResponse = await fetch(`/${grafoResponse.archivos.png}`)
        const blob = await imgResponse.blob()
        setImagenGrafo(URL.createObjectURL(blob))
      }
    } else {
      setResultadoRuta(null)
      setImagenGrafo(null)
      onMensaje(response.message || 'No se encontró una ruta', 'error')
    }
    
    setCargando(false)
  }

  return (
    <div className="space-y-6">
      <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
        <h2 className="text-2xl font-bold text-white mb-6 flex items-center gap-2">
          <TrendingDown className="w-6 h-6" />
          Buscar Camino Más Corto
        </h2>
        
        <form onSubmit={handleBuscarRuta} className="space-y-4">
          <div>
            <label className="block text-blue-300 text-sm font-bold mb-2">
              Origen
            </label>
            <select
              value={origenBusqueda}
              onChange={(e) => setOrigenBusqueda(e.target.value)}
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500"
              required
              disabled={vertices.length === 0}
            >
              <option value="">Seleccione origen</option>
              {vertices.map(v => <option key={v} value={v}>{v}</option>)}
            </select>
          </div>

          <div>
            <label className="block text-blue-300 text-sm font-bold mb-2">
              Destino
            </label>
            <select
              value={destinoBusqueda}
              onChange={(e) => setDestinoBusqueda(e.target.value)}
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500"
              required
              disabled={vertices.length === 0}
            >
              <option value="">Seleccione destino</option>
              {vertices.map(v => <option key={v} value={v}>{v}</option>)}
            </select>
          </div>

          <button
            type="submit"
            disabled={cargando || vertices.length === 0}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 transform hover:scale-105 flex items-center justify-center gap-2"
          >
            <Search className="w-4 h-4" />
            {cargando ? 'Buscando...' : 'Buscar Ruta'}
          </button>
        </form>

        {resultadoRuta && resultadoRuta.existe && (
          <div className="mt-6 p-4 bg-green-900/50 rounded-lg">
            <h3 className="text-xl font-bold text-green-400 mb-2 flex items-center gap-2">
              <Map className="w-5 h-5" />
              Ruta Encontrada
            </h3>
            <p className="text-white">
              <strong>Camino:</strong> {resultadoRuta.camino.join(' → ')}
            </p>
            <p className="text-white mt-2">
              <strong>Distancia total:</strong> {resultadoRuta.distancia} km
            </p>
          </div>
        )}

        {resultadoRuta && !resultadoRuta.existe && (
          <div className="mt-6 p-4 bg-red-900/50 rounded-lg">
            <h3 className="text-xl font-bold text-red-400 mb-2">Ruta No Encontrada</h3>
            <p className="text-white">
              No existe un camino desde <strong>{origenBusqueda}</strong> hasta <strong>{destinoBusqueda}</strong>
            </p>
          </div>
        )}
      </div>

      {imagenGrafo && (
        <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
          <h3 className="text-xl font-bold text-white mb-4 flex items-center gap-2">
            <Eye className="w-5 h-5" />
            Visualización del Grafo
          </h3>
          <div className="flex justify-center">
            <img src={imagenGrafo} alt="Grafo de rutas" className="rounded-lg max-w-full h-auto" style={{ maxHeight: '400px' }} />
          </div>
        </div>
      )}
    </div>
  )
}

export default CaminoCorto