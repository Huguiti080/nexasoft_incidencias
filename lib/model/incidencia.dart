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
      estado: m['estado']?.toString() ?? 'Pendiente',
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
