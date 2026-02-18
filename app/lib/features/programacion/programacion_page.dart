import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/audio/audio_controller.dart';
import '../../widgets/rtt_scaffold.dart';

class ProgramacionPage extends StatefulWidget {
  const ProgramacionPage({super.key});

  @override
  State<ProgramacionPage> createState() => _ProgramacionPageState();
}

class _ProgramacionPageState extends State<ProgramacionPage> {
  final api = ApiClient();

  bool loading = true;
  String? error;

  // Tabs: 0=LV, 1=S, 2=D
  int topTab = 0;

  // Subtabs LV: 0=Lunes..4=Viernes
  int lvDayTab = 0;

  List<dynamic> lv = const [];
  List<dynamic> sab = const [];
  List<dynamic> dom = const [];

  // Estado expandido por "key" estable
  final Map<String, bool> expanded = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final data = await api.getList(Endpoints.programacion());
      Map<String, dynamic>? root;
      if (data.isNotEmpty && data.first is Map) {
        root = Map<String, dynamic>.from(data.first as Map);
      }

      setState(() {
        lv = (root?['lv'] is List) ? (root!['lv'] as List) : const [];
        sab = (root?['s'] is List) ? (root!['s'] as List) : const [];
        dom = (root?['d'] is List) ? (root!['d'] as List) : const [];
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  // LV viene con items de diasemana 1..5 (según tu API)
  List<Map<String, dynamic>> _lvForDay(int day1to5) {
    final out = <Map<String, dynamic>>[];
    for (final it in lv) {
      if (it is Map) {
        final m = Map<String, dynamic>.from(it);
        final d = (m['diasemana'] as int?) ?? int.tryParse('${m['diasemana']}') ?? 0;
        if (d == day1to5) out.add(m);
      }
    }
    return out;
  }

  List<Map<String, dynamic>> _sabList() => sab.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  List<Map<String, dynamic>> _domList() => dom.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

  List<Map<String, dynamic>> get _currentItems {
    if (topTab == 0) {
      // LV + subtabs
      final day = 1 + lvDayTab; // 1..5
      return _lvForDay(day);
    }
    if (topTab == 1) return _sabList();
    return _domList();
  }

  String _keyOf(Map<String, dynamic> item) {
    // Clave estable (título + hora + día)
    final t = (item['titulo'] ?? '').toString();
    final hi = (item['horainicio'] ?? item['hora'] ?? '').toString();
    final hf = (item['horafin'] ?? '').toString();
    final d = (item['diasemana'] ?? '').toString();
    return '$d|$hi|$hf|$t';
  }

  bool _isLive(Map<String, dynamic> item) {
    final play = (item['play'] ?? '').toString().trim();
    final fondo = (item['fondo'] ?? '').toString().trim();
    return play.isNotEmpty || fondo.isNotEmpty;
  }

  String _fmtHour(dynamic v) {
    final raw = (v ?? '').toString().trim();
    final n = int.tryParse(raw);
    if (n == null) return raw;
    final hh = (n == 24) ? 0 : n; // por tu normalización
    return hh.toString().padLeft(2, '0') + ':00';
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Programación',
      actions: [
        IconButton(
          tooltip: 'Compartir',
          icon: const Icon(Icons.ios_share),
          onPressed: () {},
        ),
      ],
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (error != null)
              ? Center(child: Text('Error: $error'))
              : Column(
                  children: [
                    // ✅ TOP TABS (Lunes–Viernes / Sábado / Domingo)
                    _topTabs(),

                    // ✅ SUB TABS (solo L-V)
                    if (topTab == 0) _lvDayTabs(),

                    const Divider(height: 1),

                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _currentItems.length,
                        itemBuilder: (context, i) {
                          final item = _currentItems[i];
                          return _rowItem(context, item);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _topTabs() {
    return Container(
      color: const Color(0xFFE53935),
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          _topTabBtn('Lunes-Viernes', 0),
          _topTabBtn('Sábado', 1),
          _topTabBtn('Domingo', 2),
        ],
      ),
    );
  }

  Widget _topTabBtn(String label, int idx) {
    final active = topTab == idx;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            topTab = idx;
            // reset subtabs al cambiar sección
            if (topTab != 0) lvDayTab = 0;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFD81B60) : Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _lvDayTabs() {
    // Estilo similar (fondo rojo, pestaña activa más fuerte)
    final labels = const ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

    return Container(
      color: const Color(0xFFE53935),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = lvDayTab == i;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => lvDayTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFD81B60) : const Color(0xFFE53935),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _rowItem(BuildContext context, Map<String, dynamic> item) {
    final hi = _fmtHour(item['horainicio'] ?? item['hora']);
    final hf = _fmtHour(item['horafin']);
    final titulo = (item['titulo'] ?? '').toString();
    final presentador = (item['presentador'] ?? '').toString();
    final contenido = (item['contenido'] ?? '').toString();
    final live = _isLive(item);

    final key = _keyOf(item);
    final isOpen = expanded[key] == true;

    return Column(
      children: [
        InkWell(
          onTap: () {
            // En la app vieja abre/cierra con el botón, pero aquí también permitimos tap
            setState(() => expanded[key] = !isOpen);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ HORAS (columna izq con línea tenue)
                SizedBox(
                  width: 62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hi.replaceAll(':00', ':00'),
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        hf.replaceAll(':00', ':00'),
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),

                // Línea vertical como en la referencia
                Container(
                  width: 1,
                  height: 54,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.only(right: 16),
                ),

                // ✅ TEXTO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (presentador.trim().isNotEmpty)
                        Text(
                          'Con $presentador',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (live) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'EN DIRECTO',
                          style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ],
                  ),
                ),

                // ✅ CHEVRON (botón redondo como el de la app)
                InkWell(
                  onTap: () => setState(() => expanded[key] = !isOpen),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE53935), width: 2),
                    ),
                    child: Icon(
                      isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFFE53935),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ✅ PANEL EXPANDIDO
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            color: const Color(0xFFF7F7F7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contenido.trim().isNotEmpty)
                  Text(
                    contenido,
                    style: const TextStyle(color: Colors.black87),
                  )
                else
                  const Text(
                    'Sin descripción.',
                    style: TextStyle(color: Colors.black54),
                  ),
                const SizedBox(height: 12),

                // Botón "Escuchar" / abrir player
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      AudioController.instance.setProgramTitle(
                        titulo.isNotEmpty ? titulo : 'Radio TeleTaxi',
                      );
                      context.go('/player');
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Escuchar',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
          crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    );
  }
}
