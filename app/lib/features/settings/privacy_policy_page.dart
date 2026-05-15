import 'package:flutter/material.dart';

import '../../core/api/endpoints.dart';
import 'legal_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPage(
      title: 'Política de Privacidad',
      remoteUrl: Endpoints.privacyPolicy(),
      fallbackAsset: 'assets/legal/privacy_policy_fallback.html',
      shareSubject: 'Política de Privacidad - Radio TeleTaxi',
    );
  }
}
