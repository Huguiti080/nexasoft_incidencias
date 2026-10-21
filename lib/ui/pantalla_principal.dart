import 'package:flutter/material.dart';
import '../model/incidencia.dart';
import '../services/gestor_incidencias.dart';
import 'pantalla_detalle.dart';
import 'pantalla_nueva.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final GestorIncidencias g = GestorIncidencias();
  bool cargando = true;
  String? error;
  String busqueda = '';
  String? estadoSeleccionado;
  Prioridad? prioridadSeleccionada;

  final TextEditingController _busquedaController = TextEditingController();

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      await g.iniciar();
    } catch (e) {
      error = 'No se pudieron cargar las incidencias: $e';
    }
    if (mounted) setState(() => cargando = false);
  }

  List<Incidencia> get itemsFiltrados => g.filtrar(
        texto: busqueda,
        estado: estadoSeleccionado,
        prioridad: prioridadSeleccionada,
      );

  Color colorEstado(String estado) {
    if (estado == EstadoIncidencia.resuelta) return const Color(0xFF147D64);
    if (estado == EstadoIncidencia.enProceso) return const Color(0xFFB56B13);
    return const Color(0xFFAC4052);
  }

  Color colorPrioridad(Prioridad prioridad) {
    return switch (prioridad) {
      Prioridad.baja => const Color(0xFF147D64),
      Prioridad.media => const Color(0xFFB56B13),
      Prioridad.alta => const Color(0xFFAC4052),
    };
  }

  Widget resumen(String etiqueta, String valor, IconData icono) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icono, size: 19, color: const Color(0xFF174C83)),
              const SizedBox(height: 4),
              Text(valor,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text(etiqueta,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> abrirDetalle(Incidencia item) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
          builder: (_) => PantallaDetalle(gestor: g, id: item.id)),
    );
    if (mounted) setState(() {});
  }

  Future<void> abrirFormulario() async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PantallaNueva(gestor: g)),
    );
    if (!mounted) return;
    if (guardado == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incidencia registrada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = itemsFiltrados;
    final hayFiltros = busqueda.isNotEmpty ||
        estadoSeleccionado != null ||
        prioridadSeleccionada != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('NexaSoft | Incidencias'),
        actions: [
          IconButton(
            tooltip: 'Restablecer datos de demostración',
            onPressed: () async {
              final aceptar = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Restablecer demostración'),
                  content: const Text(
                      'Se descartarán los cambios locales y se cargarán las incidencias iniciales.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Restablecer')),
                  ],
                ),
              );
              if (aceptar != true) return;
              try {
                await g.reiniciarDemo();
                if (mounted) setState(() {});
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al reiniciar: $e')));
                }
              }
            },
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      floatingActionButton: cargando || error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: abrirFormulario,
              label: const Text('Nueva incidencia'),
              icon: const Icon(Icons.add),
            ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: cargar, child: const Text('Reintentar')),
                  ]),
                ))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                          child: Row(children: [
                            resumen('Pendientes', '${g.contar(EstadoIncidencia.pendiente)}',
                                Icons.pending_actions),
                            resumen('En proceso', '${g.contar(EstadoIncidencia.enProceso)}',
                                Icons.build_outlined),
                            resumen('Resueltas', '${g.contar(EstadoIncidencia.resuelta)}',
                                Icons.check_circle_outline),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 17, vertical: 5),
                          child: TextField(
                            controller: _busquedaController,
                            decoration: const InputDecoration(
                              labelText: 'Buscar incidencias',
                              hintText: 'Ejemplo: WiFi, correo, pantalla',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (texto) =>
                                setState(() => busqueda = texto),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 17, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  // ignore: deprecated_member_use
                                  value: estadoSeleccionado,
                                  isDense: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Estado',
                                    border: OutlineInputBorder(),
                                  ),
                                  hint: const Text('Todos'),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('Todos'),
                                    ),
                                    ...EstadoIncidencia.todos.map(
                                      (e) => DropdownMenuItem<String?>(
                                          value: e, child: Text(e)),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => estadoSeleccionado = v),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<Prioridad?>(
                                  // ignore: deprecated_member_use
                                  value: prioridadSeleccionada,
                                  isDense: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Prioridad',
                                    border: OutlineInputBorder(),
                                  ),
                                  hint: const Text('Todas'),
                                  items: const [
                                    DropdownMenuItem<Prioridad?>(
                                        value: null, child: Text('Todas')),
                                    DropdownMenuItem<Prioridad?>(
                                      value: Prioridad.baja,
                                      child: Text('Baja'),
                                    ),
                                    DropdownMenuItem<Prioridad?>(
                                      value: Prioridad.media,
                                      child: Text('Media'),
                                    ),
                                    DropdownMenuItem<Prioridad?>(
                                      value: Prioridad.alta,
                                      child: Text('Alta'),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => prioridadSeleccionada = v),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                '${items.length} registros',
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const Spacer(),
                              if (hayFiltros)
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      busqueda = '';
                                      estadoSeleccionado = null;
                                      prioridadSeleccionada = null;
                                    });
                                    _busquedaController.clear();
                                  },
                                  icon: const Icon(Icons.filter_alt_off,
                                      size: 18),
                                  label: const Text('Restablecer'),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: items.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          hayFiltros
                                              ? Icons.filter_alt_off
                                              : Icons.inbox_outlined,
                                          size: 48,
                                          color: Colors.black38,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          hayFiltros
                                              ? 'No hay incidencias que coincidan con los filtros.'
                                              : 'Aún no hay incidencias registradas.',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                        if (hayFiltros) ...[
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                busqueda = '';
                                                estadoSeleccionado = null;
                                                prioridadSeleccionada = null;
                                              });
                                              _busquedaController.clear();
                                            },
                                            child: const Text(
                                                'Restablecer filtros'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12, bottom: 100),
                                  itemCount: items.length,
                                  itemBuilder: (context, i) {
                                    final item = items[i];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                        title: Text(item.titulo,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${item.id}  ·  ${item.cliente}'),
                                              const SizedBox(height: 6),
                                              Text(item.estado,
                                                  style: TextStyle(
                                                    color: colorEstado(
                                                        item.estado),
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              const SizedBox(height: 4),
                                              Text(
                                                  'Prioridad: ${item.prioridad.etiqueta}',
                                                  style: TextStyle(
                                                    color: colorPrioridad(
                                                        item.prioridad),
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        trailing:
                                            const Icon(Icons.chevron_right),
                                        onTap: () => abrirDetalle(item),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
