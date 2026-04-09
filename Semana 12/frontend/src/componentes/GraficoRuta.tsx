import { useState } from 'react'

// Tipo para las rutas registradas
interface Ruta {
  id: number
  origen: string
  destino: string
  distancia: number
}

function GraficoRuta() {
  const [rutas] = useState<Ruta[]>([
    // Datos de ejemplo - luego se conectarán con el almacenamiento
    { id: 1, origen: 'Ciudad de Guatemala', destino: 'Antigua Guatemala', distancia: 45 },
    { id: 2, origen: 'Ciudad de Guatemala', destino: 'Lake Atitlán', distancia: 140 },
    { id: 3, origen: 'Antigua Guatemala', destino: 'Lake Atitlán', distancia: 95 },
  ])

  return (
    <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
      <h2 className="text-2xl font-bold text-white mb-6">Visualización de Rutas</h2>
      
      {rutas.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-gray-400 text-lg">No hay rutas registradas aún</p>
          <p className="text-gray-500 mt-2">Ve a la sección de registro para agregar rutas</p>
        </div>
      ) : (
        <div className="space-y-6">
          {/* Gráfico simple de barras */}
          <div className="space-y-3">
            <h3 className="text-xl font-semibold text-blue-300 mb-4">
              Distancias por Ruta
            </h3>
            {rutas.map((ruta) => (
              <div key={ruta.id} className="space-y-1">
                <div className="flex justify-between text-sm text-gray-300">
                  <span>{ruta.origen} → {ruta.destino}</span>
                  <span>{ruta.distancia} km</span>
                </div>
                <div className="w-full bg-gray-700 rounded-full h-8 overflow-hidden">
                  <div
                    className="bg-gradient-to-r from-blue-500 to-blue-700 h-full rounded-full flex items-center justify-end pr-3 text-white text-sm font-bold transition-all duration-1000"
                    style={{ width: `${Math.min((ruta.distancia / 200) * 100, 100)}%` }}
                  >
                    {ruta.distancia > 0 && `${ruta.distancia} km`}
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Tabla de rutas */}
          <div className="mt-8">
            <h3 className="text-xl font-semibold text-blue-300 mb-4">
              Listado de Rutas
            </h3>
            <div className="overflow-x-auto">
              <table className="w-full text-left">
                <thead className="bg-gray-800 rounded-lg">
                  <tr>
                    <th className="px-4 py-2 text-blue-300">Origen</th>
                    <th className="px-4 py-2 text-blue-300">Destino</th>
                    <th className="px-4 py-2 text-blue-300">Distancia (km)</th>
                  </tr>
                </thead>
                <tbody>
                  {rutas.map((ruta) => (
                    <tr key={ruta.id} className="border-t border-gray-700">
                      <td className="px-4 py-2 text-gray-300">{ruta.origen}</td>
                      <td className="px-4 py-2 text-gray-300">{ruta.destino}</td>
                      <td className="px-4 py-2 text-gray-300">{ruta.distancia}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Resumen estadístico */}
          <div className="mt-8 p-4 bg-gray-800/50 rounded-lg">
            <h3 className="text-lg font-semibold text-blue-300 mb-2">
              Resumen
            </h3>
            <p className="text-gray-300">
              Total de rutas: {rutas.length} | 
              Distancia promedio: {(rutas.reduce((acc, r) => acc + r.distancia, 0) / rutas.length).toFixed(1)} km |
              Distancia total: {rutas.reduce((acc, r) => acc + r.distancia, 0)} km
            </p>
          </div>
        </div>
      )}
    </div>
  )
}

export default GraficoRuta