import { useState, useEffect } from 'react'
import { FileImage, Download, Trash2, RefreshCw, Eye, Plus, Map, GitBranch } from 'lucide-react'
import ApiService from '../servicios/api'
import type { GrafoInfo, ApiResponse, RutaResultado } from '../servicios/api'

interface GestorGrafosProps {
  onMensaje: (texto: string, tipo: 'exito' | 'error') => void
}

function GestorGrafos({ onMensaje }: GestorGrafosProps) {
  const [grafos, setGrafos] = useState<GrafoInfo[]>([])
  const [cargando, setCargando] = useState(false)
  const [vistaPrevia, setVistaPrevia] = useState<string | null>(null)
  const [mostrarFormulario, setMostrarFormulario] = useState(false)
  const [nombreGrafo, setNombreGrafo] = useState('')
  const [tamañoGrafo, setTamañoGrafo] = useState<'pequeno' | 'mediano' | 'grande'>('pequeno')
  const [origenCamino, setOrigenCamino] = useState('')
  const [destinoCamino, setDestinoCamino] = useState('')
  const [vertices, setVertices] = useState<string[]>([])
  const [resultadoRuta, setResultadoRuta] = useState<RutaResultado | null>(null)
  const [rutasInfo, setRutasInfo] = useState<{ total: number }>({ total: 0 })

  const listarGrafos = async () => {
    setCargando(true)
    const response: ApiResponse = await ApiService.listarGrafos()
    
    if (response.success && response.grafos) {
      setGrafos(response.grafos)
    } else {
      onMensaje(response.message || 'Error al listar grafos', 'error')
    }
    setCargando(false)
  }

  const cargarInformacionGrafo = async () => {
    try {
      const response: ApiResponse = await ApiService.obtenerTodasRutas()
      if (response.success) {
        setVertices(response.vertices || [])
        setRutasInfo({
          total: response.rutas?.length || 0
        })
      }
    } catch (error) {
      console.error('Error al cargar información del grafo:', error)
    }
  }

  const generarGrafoCompleto = async () => {
    if (!nombreGrafo.trim()) {
      onMensaje('Por favor ingrese un nombre para el grafo', 'error')
      return
    }

    const totalRutas = rutasInfo.total
    if (totalRutas === 0) {
      onMensaje('No hay rutas registradas para generar el grafo. Primero cargue rutas desde archivo o registre rutas manualmente.', 'error')
      return
    }

    setCargando(true)
    // Generar grafo completo sin resaltar ningún camino específico
    const response: ApiResponse = await ApiService.generarGrafoConCamino(nombreGrafo, null, tamañoGrafo)
    
    if (response.success) {
      onMensaje(`Grafo completo generado exitosamente con ${totalRutas} rutas y ${vertices.length} vértices`, 'exito')
      setNombreGrafo('')
      setMostrarFormulario(false)
      await listarGrafos()
    } else {
      onMensaje(response.message || 'Error al generar grafo', 'error')
    }
    setCargando(false)
  }

  const generarGrafoConCaminoResaltado = async () => {
    if (!nombreGrafo.trim()) {
      onMensaje('Por favor ingrese un nombre para el grafo', 'error')
      return
    }

    const totalRutas = rutasInfo.total
    if (totalRutas === 0) {
      onMensaje('No hay rutas registradas para generar el grafo', 'error')
      return
    }

    if (!origenCamino || !destinoCamino) {
      onMensaje('Seleccione origen y destino para resaltar el camino', 'error')
      return
    }

    setCargando(true)
    
    // Primero obtener el camino más corto para resaltar
    const rutaResponse: ApiResponse = await ApiService.obtenerRutaMasCorta(origenCamino, destinoCamino)
    
    if (!rutaResponse.success || !rutaResponse.ruta?.existe) {
      onMensaje(`No existe un camino entre ${origenCamino} y ${destinoCamino}`, 'error')
      setCargando(false)
      return
    }

    setResultadoRuta(rutaResponse.ruta)

    // Generar grafo COMPLETO con el camino resaltado (pero mostrando TODAS las rutas)
    const response: ApiResponse = await ApiService.generarGrafoConCamino(nombreGrafo, rutaResponse.ruta.camino, tamañoGrafo)
    
    if (response.success) {
      onMensaje(
        `Grafo completo generado exitosamente. Total: ${totalRutas} rutas, ${vertices.length} vértices. ` +
        `Camino resaltado: ${origenCamino} → ${destinoCamino} (${rutaResponse.ruta.distancia} km)`,
        'exito'
      )
      setNombreGrafo('')
      setOrigenCamino('')
      setDestinoCamino('')
      setMostrarFormulario(false)
      setResultadoRuta(null)
      await listarGrafos()
    } else {
      onMensaje(response.message || 'Error al generar grafo', 'error')
    }
    setCargando(false)
  }

  const descargarGrafo = async (nombre: string) => {
    const response = await ApiService.descargarGrafo(nombre)
    if (response.success) {
      onMensaje(`Grafo ${nombre} descargado exitosamente`, 'exito')
    } else {
      onMensaje(response.message || 'Error al descargar grafo', 'error')
    }
  }

  const eliminarGrafo = async (nombre: string) => {
    if (confirm(`¿Estás seguro de que deseas eliminar el grafo ${nombre}?`)) {
      const response: ApiResponse = await ApiService.eliminarGrafo(nombre)
      if (response.success) {
        onMensaje(response.message || 'Grafo eliminado exitosamente', 'exito')
        await listarGrafos()
      } else {
        onMensaje(response.message || 'Error al eliminar grafo', 'error')
      }
    }
  }

  const verVistaPrevia = async (nombre: string) => {
    const response = await fetch(`/${nombre}.png`)
    if (response.ok) {
      const blob = await response.blob()
      setVistaPrevia(URL.createObjectURL(blob))
    }
  }

  useEffect(() => {
    listarGrafos()
    cargarInformacionGrafo()

    // Escuchar eventos que puedan cambiar el grafo
    const handleActualizar = () => {
      cargarInformacionGrafo()
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
      <div className="flex justify-between items-center mb-6 flex-wrap gap-4">
        <div>
          <h2 className="text-2xl font-bold text-white flex items-center gap-2">
            <GitBranch className="w-6 h-6" />
            Generar Grafo
          </h2>
          <p className="text-gray-400 text-sm mt-1">
            {rutasInfo.total > 0 
              ? `Grafo actual: ${vertices.length} vértices, ${rutasInfo.total} rutas registradas`
              : 'No hay rutas registradas. Cargue rutas desde archivo para generar el grafo.'}
          </p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => {
              setMostrarFormulario(!mostrarFormulario)
              setResultadoRuta(null)
              setOrigenCamino('')
              setDestinoCamino('')
            }}
            disabled={rutasInfo.total === 0}
            className={`bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 flex items-center gap-2 ${
              rutasInfo.total === 0 ? 'opacity-50 cursor-not-allowed' : ''
            }`}
            title={rutasInfo.total === 0 ? 'No hay rutas para generar el grafo' : 'Generar nuevo grafo'}
          >
            <Plus className="w-4 h-4" />
            Nuevo Grafo
          </button>
          <button
            onClick={listarGrafos}
            disabled={cargando}
            className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 flex items-center gap-2"
          >
            <RefreshCw className={`w-4 h-4 ${cargando ? 'animate-spin' : ''}`} />
            Actualizar
          </button>
        </div>
      </div>

      {/* Formulario para generar nuevo grafo */}
      {mostrarFormulario && (
        <div className="mb-6 p-4 bg-gray-800/50 rounded-lg">
          <h3 className="text-xl font-bold text-white mb-4 flex items-center gap-2">
            <Plus className="w-5 h-5" />
            Generar Nuevo Grafo
          </h3>
          
          <div className="space-y-4">
            <div>
              <label className="block text-blue-300 text-sm font-bold mb-2">
                Nombre del Grafo
              </label>
              <input
                type="text"
                value={nombreGrafo}
                onChange={(e) => setNombreGrafo(e.target.value)}
                className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500"
                placeholder="Ej: grafo_completo_2024"
              />
            </div>

            <div>
              <label className="block text-blue-300 text-sm font-bold mb-2">
                Tamaño del Grafo
              </label>
              <select
                value={tamañoGrafo}
                onChange={(e) => setTamañoGrafo(e.target.value as 'pequeno' | 'mediano' | 'grande')}
                className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500"
              >
                <option value="pequeno">Pequeño - 6x4 (recomendado para vista previa)</option>
                <option value="mediano">Mediano - 10x7</option>
                <option value="grande">Grande - 14x10 (para impresión)</option>
              </select>
            </div>

            <div className="border-t border-gray-700 pt-4">
              <label className="block text-blue-300 text-sm font-bold mb-2 flex items-center gap-2">
                <Map className="w-4 h-4" />
                Opcional: Resaltar un Camino Específico
              </label>
              <p className="text-gray-400 text-xs mb-3">
                Seleccione origen y destino para resaltar el camino más corto dentro del grafo completo.
                El grafo seguirá mostrando TODAS las rutas, pero este camino se mostrará en verde.
              </p>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-gray-400 text-xs mb-1">Origen</label>
                  <select
                    value={origenCamino}
                    onChange={(e) => setOrigenCamino(e.target.value)}
                    className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500"
                  >
                    <option value="">Seleccione origen (opcional)</option>
                    {vertices.map(v => <option key={v} value={v}>{v}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-gray-400 text-xs mb-1">Destino</label>
                  <select
                    value={destinoCamino}
                    onChange={(e) => setDestinoCamino(e.target.value)}
                    className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500"
                  >
                    <option value="">Seleccione destino (opcional)</option>
                    {vertices.map(v => <option key={v} value={v}>{v}</option>)}
                  </select>
                </div>
              </div>
            </div>

            {resultadoRuta && resultadoRuta.existe && (
              <div className="p-3 bg-green-900/50 rounded-lg">
                <p className="text-green-400 text-sm">
                  <strong>Camino a resaltar:</strong> {resultadoRuta.camino.join(' → ')}
                </p>
                <p className="text-green-400 text-sm">
                  <strong>Distancia total:</strong> {resultadoRuta.distancia} km
                </p>
              </div>
            )}

            <div className="flex gap-2 pt-2">
              <button
                onClick={generarGrafoCompleto}
                disabled={cargando || !nombreGrafo.trim()}
                className="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 disabled:opacity-50"
              >
                Generar Grafo Completo
              </button>
              <button
                onClick={generarGrafoConCaminoResaltado}
                disabled={cargando || !nombreGrafo.trim() || !origenCamino || !destinoCamino}
                className="flex-1 bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 disabled:opacity-50"
              >
                Generar con Camino Resaltado
              </button>
              <button
                onClick={() => {
                  setMostrarFormulario(false)
                  setResultadoRuta(null)
                  setOrigenCamino('')
                  setDestinoCamino('')
                }}
                className="bg-gray-600 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300"
              >
                Cancelar
              </button>
            </div>
          </div>
        </div>
      )}
      
      {cargando && !mostrarFormulario ? (
        <p className="text-white text-center py-8">Cargando...</p>
      ) : grafos.length === 0 ? (
        <div className="text-center py-8">
          <GitBranch className="w-16 h-16 text-gray-500 mx-auto mb-4" />
          <p className="text-gray-400 mb-4">No hay grafos generados aún</p>
          {rutasInfo.total > 0 ? (
            <button
              onClick={() => setMostrarFormulario(true)}
              className="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 flex items-center gap-2 mx-auto"
            >
              <Plus className="w-4 h-4" />
              Generar Primer Grafo
            </button>
          ) : (
            <p className="text-yellow-400 text-sm">
              ⚠️ No hay rutas registradas. Ve a la pestaña "Registrar Ruta" y carga rutas desde archivo primero.
            </p>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {grafos.map((grafo) => (
            <div key={grafo.nombre} className="bg-gray-800 rounded-lg p-4">
              <div className="flex justify-between items-start mb-2">
                <h3 className="text-white font-bold truncate flex-1">{grafo.nombre}</h3>
                <span className="text-gray-400 text-xs">{(grafo.tamaño / 1024).toFixed(2)} KB</span>
              </div>
              {grafo.png && (
                <img 
                  src={`/${grafo.png}`} 
                  alt={grafo.nombre}
                  className="w-full h-32 object-contain bg-gray-900 rounded mb-2 cursor-pointer"
                  onClick={() => verVistaPrevia(grafo.nombre)}
                />
              )}
              <div className="flex gap-2 mt-2">
                <button
                  onClick={() => verVistaPrevia(grafo.nombre)}
                  className="flex-1 bg-green-600 hover:bg-green-700 text-white py-1 px-2 rounded text-sm flex items-center justify-center gap-1"
                >
                  <Eye className="w-3 h-3" />
                  Vista Previa
                </button>
                <button
                  onClick={() => descargarGrafo(grafo.nombre)}
                  className="flex-1 bg-blue-600 hover:bg-blue-700 text-white py-1 px-2 rounded text-sm flex items-center justify-center gap-1"
                >
                  <Download className="w-3 h-3" />
                  Descargar
                </button>
                <button
                  onClick={() => eliminarGrafo(grafo.nombre)}
                  className="bg-red-600 hover:bg-red-700 text-white py-1 px-2 rounded text-sm flex items-center justify-center gap-1"
                >
                  <Trash2 className="w-3 h-3" />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal de vista previa */}
      {vistaPrevia && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4" onClick={() => setVistaPrevia(null)}>
          <div className="max-w-4xl max-h-full" onClick={(e) => e.stopPropagation()}>
            <img src={vistaPrevia} alt="Vista previa" className="max-w-full max-h-screen rounded-lg" />
            <button
              onClick={() => setVistaPrevia(null)}
              className="absolute top-4 right-4 bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg"
            >
              Cerrar
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

export default GestorGrafos