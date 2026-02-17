import 'package:flutter/material.dart';
import '../../widgets/rtt_appbar.dart';

class ActualidadPage extends StatelessWidget {
  const ActualidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: RttAppBar(phoneNumber: '934661819'),
      body: Center(child: Text('Actualidad (pendiente)')),
    );
  }
}
