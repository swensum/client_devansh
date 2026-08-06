import 'package:devansh/homecomponents/footer.dart';
import 'package:devansh/homecomponents/header.dart';
import 'package:devansh/homecomponents/topbar.dart';
import 'package:flutter/material.dart';

const _kAmber = Color.fromRGBO(245, 171, 30, 1);

/// Standard privacy-policy boilerplate. Treat this as a first draft:
/// review and adapt the specifics (what you actually collect, which
/// third-party services you use — Firebase Analytics, payment
/// processors, etc.) before relying on it, ideally with a quick pass
/// from a lawyer or a reputable policy generator tied to your business.
class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Header.height + TopBar.height),
                _LegalPageBody(
                  title: 'Privacy Policy',
                  lastUpdated: 'August 2026',
                  sections: [
                    _LegalSection(
                      heading: '1. Information We Collect',
                      body:
                          'When you use this website, we may collect information '
                          'you provide directly — such as your name, email '
                          'address, phone number, and shipping details when you '
                          'place an order or contact us. We also automatically '
                          'collect certain technical information, such as your '
                          'IP address, browser type, and pages visited, to help '
                          'us understand how the site is used and to keep it '
                          'secure.',
                    ),
                    _LegalSection(
                      heading: '2. How We Use Your Information',
                      body:
                          'We use the information we collect to process and '
                          'fulfil orders, respond to enquiries, provide customer '
                          'support, and improve our products and services. We '
                          'do not sell your personal information to third '
                          'parties.',
                    ),
                    _LegalSection(
                      heading: '3. Cookies and Similar Technologies',
                      body:
                          'This site may use cookies or similar local storage '
                          'technologies to keep you signed in, remember your '
                          'preferences, and understand site usage. You can '
                          'control cookies through your browser settings.',
                    ),
                    _LegalSection(
                      heading: '4. Data Sharing',
                      body:
                          'We may share information with trusted service '
                          'providers who help us operate the site (for example, '
                          'hosting or authentication providers), and only to '
                          'the extent necessary for them to perform those '
                          'services. We may also disclose information if '
                          'required by law.',
                    ),
                    _LegalSection(
                      heading: '5. Data Security',
                      body:
                          'We take reasonable technical and organisational '
                          'measures to protect your information. However, no '
                          'method of transmission or storage over the internet '
                          'is completely secure, and we cannot guarantee '
                          'absolute security.',
                    ),
                    _LegalSection(
                      heading: '6. Your Rights',
                      body:
                          'You may request access to, correction of, or '
                          'deletion of your personal information by contacting '
                          'us using the details below.',
                    ),
                    _LegalSection(
                      heading: '7. Contact Us',
                      body:
                          'If you have any questions about this Privacy '
                          'Policy, please contact us at info@devanshhardware.com '
                          'or visit us at Sukhanagar (Old Napi Office), Butwal, '
                          'Nepal.',
                    ),
                  ],
                ),
                const Footer(),
              ],
            ),
          ),
          SiteHeader(scrollController: _scrollController),
        ],
      ),
    );
  }
}

class _LegalPageBody extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<_LegalSection> sections;

  const _LegalPageBody({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(height: 3, width: 48, color: _kAmber),
              const SizedBox(height: 12),
              Text(
                'Last updated: $lastUpdated',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 40),
              for (final section in sections) ...[
                Text(
                  section.heading,
                  style: const TextStyle(
                    color: _kAmber,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  section.body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 14.5,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalSection {
  final String heading;
  final String body;
  const _LegalSection({required this.heading, required this.body});
}
