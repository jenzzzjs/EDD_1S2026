import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Principal from './componentes/Principal'
import Registro from './vistas/Registro'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Principal />} />
        <Route path="/registro" element={<Registro />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App