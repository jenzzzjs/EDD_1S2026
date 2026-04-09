declare module '../servicios/api' {
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
  }

  export interface ApiResponse {
    success: boolean;
    message?: string;
    rutas?: Ruta[];
    vertices?: string[];
    ruta?: RutaResultado;
    estadisticas?: {
      total_vertices: number;
      total_rutas: number;
      distancia_total: number;
      distancia_promedio: number;
      vertices: string[];
    };
    total_rutas?: number;
  }

  const ApiService: {
    cargarRutas(archivo?: string): Promise<ApiResponse>;
    registrarRuta(origen: string, destino: string, distancia: number): Promise<ApiResponse>;
    obtenerRutaMasCorta(origen: string, destino: string): Promise<ApiResponse>;
    obtenerTodasRutas(): Promise<ApiResponse>;
    obtenerEstadisticas(): Promise<ApiResponse>;
    obtenerGrafo(): Promise<string | null>;
    registrarUbicacion(departamento: string, municipio: string): Promise<ApiResponse>;
    eliminarTodasRutas(): Promise<ApiResponse>;
  };

  export default ApiService;
}