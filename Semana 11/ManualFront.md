

como crear un frontend sencillo utilizando react

pasos

paso 1

```bash
npm create vite@latest frontend -- --template react-ts
cd frontend
```
paso 2 - instalacion de tailwindcss

```bash
npm install -D tailwindcss@3 postcss autoprefixer
npx tailwindcss init -p
```


paso 3 - modificacion de archivos

creamos un archivo tailwind.config.js y colocamos la siguiente configuracion

```json
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```




modificamos el archivo index.css con el siguiente codigo

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

```


modificamos el archivo App.tsx
```typescript
import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [showEDD, setShowEDD] = useState(false)
  const [textIndex, setTextIndex] = useState(0)
  
  const messages = [
    "Que onda mucha",
    "Si sale EDD",
    "Feliz semana santa",
    "Feliz Descanso"
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
                EDD
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
```


modificamos el main.tsx


```typescript
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
```

Modificamos el archivo App.css

```css
@keyframes gradient-x {
  0%, 100% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-10px);
  }
}

.animate-gradient-x {
  background-size: 300% 300%;
  animation: gradient-x 3s ease infinite;
}

.animate-float {
  animation: float 3s ease-in-out infinite;
}
```



y ya estaria, si les da un problema de vite.svg, coloquen lo siguiente


```bash
cat > public/vite.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 410 404">
  <path fill="currentColor" d="M399.64 59.52L215.66 388.17c-3.75 6.53-13.23 6.57-17.03.07L10.36 59.52c-4.14-7.07.47-15.97 8.43-16.18l180.94-4.68c5.13-.13 10.22.06 15.29.57l180.55 6.08c7.87.27 12.47 8.92 8.07 15.73z"/>
  <path fill="url(#a)" d="M399.64 59.52L215.66 388.17c-3.75 6.53-13.23 6.57-17.03.07L10.36 59.52c-4.14-7.07.47-15.97 8.43-16.18l180.94-4.68c5.13-.13 10.22.06 15.29.57l180.55 6.08c7.87.27 12.47 8.92 8.07 15.73z"/>
  <defs>
    <linearGradient id="a" x1="206.07" y1="13.48" x2="206.07" y2="401.04" gradientUnits="userSpaceOnUse">
      <stop stop-color="#41D1FF"/>
      <stop offset="1" stop-color="#BD34FE"/>
    </linearGradient>
  </defs>
</svg>
EOF
```

