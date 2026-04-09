import { useState, useEffect } from 'react'
import { MapPin, Plus, Upload, AlertCircle } from 'lucide-react'
import ApiService from '../servicios/api'
import type { ApiResponse } from '../servicios/api'

interface RegistrarRutaProps {
  onMensaje: (texto: string, tipo: 'exito' | 'error') => void
}

function RegistrarRuta({ onMensaje }: RegistrarRutaProps) {
  const [origen, setOrigen] = useState('')
  const [destino, setDestino] = useState('')
  const [distancia, setDistancia] = useState('')
  const [vertices, setVertices] = useState<string[]>([])
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

    const handleUbicacionRegistrada = () => {
      cargarVertices()
    }
    
    window.addEventListener('ubicacionRegistrada', handleUbicacionRegistrada)
    return () => {
      window.removeEventListener('ubicacionRegistrada', handleUbicacionRegistrada)
    }
  }, [])

  const handleRegistrarRuta = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!origen || !destino) {
      onMensaje('Por favor seleccione origen y destino', 'error')
      return
    }
    
    if (origen === destino) {
      onMensaje('Origen y destino no pueden ser iguales', 'error')
      return
    }
    
    const distanciaNum = parseFloat(distancia)
    if (isNaN(distanciaNum) || distanciaNum <= 0) {
      onMensaje('Por favor ingrese una distancia válida mayor a 0', 'error')
      return
    }
    
    setCargando(true)
    
    const response: ApiResponse = await ApiService.registrarRuta(origen, destino, distanciaNum)
    
    if (response.success) {
      onMensaje(response.message || 'Ruta registrada exitosamente', 'exito')
      setOrigen('')
      setDestino('')
      setDistancia('')
      await cargarVertices()
      window.dispatchEvent(new CustomEvent('rutaRegistrada'))
    } else {
      onMensaje(response.message || 'Error al registrar ruta', 'error')
    }
    
    setCargando(false)
  }

  const handleCargarRutasArchivo = async () => {
    setCargando(true)
    const response: ApiResponse = await ApiService.cargarRutas()
    
    if (response.success) {
      onMensaje(response.message || 'Rutas cargadas exitosamente', 'exito')
      await cargarVertices()
      window.dispatchEvent(new CustomEvent('rutaRegistrada'))
    } else {
      onMensaje(response.message || 'Error al cargar rutas', 'error')
    }
    
    setCargando(false)
  }

  return (
    <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
      <h2 className="text-2xl font-bold text-white mb-6 flex items-center gap-2">
        <MapPin className="w-6 h-6" />
        Registrar Nueva Ruta
      </h2>
      
      <div className="mb-4">
        <button
          onClick={handleCargarRutasArchivo}
          disabled={cargando}
          className="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 flex items-center gap-2"
        >
          <Upload className="w-4 h-4" />
          Cargar Rutas desde Archivo
        </button>
      </div>
      
      <form onSubmit={handleRegistrarRuta} className="space-y-4">
        <div>
          <label className="block text-blue-300 text-sm font-bold mb-2">
            Origen
          </label>
          <select
            value={origen}
            onChange={(e) => setOrigen(e.target.value)}
            className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500"
            required
          >
            <option value="">Seleccione el origen</option>
            {vertices.length === 0 ? (
              <option value="" disabled>No hay vértices disponibles</option>
            ) : (
              vertices.map(v => (
                <option key={v} value={v}>{v}</option>
              ))
            )}
          </select>
        </div>

        <div>
          <label className="block text-blue-300 text-sm font-bold mb-2">
            Destino
          </label>
          <select
            value={destino}
            onChange={(e) => setDestino(e.target.value)}
            className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500"
            required
            disabled={vertices.length === 0}
          >
            <option value="">Seleccione el destino</option>
            {vertices.map(v => (
              <option key={v} value={v}>{v}</option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-blue-300 text-sm font-bold mb-2">
            Distancia (km)
          </label>
          <input
            type="number"
            value={distancia}
            onChange={(e) => setDistancia(e.target.value)}
            className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500"
            placeholder="Ingrese la distancia en kilómetros"
            required
            min="0.1"
            step="0.1"
          />
        </div>

        <button
          type="submit"
          disabled={cargando || vertices.length === 0}
          className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 transform hover:scale-105 disabled:opacity-50 flex items-center justify-center gap-2"
        >
          <Plus className="w-4 h-4" />
          {cargando ? 'Registrando...' : 'Registrar Ruta'}
        </button>
      </form>

      {vertices.length === 0 && (
        <div className="mt-4 p-3 bg-yellow-500/20 border border-yellow-500/50 rounded-lg flex items-center gap-2">
          <AlertCircle className="w-4 h-4 text-yellow-400" />
          <p className="text-yellow-300 text-sm">
            No hay vértices disponibles. Carga rutas desde archivo o registra ubicaciones.
          </p>
        </div>
      )}
    </div>
  )
}

export default RegistrarRuta