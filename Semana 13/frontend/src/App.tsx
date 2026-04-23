import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import './App.css';
import Login from './pages/Login';
import Registro from './pages/Registro';
import Amistades from './pages/Amistades';
import Solicitudes from './pages/Solicitudes';

function App() {
  const isAuthenticated = () => {
    return !!localStorage.getItem('usuario');
  };

  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/registro" element={<Registro />} />
        <Route
          path="/amistades"
          element={
            isAuthenticated() ? <Amistades /> : <Navigate to="/login" />
          }
        />
        <Route
          path="/solicitudes"
          element={
            isAuthenticated() ? <Solicitudes /> : <Navigate to="/login" />
          }
        />
        <Route path="/" element={<Navigate to="/login" />} />
      </Routes>
    </Router>
  );
}

export default App;
