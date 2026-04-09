import { Link, useLocation } from 'react-router-dom'

function Header() {
  const location = useLocation()

  return (
    <header className="bg-gradient-to-r from-gray-900 to-blue-900 shadow-lg">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          {/* Logo o título */}
          <div className="text-white font-bold text-xl">
            Sistema de Rutas
          </div>

          {/* Menú de navegación */}
          <nav className="flex space-x-4">
            <Link
              to="/"
              className={`px-4 py-2 rounded-lg transition-all duration-300 ${
                location.pathname === '/'
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-300 hover:bg-blue-700 hover:text-white'
              }`}
            >
              Principal
            </Link>
            <Link
              to="/registro"
              className={`px-4 py-2 rounded-lg transition-all duration-300 ${
                location.pathname === '/registro'
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-300 hover:bg-blue-700 hover:text-white'
              }`}
            >
              Registro
            </Link>
          </nav>
        </div>
      </div>
    </header>
  )
}

export default Header