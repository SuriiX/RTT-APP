import 'package:flutter/material.dart';

import 'legal_page.dart';

/// Política de Privacidad — versión 100 % estática.
///
/// La app empaqueta su propia política firmada por el equipo legal en
/// `assets/legal/privacy_policy_fallback.html` y la muestra siempre desde
/// el bundle. No se hace ninguna petición de red, ni hay fallback remoto:
/// las stores (Play / App Store) exigen que la política esté disponible
/// aunque no haya conexión, y el WordPress puede caerse.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Política de Privacidad',
      fallbackAsset: 'assets/legal/privacy_policy_fallback.html',
    );
  }
}
