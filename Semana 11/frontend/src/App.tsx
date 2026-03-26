import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [showEDD, setShowEDD] = useState(false)
  const [textIndex, setTextIndex] = useState(0)
  
  const messages = [
    "Que onda mucha",
    "Si sale EDD",
    "Feliz Semana Santa",
    "y feliz descanso"
  ]

  useEffect(() => {
    const interval = setInterval(() => {
      setTextIndex((prev) => (prev + 1) % messages.length)
      if (textIndex === 1) {
        setShowEDD(true)
        setTimeout(() => setShowEDD(false), 1000)
      }
    }, 3000)
    
    return () => clearInterval(interval)
  }, [textIndex])

  return (
    <div className="relative min-h-screen overflow-hidden bg-gradient-to-br from-black via-gray-900 to-blue-900">
      {/* Efecto de partículas */}
      <div className="absolute inset-0 opacity-30">
        {[...Array(50)].map((_, i) => (
          <div
            key={i}
            className="absolute bg-blue-500 rounded-full animate-pulse"
            style={{
              width: `${Math.random() * 4 + 2}px`,
              height: `${Math.random() * 4 + 2}px`,
              top: `${Math.random() * 100}%`,
              left: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 5}s`,
              animationDuration: `${Math.random() * 3 + 2}s`
            }}
          />
        ))}
      </div>

      {/* Contenido principal */}
      <div className="relative flex flex-col items-center justify-center min-h-screen px-4">
        {/* Texto animado con mezcla de azul y negro */}
        <div className="text-center space-y-6">
          <h1 className="text-6xl md:text-8xl font-extrabold tracking-tight animate-gradient bg-gradient-to-r from-blue-400 via-blue-600 to-black bg-clip-text text-transparent bg-300% animate-gradient-x">
            {messages[textIndex]}
          </h1>
          
          {/* Efecto EDD cuando aparece */}
          {showEDD && (
            <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
              <div className="text-9xl md:text-9xl font-black text-blue-500 animate-ping opacity-75">
                EDD seccion B
              </div>
            </div>
          )}
          
          {/* Texto secundario con efecto de escritura */}
          <div className="mt-8 space-y-2">
            <p className="text-blue-300 text-lg md:text-xl font-mono animate-pulse">
               Jens hizo esto
            </p>
            <div className="flex justify-center gap-2">
              <span className="px-3 py-1 bg-blue-500/20 border border-blue-500/50 rounded-full text-blue-300 text-sm">
                React
              </span>
              <span className="px-3 py-1 bg-blue-500/20 border border-blue-500/50 rounded-full text-blue-300 text-sm">
                Vite
              </span>
              <span className="px-3 py-1 bg-blue-500/20 border border-blue-500/50 rounded-full text-blue-300 text-sm">
                Tailwind
              </span>
            </div>
          </div>
        </div>

        {/* Efecto de onda en el fondo */}
        <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-black/50 to-transparent" />
      </div>
    </div>
  )
}

export default App
