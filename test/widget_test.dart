import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';

void main() {
  test('Una incidencia antigua puede convertirse desde JSON', () {
    final registro = Incidencia.desdeJson({
      'id': 'INC-DEMO',
      'titulo': 'Prueba',
      'descripcion': 'Caso de ejemplo',
      'cliente': 'Cliente ficticio',
      'categoria': 'Redes',
      'estado': 'Pendiente',
      'fecha': '2026-10-12',
    });
    expect(registro.id, 'INC-DEMO');
    expect(registro.prioridad, Prioridad.media);
    expect(registro.toJson()['estado'], 'Pendiente');
    expect(registro.toJson()['prioridad'], 'Media');
  });

  test('La prioridad se convierte y persiste desde JSON', () {
    final registro = Incidencia.desdeJson({
      'id': 'INC-ALTA',
      'titulo': 'Prueba',
      'descripcion': 'Caso de ejemplo',
      'cliente': 'Cliente ficticio',
      'categoria': 'Redes',
      'estado': 'Pendiente',
      'fecha': '2026-10-12',
      'prioridad': 'Alta',
    });

    expect(registro.prioridad, Prioridad.alta);
    expect(Incidencia.desdeJson(registro.toJson()).prioridad, Prioridad.alta);
  });

  test('Una prioridad JSON desconocida usa Media sin error', () {
    expect(Prioridad.desdeJson('urgente'), Prioridad.media);
  });
}
