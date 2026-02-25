import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/rtt_theme.dart';
import '../../widgets/rtt_animated_list_item.dart';
import '../../widgets/rtt_error_widget.dart';
import '../../widgets/rtt_scaffold.dart';
import '../../widgets/rtt_shimmer.dart';
import 'frecuencias_repository.dart';

class FrecuenciasPage extends StatefulWidget {
  const FrecuenciasPage({super.key});

  @override
  State<FrecuenciasPage> createState() => _FrecuenciasPageState();
}

class _FrecuenciasPageState extends State<FrecuenciasPage> {
  final _repo = FrecuenciasRepository();

  bool loading = true;
  String? error;

  // Raw rows from API
  List<Map<String, dynamic>> rows = const [];

  // provincia -> expanded?
  final Map<String, bool> provinceOpen = {};

  // rowKey -> expanded?
  final Map<String, bool> rowOpen = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      if (!mounted) return;
      setState(() {
        loading = true;
        error = null;
      });

      final data = await _repo.fetchFrecuencias();
      final parsed = <Map<String, dynamic>>[];

      for (final it in data) {
        if (it is Map) {
          parsed.add(Map<String, dynamic>.from(it));
        }
      }

      // Orden: provincia fijo como en la app (si existen)
      const provinceOrder = ['Barcelona', 'Girona', 'Ebre', 'Lleida', 'Andorra'];

      parsed.sort((a, b) {
        final pa = (a['provincia'] ?? '').toString();
        final pb = (b['provincia'] ?? '').toString();

        final ia = provinceOrder.indexOf(pa);
        final ib = provinceOrder.indexOf(pb);

        final oa = ia == -1 ? 999 : ia;
        final ob = ib == -1 ? 999 : ib;
        if (oa != ob) return oa.compareTo(ob);

        // Dentro de provincia: ordenar por frecuencia numérica si se puede
        final fa = _freqNumber((a['frecuencia'] ?? '').toString());
        final fb = _freqNumber((b['frecuencia'] ?? '').toString());
        return fa.compareTo(fb);
      });

      // Inicial: abrir Barcelona como en tu captura
      for (final r in parsed) {
        final prov = (r['provincia'] ?? '').toString().trim();
        if (prov.isNotEmpty) {
          provinceOpen.putIfAbsent(prov, () => prov == 'Barcelona');
        }
      }

      if (!mounted) return;
      setState(() {
        rows = parsed;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  static double _freqNumber(String raw) {
    final n = double.tryParse(raw.replaceAll(',', '.').replaceAll(' FM', '').trim());
    return n ?? 9999;
  }

  // Group rows by provincia
  Map<String, List<Map<String, dynamic>>> get grouped {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final r in rows) {
      final prov = (r['provincia'] ?? '').toString().trim();
      map.putIfAbsent(prov.isEmpty ? 'Otros' : prov, () => []);
      map[prov.isEmpty ? 'Otros' : prov]!.add(r);
    }
    return map;
  }

  String _rowKey(String provincia, Map<String, dynamic> r) {
    final f = (r['frecuencia'] ?? '').toString();
    final z = (r['zona'] ?? '').toString();
    return '$provincia|$f|$z';
  }

  @override
  Widget build(BuildContext context) {
    return RttScaffold(
      title: 'Frecuencias',
      actions: [
        IconButton(
          tooltip: 'Compartir',
          icon: const Icon(Icons.ios_share),
          onPressed: () => Share.share(
            'Frecuencias RTT: https://radioteletaxi.com/frecuencias',
          ),
        ),
      ],
      body: loading
          ? const RttShimmerRows()
          : (error != null)
              ? RttErrorWidget(message: error!, onRetry: _load)
              : _body(),
    );
  }

  Widget _body() {
    final g = grouped;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 10),

          // Texto pequeño arriba (la app vieja lo tiene)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'donde nos puedes escuchar.',
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),

          ...g.entries.toList().asMap().entries.map((entry) {
            final idx = entry.key;
            final e = entry.value;
            final prov = e.key;
            final items = e.value;
            final open = provinceOpen[prov] == true;

            return RttAnimatedListItem(
              index: idx,
              child: Column(
              children: [
                _provinceHeader(prov, open),
                if (open) ...items.map((r) => _frequencyRow(prov, r)).toList(),
                const Divider(height: 1),
              ],
            ),
            );
          }),
        ],
      ),
    );
  }

  Widget _provinceHeader(String provincia, bool open) {
    return InkWell(
      onTap: () => setState(() => provinceOpen[provincia] = !open),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icono tipo "mapa" rojo (simple)
            SizedBox(
              width: 34,
              child: Icon(Icons.map_outlined, color: RttColors.red, size: 26),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                provincia,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),

            // Chevron rojo
            Icon(
              open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: RttColors.red,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _frequencyRow(String provincia, Map<String, dynamic> r) {
    final freq = (r['frecuencia'] ?? '').toString().trim();
    final zona = (r['zona'] ?? '').toString().trim();
    final cobertura = (r['cobertura'] ?? '').toString().trim();

    final key = _rowKey(provincia, r);
    final open = rowOpen[key] == true;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => rowOpen[key] = !open),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // frecuencia (roja)
                SizedBox(
                  width: 60,
                  child: Text(
                    freq,
                    style: TextStyle(
                      color: RttColors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // "FM" (gris)
                const SizedBox(
                  width: 34,
                  child: Text(
                    'FM',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ),

                const SizedBox(width: 10),

                // zona
                Expanded(
                  child: Text(
                    zona,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),

                // botón redondo +/-
                _circleToggle(open: open),
              ],
            ),
          ),
        ),

        // Panel gris (cobertura)
        if (open)
          Container(
            width: double.infinity,
            color: const Color(0xFFF0F0F0),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Text(
              cobertura.isNotEmpty ? cobertura : 'Sin información de cobertura.',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }

  Widget _circleToggle({required bool open}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: RttColors.red, width: 2),
      ),
      child: Center(
        child: Icon(
          open ? Icons.remove : Icons.add,
          size: 18,
          color: RttColors.red,
        ),
      ),
    );
  }
}
