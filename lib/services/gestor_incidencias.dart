import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];

  Future<void> iniciar() async {
    incidencias = await datos.leer();
  } 

  List<Incidencia> filtrar ({
    String texto = '',
    String? estado,
    Prioridad? prioridad,
  }) {
    final consulta = texto.trim().toLowerCase();
    return incidencias.where((x) {
      final coincideTexto = consulta.isEmpty ||
          x.titulo.toLowerCase().contains(consulta) ||
          x.descripcion.toLowerCase().contains(consulta);
      final coincideEstado = estado == null || x.estado == estado;
      final coincidePrioridad = prioridad == null || x.prioridad == prioridad;
      return coincideTexto && coincideEstado && coincidePrioridad;
    }).toList();
  }

  List<Incidencia> buscar(String texto) => filtrar(texto: texto);

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) =>
      incidencias.where((x) => x.estado == estado).length;

  Future<void> cambiarEstado(String id, String estado) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].estado = estado;
        break;
      }
    }
    await datos.guardar(incidencias);
  }

  Future<void> cambiarPrioridad(String id, Prioridad prioridad) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].prioridad = prioridad;
        break;
      }
    }
    await datos.guardar(incidencias);
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria, Prioridad prioridad) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: EstadoIncidencia.pendiente,
      fecha: DateTime.now().toIso8601String().split('T').first,
      prioridad: prioridad,
    );
    incidencias.insert(0, nuevo);
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
