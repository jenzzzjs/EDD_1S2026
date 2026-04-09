import { useState } from 'react'
import Header from '../componentes/Header'

import ApiService from '../servicios/api'
import type { ApiResponse } from '../servicios/api'

function Registro() {
  const [departamento, setDepartamento] = useState('')
  const [municipio, setMunicipio] = useState('')
  const [mensaje, setMensaje] = useState<{ texto: string; tipo: 'exito' | 'error' } | null>(null)
  const [cargando, setCargando] = useState(false)

  const departamentos = [
    'Guatemala',
    'Sacatepéquez',
    'Escuintla',
    'Chimaltenango',
    'Quetzaltenango',
    'Huehuetenango',
    'Petén',
    'Alta Verapaz',
    'Baja Verapaz',
    'Izabal',
    'San Marcos',
    'Sololá',
    'Totonicapán',
    'Suchitepéquez',
    'Retalhuleu'
  ]

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setCargando(true)
    
    const response = await ApiService.registrarUbicacion(departamento, municipio)
    
    if (response.success) {
      setMensaje({ 
        texto: response.message || `Ubicación "${municipio}, ${departamento}" registrada exitosamente`, 
        tipo: 'exito' 
      })
      setDepartamento('')
      setMunicipio('')
      
      // Disparar evento para actualizar la lista de vértices en Principal
      window.dispatchEvent(new CustomEvent('ubicacionRegistrada', { 
        detail: { ubicacion: `${municipio}, ${departamento}` }
      }))
    } else {
      setMensaje({ texto: response.message || 'Error al registrar ubicación', tipo: 'error' })
    }
    
    setCargando(false)
    setTimeout(() => setMensaje(null), 3000)
  }

  return (
    <div className="relative min-h-screen overflow-hidden bg-gradient-to-br from-black via-gray-900 to-blue-900">
      <Header />
      
      <div className="relative container mx-auto px-4 py-12">
        {mensaje && (
          <div className={`fixed top-20 right-4 p-4 rounded-lg shadow-lg z-50 ${
            mensaje.tipo === 'exito' ? 'bg-green-500' : 'bg-red-500'
          } text-white`}>
            {mensaje.texto}
          </div>
        )}

        <div className="max-w-2xl mx-auto">
          <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-8 shadow-xl">
            <h1 className="text-3xl font-bold text-white text-center mb-8">
              Registro de Ubicación
            </h1>
            
            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <label className="block text-blue-300 text-sm font-bold mb-2">
                  Departamento
                </label>
                <select
                  value={departamento}
                  onChange={(e) => setDepartamento(e.target.value)}
                  className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500 transition-colors"
                  required
                >
                  <option value="">Seleccione un departamento</option>
                  {departamentos.map((dept) => (
                    <option key={dept} value={dept}>
                      {dept}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-blue-300 text-sm font-bold mb-2">
                  Municipio
                </label>
                <input
                  type="text"
                  value={municipio}
                  onChange={(e) => setMunicipio(e.target.value)}
                  className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500 transition-colors"
                  placeholder="Ingrese el municipio"
                  required
                />
                <p className="text-gray-500 text-xs mt-1">
                  Ejemplo: Ciudad de Guatemala, Mixco, Villa Nueva, etc.
                </p>
              </div>

              <button
                type="submit"
                disabled={cargando}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition-all duration-300 transform hover:scale-105 disabled:opacity-50"
              >
                {cargando ? 'Registrando...' : 'Registrar Ubicación'}
              </button>
            </form>

            <div className="mt-8 p-4 bg-blue-900/30 rounded-lg">
              <p className="text-blue-300 text-sm text-center">
                📍 Las ubicaciones registradas se agregarán automáticamente al grafo de rutas
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Registro