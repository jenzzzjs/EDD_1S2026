import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Users, Home, LogOut, UserPlus, UserCheck } from 'lucide-react';

interface NavbarProps {
  usuario: string;
  onLogout: () => void;
}

const Navbar: React.FC<NavbarProps> = ({ usuario, onLogout }) => {
  const navigate = useNavigate();

  const handleLogout = () => {
    onLogout();
    navigate('/login');
  };

  return (
    <nav className="bg-gradient-to-r from-blue-900 to-black shadow-lg border-b border-blue-500/30">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          <Link to="/amistades" className="flex items-center space-x-2">
            <Users className="w-8 h-8 text-blue-400" />
            <span className="text-xl font-bold bg-gradient-to-r from-blue-400 to-blue-600 bg-clip-text text-transparent">
              SocialNet
            </span>
          </Link>

          <div className="flex items-center space-x-4">
            <Link
              to="/amistades"
              className="flex items-center space-x-1 px-3 py-2 rounded-lg hover:bg-blue-500/20 transition-colors"
            >
              <Home className="w-5 h-5" />
              <span>Inicio</span>
            </Link>

            <Link
              to="/solicitudes"
              className="flex items-center space-x-1 px-3 py-2 rounded-lg hover:bg-blue-500/20 transition-colors"
            >
              <UserPlus className="w-5 h-5" />
              <span>Solicitudes</span>
            </Link>

            <div className="flex items-center space-x-2 px-3 py-1 bg-blue-500/20 rounded-lg">
              <UserCheck className="w-4 h-4 text-blue-400" />
              <span className="text-sm font-medium">{usuario}</span>
            </div>

            <button
              onClick={handleLogout}
              className="flex items-center space-x-1 px-3 py-2 rounded-lg bg-red-500/20 hover:bg-red-500/30 transition-colors"
            >
              <LogOut className="w-5 h-5" />
              <span>Salir</span>
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
