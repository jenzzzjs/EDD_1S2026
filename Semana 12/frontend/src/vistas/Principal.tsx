import { useState, useEffect } from 'react'
import Header from '../componentes/Header'
import GestorGrafos from '../componentes/GestorGrafos'
import ApiService from '../servicios/api'
import type { Ruta, RutaResultado, ApiResponse } from '../servicios/api'

function Principal() {
  const [vistaActiva, setVistaActiva] = useState<'registrar' | 'graficar' | 'camino' | 'grafos'>('registrar')
  const [origen, setOrigen] = useState('')
  const [destino, setDestino] = useState('')
  const [distancia, setDistancia] = useState('')
  const [rutas, setRutas] = useState<Ruta[]>([])
  const [vertices, setVertices] = useState<string[]>([])
  const [origenBusqueda, setOrigenBusqueda] = useState('')
  const [destinoBusqueda, setDestinoBusqueda] = useState('')
  const [resultadoRuta, setResultadoRuta] = useState<RutaResultado | null>(null)
  const [estadisticas, setEstadisticas] = useState<any>(null)
  const [imagenGrafo, setImagenGrafo] = useState<string | null>(null)
  const [cargando, setCargando] = useState(false)
  const [mensaje, setMensaje] = useState<{ texto: string; tipo: 'exito' | 'error' } | null>(null)

  // Resto del código igual...
  useEffect(() => {
    cargarRutas()
    cargarEstadisticas()
  }, [])

  // Escuchar evento de ubicación registrada
  useEffect(() => {
    const handleUbicacionRegistrada = () => {
      console.log('Nueva ubicación registrada, recargando vértices...')
      cargarRutas()
      cargarEstadisticas()
    }
    
    window.addEventListener('ubicacionRegistrada', handleUbicacionRegistrada)
    
    return () => {
      window.removeEventListener('ubicacionRegistrada', handleUbicacionRegistrada)
    }
  }, [])

  const cargarRutas = async () => {
    setCargando(true)
    try {
      const response: ApiResponse = await ApiService.obtenerTodasRutas()
      console.log('Respuesta de obtenerTodasRutas:', response)
      
      if (response.success) {
        if (response.rutas && Array.isArray(response.rutas)) {
          setRutas(response.rutas)
        } else {
          setRutas([])
        }
        
        if (response.vertices && Array.isArray(response.vertices)) {
          setVertices(response.vertices)
          console.log('Vértices cargados:', response.vertices)
        } else {
          setVertices([])
        }
      } else {
        console.error('Error al cargar rutas:', response.message)
        setMensaje({ texto: response.message || 'Error al cargar rutas', tipo: 'error' })
      }
    } catch (error) {
      console.error('Error en cargarRutas:', error)
      setMensaje({ texto: 'Error de conexión con el servidor', tipo: 'error' })
    }
    setCargando(false)
  }

  const cargarEstadisticas = async () => {
    try {
      const response: ApiResponse = await ApiService.obtenerEstadisticas()
      console.log('Respuesta de estadísticas:', response)
      
      if (response.success && response.estadisticas) {
        setEstadisticas(response.estadisticas)
      }
    } catch (error) {
      console.error('Error en cargarEstadisticas:', error)
    }
  }

  const cargarGrafo = async () => {
    setCargando(true)
    const url = await ApiService.obtenerGrafo()
    if (url) {
      setImagenGrafo(url)
    } else {
      setMensaje({ texto: 'Error al cargar el grafo', tipo: 'error' })
    }
    setCargando(false)
  }

  const handleRegistrarRuta = async (e: React.FormEvent) => {
  e.preventDefault()
  
  if (!origen || !destino) {
    setMensaje({ texto: 'Por favor seleccione origen y destino', tipo: 'error' })
    setTimeout(() => setMensaje(null), 3000)
    return
  }
  
  if (origen === destino) {
    setMensaje({ texto: 'Origen y destino no pueden ser iguales', tipo: 'error' })
    setTimeout(() => setMensaje(null), 3000)
    return
  }
  
  const distanciaNum = parseFloat(distancia)
  if (isNaN(distanciaNum) || distanciaNum <= 0) {
    setMensaje({ texto: 'Por favor ingrese una distancia válida mayor a 0', tipo: 'error' })
    setTimeout(() => setMensaje(null), 3000)
    return
  }
  
  setCargando(true)
  
  const response: ApiResponse = await ApiService.registrarRuta(origen, destino, distanciaNum)
  
  if (response.success) {
    setMensaje({ texto: response.message || 'Ruta registrada exitosamente', tipo: 'exito' })
    setOrigen('')
    setDestino('')
    setDistancia('')
    await cargarRutas()
    await cargarEstadisticas()
  } else {
    setMensaje({ texto: response.message || 'Error al registrar ruta', tipo: 'error' })
  }
  
  setCargando(false)
  setTimeout(() => setMensaje(null), 3000)
}

  const handleBuscarRuta = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!origenBusqueda || !destinoBusqueda) {
      setMensaje({ texto: 'Por favor seleccione origen y destino', tipo: 'error' })
      setTimeout(() => setMensaje(null), 3000)
      return
    }
    
    setCargando(true)
    
    const response: ApiResponse = await ApiService.obtenerRutaMasCorta(origenBusqueda, destinoBusqueda)
    
    if (response.success && response.ruta) {
      setResultadoRuta(response.ruta)
      setMensaje({ texto: response.message || 'Ruta encontrada', tipo: 'exito' })
    } else {
      setResultadoRuta(null)
      setMensaje({ texto: response.message || 'No se encontró una ruta', tipo: 'error' })
    }
    
    setCargando(false)
    setTimeout(() => setMensaje(null), 3000)
  }

  const handleCargarRutasArchivo = async () => {
    setCargando(true)
    const response: ApiResponse = await ApiService.cargarRutas()
    
    if (response.success) {
      setMensaje({ texto: response.message || 'Rutas cargadas exitosamente', tipo: 'exito' })
      await cargarRutas()
      await cargarEstadisticas()
    } else {
      setMensaje({ texto: response.message || 'Error al cargar rutas', tipo: 'error' })
    }
    
    setCargando(false)
    setTimeout(() => setMensaje(null), 3000)
  }

  return (
    <div className="relative min-h-screen overflow-hidden bg-gradient-to-br from-black via-gray-900 to-blue-900">
      <Header />
      
      <div className="relative container mx-auto px-4 py-8">
        {/* Botones de navegación */}
        <div className="flex justify-center gap-4 mb-8 flex-wrap">
          <button
            onClick={() => setVistaActiva('registrar')}
            className={`px-6 py-2 rounded-lg font-bold transition-all duration-300 ${
              vistaActiva === 'registrar'
                ? 'bg-blue-600 text-white shadow-lg transform scale-105'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }`}
          >
            Registrar Ruta
          </button>
          <button
            onClick={() => {
              setVistaActiva('camino')
              cargarGrafo()
            }}
            className={`px-6 py-2 rounded-lg font-bold transition-all duration-300 ${
              vistaActiva === 'camino'
                ? 'bg-blue-600 text-white shadow-lg transform scale-105'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }`}
          >
            Camino Más Corto
          </button>
          <button
            onClick={() => {
              setVistaActiva('graficar')
              cargarGrafo()
            }}
            className={`px-6 py-2 rounded-lg font-bold transition-all duration-300 ${
              vistaActiva === 'graficar'
                ? 'bg-blue-600 text-white shadow-lg transform scale-105'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }`}
          >
            Ver Grafos
          </button>
          <button
            onClick={() => setVistaActiva('grafos')}
            className={`px-6 py-2 rounded-lg font-bold transition-all duration-300 ${
              vistaActiva === 'grafos'
                ? 'bg-purple-600 text-white shadow-lg transform scale-105'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }`}
          >
            Generar Grafos
          </button>
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
          {/* Registrar Ruta */}
          {vistaActiva === 'registrar' && (
            <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
              <h2 className="text-2xl font-bold text-white mb-6">Registrar Nueva Ruta</h2>
              
              <div className="mb-4">
                <button
                  onClick={handleCargarRutasArchivo}
                  className="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300"
                >
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
                  {vertices.length === 0 && (
                    <p className="text-yellow-400 text-xs mt-1">
                      No hay vértices. Primero carga rutas desde archivo o registra ubicaciones.
                    </p>
                  )}
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
                  <p className="text-gray-500 text-xs mt-1">Ingrese la distancia entre el origen y el destino</p>
                </div>

                <button
                  type="submit"
                  disabled={cargando || vertices.length === 0}
                  className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 transform hover:scale-105 disabled:opacity-50"
                >
                  {cargando ? 'Registrando...' : 'Registrar Ruta'}
                </button>
              </form>

              {vertices.length === 0 && (
                <div className="mt-4 p-3 bg-yellow-500/20 border border-yellow-500/50 rounded-lg">
                  <p className="text-yellow-300 text-sm text-center">
                    ⚠️ No hay vértices disponibles. 
                    <button 
                      onClick={handleCargarRutasArchivo}
                      className="ml-2 underline hover:text-yellow-200"
                    >
                      Haz clic aquí para cargar rutas desde archivo
                    </button>
                    {' '}o ve a la pestaña de Registro para agregar ubicaciones.
                  </p>
                </div>
              )}
            </div>
          )}

          {/* Camino Más Corto */}
          {vistaActiva === 'camino' && (
            <div className="space-y-6">
              <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
                <h2 className="text-2xl font-bold text-white mb-6">Buscar Camino Más Corto</h2>
                
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
                    className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 transform hover:scale-105"
                  >
                    {cargando ? 'Buscando...' : 'Buscar Ruta'}
                  </button>
                </form>

                {resultadoRuta && resultadoRuta.existe && (
                  <div className="mt-6 p-4 bg-green-900/50 rounded-lg">
                    <h3 className="text-xl font-bold text-green-400 mb-2">✅ Ruta Encontrada</h3>
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
                    <h3 className="text-xl font-bold text-red-400 mb-2">❌ Ruta No Encontrada</h3>
                    <p className="text-white">
                      No existe un camino desde <strong>{origenBusqueda}</strong> hasta <strong>{destinoBusqueda}</strong>
                    </p>
                  </div>
                )}
              </div>

              {imagenGrafo && (
                <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
                  <h3 className="text-xl font-bold text-white mb-4">Visualización del Grafo</h3>
                  <img src={imagenGrafo} alt="Grafo de rutas" className="w-full rounded-lg" />
                </div>
              )}
            </div>
          )}

          {/* Ver Grafos */}
          {vistaActiva === 'graficar' && (
            <div className="space-y-6">
              {estadisticas && (
                <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
                  <h2 className="text-2xl font-bold text-white mb-4">Estadísticas del Grafo</h2>
                  <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <div className="bg-gray-800 p-4 rounded-lg">
                      <p className="text-blue-300 text-sm">Vértices</p>
                      <p className="text-white text-2xl font-bold">{estadisticas.total_vertices}</p>
                    </div>
                    <div className="bg-gray-800 p-4 rounded-lg">
                      <p className="text-blue-300 text-sm">Rutas</p>
                      <p className="text-white text-2xl font-bold">{estadisticas.total_rutas}</p>
                    </div>
                    <div className="bg-gray-800 p-4 rounded-lg">
                      <p className="text-blue-300 text-sm">Distancia Total</p>
                      <p className="text-white text-2xl font-bold">{estadisticas.distancia_total} km</p>
                    </div>
                    <div className="bg-gray-800 p-4 rounded-lg">
                      <p className="text-blue-300 text-sm">Distancia Promedio</p>
                      <p className="text-white text-2xl font-bold">{estadisticas.distancia_promedio?.toFixed(1) || 0} km</p>
                    </div>
                  </div>
                </div>
              )}

              <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
                <h2 className="text-2xl font-bold text-white mb-4">Lista de Rutas Registradas</h2>
                
                {cargando ? (
                  <p className="text-white">Cargando...</p>
                ) : rutas.length === 0 ? (
                  <p className="text-gray-400">No hay rutas registradas aún</p>
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

              {imagenGrafo && (
                <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
                  <h2 className="text-2xl font-bold text-white mb-4">Visualización del Grafo</h2>
                  <img src={imagenGrafo} alt="Grafo de rutas" className="w-full rounded-lg" />
                </div>
              )}
            </div>
          )}

          {/* Generar Grafos */}
          {vistaActiva === 'grafos' && (
            <div className="max-w-6xl mx-auto">
              <GestorGrafos />
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default Principal