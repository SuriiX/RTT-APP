import 'package:flutter/material.dart';

import '../../core/api/endpoints.dart';
import 'legal_page.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPage(
      title: 'Términos de Uso',
      remoteUrl: Endpoints.termsOfService(),
      fallbackAsset: 'assets/legal/terms_of_use.html',
      shareSubject: 'Términos de Uso - Radio TeleTaxi',
    );
  }
}
