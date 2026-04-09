// variable para manejar la ruta hacia el backend
const API_URL = 'http://localhost:3004/api';

export interface Ruta {
  origen: string;
  destino: string;
  distancia: number;
}

export interface RutaResultado {
  origen: string;
  destino: string;
  distancia: number;
  camino: string[];
  existe: boolean;
  mensaje?: string;
}

export interface Estadisticas {
  total_vertices: number;
  total_rutas: number;
  distancia_total: number;
  distancia_promedio: number;
  vertices: string[];
}

export interface GrafoInfo {
  nombre: string;
  png: string;
  tamaño: number;
  modificado: string;
}

export interface ApiResponse {
  success: boolean;
  message?: string;
  rutas?: Ruta[];
  vertices?: string[];
  ruta?: RutaResultado;
  estadisticas?: Estadisticas;
  total_rutas?: number;
  total_vertices?: number;
  ubicacion?: string;
  ubicaciones?: string[];
  timestamp?: string;
  archivos?: {
    dot: string;
    png: string;
  };
  grafos?: GrafoInfo[];
  total?: number;
}

class ApiService {
  static async cargarRutas(archivo: string = 'rutas.dat'): Promise<ApiResponse> {
    try {
      const response = await fetch(`${API_URL}/rutas/cargar`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ archivo })
      });
      return await response.json();
    } catch (error: any) {
      console.error('Error al cargar rutas:', error);
      return { success: false, message: error.message };
    }
  }

  static async registrarRuta(origen: string, destino: string, distancia: number): Promise<ApiResponse> {
    try {
      const response = await fetch(`${API_URL}/rutas`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ origen, destino, distancia: parseFloat(String(distancia)) })
      });
      return await response.json();
    } catch (error: any) {
      console.error('Error al registrar ruta:', error);
      return { success: false, message: error.message };
    }
  }

  static async obtenerRutaMasCorta(origen: string, destino: string): Promise<ApiResponse> {
    try {
      const response = await fetch(`${API_URL}/rutas/camino-corto`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ origen, destino })
      });
      return await response.json();
    } catch (error: any) {
      console.error('Error al obtener ruta:', error);
      return { success: false, message: error.message };
    }
  }

  static async obtenerTodasRutas(): Promise<ApiResponse> {
    try {
      const response = await fetch(`${API_URL}/rutas`);
      const data = await response.json();
      return data;
    } catch (error: any) {
      console.error('Error al obtener rutas:', error);
      return { success: false, message: error.message, rutas: [], vertices: [] };
    }
  }

  static async obtenerEstadisticas(): Promise<ApiResponse> {
    try {
      const response = await fetch(`${API_URL}/estadisticas`);
      return await response.json();
    } catch (error: any) {
      console.error('Error al obtener estadísticas:', error);
      return { success: false, message: error.message };
    }
  }

  static async obtenerGrafo(tamaño: 'pequeno' | 'mediano' | 'grande' = 'pequeno'): Promise<string | null> {
    try {
      const response = await fetch(`${API_URL}/grafo/generar`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
          nombre: 'temp_grafo',
          tamaño: tamaño
        })
      });
      
      const data = await response.json();
      if (data.success && data.archivos && data.archivos.png) {
        const imgResponse = await fetch(`/${data.archivos.png}`);
        const blob = await imgResponse.blob();
        return URL.createObjectURL(blob);
      }
      return null;
    } catch (error: any) {
      console.error('Error al obtener grafo:', error);
      return null;
    }
  }

  static async generarGrafoConCamino(nombre: string, camino: string[] | null = null, tamaño: 'pequeno' | 'mediano' | 'grande' = 'pequeno'): Promise<ApiResponse> {
    try {
      const response = await fetch(`${API_URL}/grafo/generar`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
          nombre: nombre,
          camino: camino,
          tamaño: tamaño
        })
      });
      return await response.json();
    } catch (error: any) {
      console.error('Error al generar grafo:', error);
      return { success: false, message: error.message };
    }
  }

  static async listarGrafos(): Promise<ApiResponse> {
    try {
      const response = await fetch(`${API_URL}/grafo/listar`);
      return await response.json();
    } catch (error: any) {
      console.error('Error al listar grafos:', error);
      return { success: false, message: error.message };
    }
  }

  static async descargarGrafo(nombre: string, formato: string = 'png'): Promise<{ success: boolean; message?: string }> {
    try {
      const response = await fetch(`${API_URL}/grafo/descargar/${nombre}?formato=${formato}`);
      if (!response.ok) throw new Error('Error al descargar el grafo');
      
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${nombre}.${formato}`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
      
      return { success: true };
    } catch (error: any) {
      console.error('Error al descargar grafo:', error);
      return { success: false, message: error.message };
    }
  }

  static async eliminarGrafo(nombre: string): Promise<ApiResponse> {
    try {
      const response = await fetch(`${API_URL}/grafo/eliminar/${nombre}`, {
        method: 'DELETE'
      });
      return await response.json();
    } catch (error: any) {
      console.error('Error al eliminar grafo:', error);
      return { success: false, message: error.message };
    }
  }

  static async registrarUbicacion(departamento: string, municipio: string): Promise<ApiResponse> {
    try {
      const response = await fetch(`${API_URL}/ubicacion`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ departamento, municipio })
      });
      return await response.json();
    } catch (error: any) {
      console.error('Error al registrar ubicación:', error);
      return { success: false, message: error.message };
    }
  }

  static async obtenerUbicacionesRegistradas(): Promise<ApiResponse> {
    try {
      const response = await fetch(`${API_URL}/ubicaciones`);
      return await response.json();
    } catch (error: any) {
      console.error('Error al obtener ubicaciones:', error);
      return { success: false, message: error.message, ubicaciones: [] };
    }
  }

  static async eliminarTodasRutas(): Promise<ApiResponse> {
    try {
      const response = await fetch(`${API_URL}/rutas`, {
        method: 'DELETE'
      });
      return await response.json();
    } catch (error: any) {
      console.error('Error al eliminar rutas:', error);
      return { success: false, message: error.message };
    }
  }
}

export default ApiService;