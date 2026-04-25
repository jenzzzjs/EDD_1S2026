// src/services/api.ts
import axios from 'axios';

const API_BASE_URL = 'http://localhost:3006/api';

export type Estudiante = {
  carnet: string;
  nombre: string;
  edad: number;
  curso: string;
  semestre: number;
  creado: string;
}

export type Curso = {
  nombre: string;
  slot: number;
}

export type SlotInfo = {
  indice: number;
  cursos: string;
  cantidad_cursos: number;
  cantidad_estudiantes: number;
  colisiones_estudiantes: number;
  esta_vacio: boolean;
}

export type EstadisticasHash = {
  total_estudiantes: number;
  total_cursos: number;
  capacidad: number;
  slots: SlotInfo[];
  factor_carga: string;
  cursos_registrados: Record<string, number>;
}

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const cursosService = {
  registrar: (curso: string) => api.post('/cursos/registrar', { curso }),
  listar: () => api.get('/cursos'),
};

export const estudiantesService = {
  listar: () => api.get('/estudiantes'),
  registrar: (estudiante: Omit<Estudiante, 'creado'>) => 
    api.post('/estudiantes', estudiante),
  buscarPorCarnet: (carnet: string) => 
    api.get(`/estudiantes/${carnet}`),
  buscarPorCurso: (curso: string) => 
    api.get(`/curso/${curso}`),
  eliminar: (carnet: string, curso: string) => 
    api.delete(`/estudiantes/${carnet}/${curso}`),
  obtenerEstadisticas: () => 
    api.get('/estadisticas'),
  visualizarHash: () => 
    api.get('/hash/grafo', { responseType: 'blob' }),
  obtenerDot: () => 
    api.get('/hash/dot', { responseType: 'text' }),
};

export default api;