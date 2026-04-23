import axios from 'axios';

const API_BASE_URL = 'http://localhost:3005/api';

export type Amigo = {
  nombre: string;
  desde: string;
}

export type Solicitud = {
  usuario: string;
  desde: string;
}

export type Sugerencia = {
  usuario: string;
  amigos_en_comun: number;
}

export type Estadisticas = {
  total_usuarios: number;
  total_amistades: number;
  total_solicitudes_pendientes: number;
  grado_promedio: string;
}

export type GrafoGenerado = {
  dot: string;
  png: string;
  nombre: string;
  tamaño: number;
  modificado: string;
}

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const authService = {
  registro: (usuario: string, password: string) =>
    api.post('/registro', { usuario, password }),
  
  login: (usuario: string, password: string) =>
    api.post('/login', { usuario, password }),
};

export const amistadService = {
  enviarSolicitud: (solicitante: string, destinatario: string) =>
    api.post('/amistad/solicitar', { solicitante, destinatario }),
  
  aceptarSolicitud: (usuario: string, solicitante: string) =>
    api.post('/amistad/aceptar', { usuario, solicitante }),
  
  rechazarSolicitud: (usuario: string, solicitante: string) =>
    api.post('/amistad/rechazar', { usuario, solicitante }),
  
  obtenerAmigos: (usuario: string) =>
    api.get(`/amigos/${usuario}`),
  
  obtenerSolicitudes: (usuario: string) =>
    api.get(`/solicitudes/${usuario}`),
  
  obtenerSugerencias: (usuario: string) =>
    api.get(`/sugerencias/${usuario}`),
};

export const grafoService = {
  obtenerEstadisticas: () =>
    api.get('/estadisticas'),
  
  obtenerUsuarios: () =>
    api.get('/usuarios'),
  
  obtenerGrafoDot: (usuario: string) =>
    api.get(`/grafo/dot/${usuario}`),
  
  obtenerGrafoImagen: (usuario: string) =>
    api.get(`/grafo/imagen/${usuario}`, { responseType: 'blob' }),
  
  generarGrafo: (usuario: string, nombre: string) =>
    api.post('/grafo/generar', { usuario, nombre }),
  
  listarGrafos: () =>
    api.get('/grafo/listar'),
  
  descargarGrafo: (nombre: string, formato: 'png' | 'dot') =>
    api.get(`/grafo/descargar/${nombre}?formato=${formato}`, { responseType: 'blob' }),
  
  eliminarGrafo: (nombre: string) =>
    api.delete(`/grafo/eliminar/${nombre}`),
};

export default api;