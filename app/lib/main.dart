import 'package:flutter/material.dart';

void main() {
  runApp(const RttApp());
}

class RttApp extends StatelessWidget {
  const RttApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RTT App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        fontFamily: 'SF Pro Display',
      ),
      home: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RttTopBar(title: 'Ajustes'),
      body: Column(
        children: [
          _SettingsTile(
            icon: Icons.notifications_none_outlined,
            label: 'Notificaciones',
            trailing: Switch.adaptive(
              value: notificationsEnabled,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF2D7EFF),
              onChanged: (value) {
                setState(() => notificationsEnabled = value);
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            label: 'Política de privacidad',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RttTopBar(title: 'Politica de Privacidad'),
      body: ListView(
        children: const [
          _PolicyHeading('POLÍTICA DE PRIVACIDAD PARA\nAPLICACIONES MÓVILES'),
          _PolicyParagraph(
            'La información que tienen la obligación de incluir las apps en su política de privacidad debe ser lo más clara y completa posible.',
          ),
          _PolicyParagraph(
            'Un ejemplo de política de privacidad utilizada en aplicaciones debería incluir los siguientes apartados:',
          ),
          _PolicyHeading('Y TRATAMIENTO DE DATOS DE\nCARÁCTER PERSONAL'),
          _PolicyParagraph(
            'Los datos de carácter personal son los que pueden ser utilizados para identificar a una persona o ponerse en contacto con ella.',
          ),
          _PolicyParagraph(
            'Radio Teletaxi (en adelante RTT ) puede solicitar datos personales de usuarios al acceder a aplicaciones de la empresa o de otras empresas afiliadas así como la posibilidad de que entre estas empresas puedan compartir esos datos para mejorar los productos y servicios ofrecidos.',
          ),
          _PolicyParagraph(
            'Si no se facilitan esos datos personales, en muchos casos no podremos ofrecer los productos o servicios solicitados.',
          ),
          _PolicyParagraph(
            'Estos son algunos ejemplos de las categorías de datos de carácter personal que RTT puede recoger y la finalidad para los que puede llevar a cabo el tratamiento de estos datos.',
            hasBottomPadding: true,
          ),
        ],
      ),
    );
  }
}

class RttTopBar extends StatelessWidget implements PreferredSizeWidget {
  const RttTopBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 84,
      backgroundColor: const Color(0xFFFF2339),
      elevation: 0,
      leading: const Icon(Icons.menu, size: 34, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.w300,
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.ios_share_outlined, color: Colors.white, size: 30),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(84);
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFE91E63), size: 34),
              const SizedBox(width: 26),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 26,
                    color: Color(0xFF222222),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyHeading extends StatelessWidget {
  const _PolicyHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFD8D8D8))),
      ),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFFF2339),
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1.15,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _PolicyParagraph extends StatelessWidget {
  const _PolicyParagraph(this.text, {this.hasBottomPadding = false});

  final String text;
  final bool hasBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, hasBottomPadding ? 24 : 0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 22,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
