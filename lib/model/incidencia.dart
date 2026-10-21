enum Prioridad {
  baja,
  media,
  alta;

  String get etiqueta => switch (this) {
        Prioridad.baja => 'Baja',
        Prioridad.media => 'Media',
        Prioridad.alta => 'Alta',
      };

  static Prioridad desdeJson(dynamic valor) {
    return switch (valor?.toString().toLowerCase()) {
      'baja' => Prioridad.baja,
      'alta' => Prioridad.alta,
      _ => Prioridad.media,
    };
  }
}

/// Etiquetas canónicas del estado. Mantener el campo `Incidencia.estado`
/// como String para no romper persistencia ni el tablero (BUG-003).
class EstadoIncidencia {
  static const pendiente = 'Pendiente';
  static const enProceso = 'En proceso';
  static const resuelta = 'Resuelta';

  static const todos = [pendiente, enProceso, resuelta];

  /// Normaliza cualquier variante guardada ('pendiente', 'EN PROCESO', etc.)
  /// a la etiqueta canónica. Si no reconoce, devuelve `pendiente`.
  static String normalizar(String? valor) {
    final v = valor?.trim().toLowerCase() ?? '';
    return switch (v) {
      'en proceso' || 'enproceso' || 'en_proceso' => enProceso,
      'resuelta' || 'resuelto' => resuelta,
      _ => pendiente,
    };
  }
}

class Incidencia {
  String id;
  String titulo;
  String descripcion;
  String cliente;
  String categoria;
  String estado;
  String fecha;
  Prioridad prioridad;

  Incidencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.cliente,
    required this.categoria,
    required this.estado,
    required this.fecha,
    required this.prioridad,
  });

  factory Incidencia.desdeJson(Map<String, dynamic> m) {
    return Incidencia(
      id: m['id']?.toString() ?? '',
      titulo: m['titulo']?.toString() ?? '',
      descripcion: m['descripcion']?.toString() ?? '',
      cliente: m['cliente']?.toString() ?? '',
      categoria: m['categoria']?.toString() ?? 'Software',
      estado: EstadoIncidencia.normalizar(m['estado']?.toString()),
      fecha: m['fecha']?.toString() ?? '',
      prioridad: Prioridad.desdeJson(m['prioridad']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'cliente': cliente,
      'categoria': categoria,
      'estado': estado,
      'fecha': fecha,
      'prioridad': prioridad.etiqueta,
    };
  }
}
