import { useState } from 'react'

function FormularioRuta() {
  const [origen, setOrigen] = useState('')
  const [destino, setDestino] = useState('')
  const [distancia, setDistancia] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // Aquí guardaremos los datos más adelante
    console.log({ origen, destino, distancia })
    alert('Ruta registrada correctamente')
    // Limpiar formulario
    setOrigen('')
    setDestino('')
    setDistancia('')
  }

  return (
    <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-xl">
      <h2 className="text-2xl font-bold text-white mb-6">Registrar Nueva Ruta</h2>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-blue-300 text-sm font-bold mb-2">
            Origen
          </label>
          <input
            type="text"
            value={origen}
            onChange={(e) => setOrigen(e.target.value)}
            className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500 transition-colors"
            placeholder="Ej: Ciudad de Guatemala"
            required
          />
        </div>

        <div>
          <label className="block text-blue-300 text-sm font-bold mb-2">
            Destino
          </label>
          <input
            type="text"
            value={destino}
            onChange={(e) => setDestino(e.target.value)}
            className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500 transition-colors"
            placeholder="Ej: Antigua Guatemala"
            required
          />
        </div>

        <div>
          <label className="block text-blue-300 text-sm font-bold mb-2">
            Distancia (km)
          </label>
          <input
            type="number"
            value={distancia}
            onChange={(e) => setDistancia(e.target.value)}
            className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:border-blue-500 transition-colors"
            placeholder="Ej: 45"
            required
            min="0"
            step="0.1"
          />
        </div>

        <button
          type="submit"
          className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-all duration-300 transform hover:scale-105"
        >
          Registrar Ruta
        </button>
      </form>
    </div>
  )
}

export default FormularioRuta