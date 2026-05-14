import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/consent/consent_service.dart';
import '../../core/theme/rtt_theme.dart';
import '../settings/privacy_policy_page.dart';
import '../settings/terms_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;

  bool _privacyAccepted = false;
  bool _termsAccepted = false;
  bool _ageConfirmed = false;

  bool get _allAccepted => _privacyAccepted && _termsAccepted && _ageConfirmed;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ConsentService.instance.acceptConsent();
    if (!mounted) return;
    context.go('/');
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // --------------- BUILD ---------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomeSlide(),
                  _buildFeaturesSlide(),
                  _buildConsentSlide(),
                ],
              ),
            ),
            _buildIndicators(),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  // --------------- SLIDE 1: BIENVENIDA ---------------

  Widget _buildWelcomeSlide() {
    return Container(
      color: RttColors.red,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo RTT grande
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'RTT',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 32,
                color: RttColors.red,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'RadioTeleTaxi',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tu radio, en tu bolsillo',
            style: TextStyle(
              fontSize: 17,
              color: Colors.white.withAlpha(200),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // --------------- SLIDE 2: FUNCIONALIDADES ---------------

  Widget _buildFeaturesSlide() {
    return Container(
      color: RttColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Todo lo que necesitas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: RttColors.textPrimary,
            ),
          ),
          const SizedBox(height: 40),
          _featureRow(
            icon: Icons.play_circle_fill,
            title: 'Radio en directo',
            subtitle: 'Escucha tu emisora favorita en cualquier lugar',
          ),
          const SizedBox(height: 28),
          _featureRow(
            icon: Icons.newspaper_outlined,
            title: 'Actualidad y eventos',
            subtitle: 'Mantente al día con las últimas noticias',
          ),
          const SizedBox(height: 28),
          _featureRow(
            icon: Icons.favorite_outline,
            title: 'Tus favoritos',
            subtitle: 'Guarda lo que mas te interese',
          ),
        ],
      ),
    );
  }

  Widget _featureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: RttColors.red.withAlpha(25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: RttColors.red, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: RttColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: RttColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------- SLIDE 3: CONSENTIMIENTO ---------------

  Widget _buildConsentSlide() {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          const SizedBox(height: 20),
          Text(
            'Antes de empezar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: RttColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Para usar la app necesitamos tu consentimiento',
            style: TextStyle(
              fontSize: 15,
              color: RttColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),

          // Checkbox 1: Privacidad
          _consentTile(
            value: _privacyAccepted,
            onChanged: (v) => setState(() => _privacyAccepted = v ?? false),
            label: 'He leído y acepto la ',
            linkText: 'Política de Privacidad',
            onLinkTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            ),
          ),

          const SizedBox(height: 8),

          // Checkbox 2: Términos
          _consentTile(
            value: _termsAccepted,
            onChanged: (v) => setState(() => _termsAccepted = v ?? false),
            label: 'He leído y acepto los ',
            linkText: 'Términos de Servicio',
            onLinkTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TermsPage()),
            ),
          ),

          const SizedBox(height: 8),

          // Checkbox 3: Edad (14+ LOPD-GDD)
          CheckboxListTile(
            value: _ageConfirmed,
            onChanged: (v) => setState(() => _ageConfirmed = v ?? false),
            activeColor: RttColors.red,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Confirmo que tengo 14 años o más',
              style: TextStyle(
                fontSize: 15,
                color: RttColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Requisito legal según la LOPD-GDD',
              style: TextStyle(
                fontSize: 12,
                color: RttColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _consentTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: RttColors.red,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: GestureDetector(
        onTap: () {}, // no toggle — el checkbox lo gestiona
        child: Text.rich(
          TextSpan(
            text: label,
            style: TextStyle(fontSize: 15, color: RttColors.textPrimary),
            children: [
              WidgetSpan(
                child: GestureDetector(
                  onTap: onLinkTap,
                  child: Text(
                    linkText,
                    style: TextStyle(
                      fontSize: 15,
                      color: RttColors.red,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: RttColors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------- INDICADORES ---------------

  Widget _buildIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final active = i == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? RttColors.red : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  // --------------- BOTON INFERIOR ---------------

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: _currentPage < 2
            ? FilledButton(
                onPressed: _nextPage,
                style: FilledButton.styleFrom(
                  backgroundColor: RttColors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Siguiente',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              )
            : FilledButton(
                onPressed: _allAccepted ? _finish : null,
                style: FilledButton.styleFrom(
                  backgroundColor: RttColors.red,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Comenzar',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
      ),
    );
  }
}
