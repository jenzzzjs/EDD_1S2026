import { useState, useEffect } from 'react'
import ApiService from '../servicios/api'
import type { ApiResponse, GrafoInfo } from '../servicios/api'

function GestorGrafos() {
  const [grafos, setGrafos] = useState<GrafoInfo[]>([])
  const [nombreGrafo, setNombreGrafo] = useState<string>('grafo_rutas')
  const [cargando, setCargando] = useState<boolean>(false)
  const [mensaje, setMensaje] = useState<{ texto: string; tipo: 'exito' | 'error' } | null>(null)

  useEffect(() => {
    cargarListaGrafos()
  }, [])

  const cargarListaGrafos = async (): Promise<void> => {
    setCargando(true)
    const response: ApiResponse = await ApiService.listarGrafos()
    if (response.success && response.grafos) {
      setGrafos(response.grafos)
    }
    setCargando(false)
  }

  const handleGenerarGrafo = async (e: React.FormEvent<HTMLFormElement>): Promise<void> => {
    e.preventDefault()
    setCargando(true)
    
    const response: ApiResponse = await ApiService.generarGrafo(nombreGrafo)
    
    if (response.success) {
      const archivosInfo = response.archivos
        ? `Archivos: ${response.archivos.dot} y ${response.archivos.png}`
        : 'Grafo generado exitosamente'
      
      setMensaje({ 
        texto: `Grafo generado: ${archivosInfo}`, 
        tipo: 'exito' 
      })
      setNombreGrafo('grafo_rutas')
      await cargarListaGrafos()
    } else {
      setMensaje({ texto: response.message || 'Error al generar el grafo', tipo: 'error' })
    }
    
    setCargando(false)
    setTimeout(() => setMensaje(null), 3000)
  }

  const handleDescargar = async (nombre: string, formato: string): Promise<void> => {
    setCargando(true)
    const result = await ApiService.descargarGrafo(nombre, formato)
    if (result.success) {
      setMensaje({ texto: `Descargando ${nombre}.${formato}`, tipo: 'exito' })
    } else {
      setMensaje({ texto: result.message || 'Error al descargar', tipo: 'error' })
    }
    setCargando(false)
    setTimeout(() => setMensaje(null), 2000)
  }

  const handleEliminar = async (nombre: string): Promise<void> => {
    if (confirm(`¿Eliminar el grafo "${nombre}"?`)) {
      setCargando(true)
      const response: ApiResponse = await ApiService.eliminarGrafo(nombre)
      if (response.success) {
        setMensaje({ texto: response.message || 'Grafo eliminado', tipo: 'exito' })
        await cargarListaGrafos()
      } else {
        setMensaje({ texto: response.message || 'Error al eliminar', tipo: 'error' })
      }
      setCargando(false)
      setTimeout(() => setMensaje(null), 3000)
    }
  }

  const formatearTamaño = (bytes: number): string => {
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  }

  return (
    <div className="space-y-6">
      {mensaje && (
        <div className={`fixed top-20 right-4 p-4 rounded-lg shadow-lg z-50 ${
          mensaje.tipo === 'exito' ? 'bg-green-500' : 'bg-red-500'
        } text-white`}>
          {mensaje.texto}
        </div>
      )}

      {/* Formulario para generar nuevo grafo */}
      <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
        <h2 className="text-2xl font-bold text-white mb-6">Generar Nuevo Grafo</h2>
        
        <form onSubmit={handleGenerarGrafo} className="space-y-4">
          <div>
            <label className="block text-blue-300 text-sm font-bold mb-2">
              Nombre del Grafo
            </label>
            <input
              type="text"
              value={nombreGrafo}
              onChange={(e) => setNombreGrafo(e.target.value)}
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500"
              placeholder="Ej: grafo_rutas_2024"
              required
            />
            <p className="text-gray-500 text-xs mt-1">
              Se generarán archivos {nombreGrafo}.dot y {nombreGrafo}.png
            </p>
          </div>

          <button
            type="submit"
            disabled={cargando}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 transform hover:scale-105 disabled:opacity-50"
          >
            {cargando ? 'Generando...' : 'Generar Grafo'}
          </button>
        </form>
      </div>

      {/* Lista de grafos generados */}
      <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
        <h2 className="text-2xl font-bold text-white mb-4">Grafos Generados</h2>
        
        {cargando && grafos.length === 0 ? (
          <p className="text-white">Cargando...</p>
        ) : grafos.length === 0 ? (
          <div className="text-center py-8">
            <p className="text-gray-400">No hay grafos generados aún</p>
            <p className="text-gray-500 text-sm mt-2">
              Use el formulario superior para generar un nuevo grafo
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {grafos.map((grafo, index) => (
              <div key={index} className="bg-gray-800 rounded-lg p-4">
                <div className="flex justify-between items-start mb-3">
                  <div>
                    <h3 className="text-white font-bold text-lg">{grafo.nombre}</h3>
                    <p className="text-gray-400 text-xs">
                      {formatearTamaño(grafo.tamaño)} • {grafo.modificado}
                    </p>
                  </div>
                  <div className="flex gap-2">
                    {grafo.png && (
                      <button
                        onClick={() => handleDescargar(grafo.nombre, 'png')}
                        className="bg-green-600 hover:bg-green-700 text-white px-3 py-1 rounded text-sm transition-all"
                      >
                        PNG
                      </button>
                    )}
                    {grafo.dot && (
                      <button
                        onClick={() => handleDescargar(grafo.nombre, 'dot')}
                        className="bg-yellow-600 hover:bg-yellow-700 text-white px-3 py-1 rounded text-sm transition-all"
                      >
                        DOT
                      </button>
                    )}
                    <button
                      onClick={() => handleEliminar(grafo.nombre)}
                      className="bg-red-600 hover:bg-red-700 text-white px-3 py-1 rounded text-sm transition-all"
                    >
                      Eliminar
                    </button>
                  </div>
                </div>
                
                {/* Vista previa del grafo */}
                {grafo.png && (
                  <div className="mt-2">
                    <img 
                      src={`http://localhost:3004/${grafo.png}`}
                      alt={grafo.nombre}
                      className="w-full rounded-lg border border-gray-700 cursor-pointer hover:border-blue-500 transition-all"
                      onClick={() => window.open(`http://localhost:3004/${grafo.png}`, '_blank')}
                      onError={(e) => {
                        (e.target as HTMLImageElement).src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="200" height="200" viewBox="0 0 200 200"%3E%3Crect width="200" height="200" fill="%23333"%3E%3C/rect%3E%3Ctext x="50%25" y="50%25" text-anchor="middle" fill="%23fff" dy=".3em"%3EImagen no disponible%3C/text%3E%3C/svg%3E'
                      }}
                    />
                    <p className="text-gray-500 text-xs text-center mt-2">
                      Click en la imagen para ver en tamaño completo
                    </p>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Información de GraphViz */}
      <div className="bg-blue-900/30 rounded-lg p-4">
        <h3 className="text-blue-300 font-bold mb-2">📊 Información de GraphViz</h3>
        <p className="text-gray-300 text-sm">
          Los grafos se generan usando GraphViz y se guardan como archivos PNG y DOT en el servidor.
          Puedes descargarlos para usarlos en tus reportes o documentación.
        </p>
        <p className="text-gray-400 text-xs mt-2">
          Ubicación de los archivos: Directorio del backend Perl
        </p>
      </div>
    </div>
  )
}

export default GestorGrafos