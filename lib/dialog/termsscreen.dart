import 'package:devansh/homecomponents/footer.dart';
import 'package:devansh/homecomponents/header.dart';
import 'package:devansh/homecomponents/topbar.dart';
import 'package:flutter/material.dart';

const _kAmber = Color.fromRGBO(245, 171, 30, 1);

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  // SiteHeader needs to listen to the page's actual scroll position to
  // know when to hide/reveal the TopBar — so the scrollable content and
  // the header share the same controller.
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
                // Reserved space so page content starts below the fixed
                // header instead of underneath it.
                const SizedBox(height: Header.height + TopBar.height),
                _LegalPageBody(
                  title: 'Terms of Service',
                  lastUpdated: 'August 2026',
                  sections: [
                    _LegalSection(
                      heading: '1. Acceptance of Terms',
                      body:
                          'By accessing or using this website, you agree to be '
                          'bound by these Terms of Service. If you do not agree '
                          'to these terms, please do not use the site.',
                    ),
                    _LegalSection(
                      heading: '2. Products and Pricing',
                      body:
                          'We make every effort to display accurate product '
                          'information, pricing, and availability. However, '
                          'errors may occur, and we reserve the right to '
                          'correct any inaccuracies and to update or cancel '
                          'orders affected by such errors.',
                    ),
                    _LegalSection(
                      heading: '3. Orders and Payment',
                      body:
                          'Placing an order constitutes an offer to purchase a '
                          'product. We reserve the right to accept or decline '
                          'any order for any reason, including product '
                          'availability or errors in pricing.',
                    ),
                    _LegalSection(
                      heading: '4. Shipping and Delivery',
                      body:
                          'Delivery timeframes are estimates and may vary '
                          'depending on your location and product availability. '
                          'We are not responsible for delays caused by '
                          'circumstances outside our reasonable control.',
                    ),
                    _LegalSection(
                      heading: '5. Returns and Warranty',
                      body:
                          'Please contact us directly regarding returns, '
                          'exchanges, or warranty claims on any product '
                          'purchased through this site, and we will guide you '
                          'through the applicable process.',
                    ),
                    _LegalSection(
                      heading: '6. Intellectual Property',
                      body:
                          'All content on this site, including text, images, '
                          'and logos, is the property of Devansh Hardware and '
                          'may not be reproduced without permission.',
                    ),
                    _LegalSection(
                      heading: '7. Limitation of Liability',
                      body:
                          'To the fullest extent permitted by law, Devansh '
                          'Hardware is not liable for any indirect, incidental, '
                          'or consequential damages arising from your use of '
                          'this site or its products.',
                    ),
                    _LegalSection(
                      heading: '8. Changes to These Terms',
                      body:
                          'We may update these Terms of Service from time to '
                          'time. Continued use of the site after changes are '
                          'posted constitutes your acceptance of the revised '
                          'terms.',
                    ),
                    _LegalSection(
                      heading: '9. Contact Us',
                      body:
                          'Questions about these Terms can be sent to '
                          'info@devanshhardware.com or by visiting us at '
                          'Sukhanagar (Old Napi Office), Butwal, Nepal.',
                    ),
                  ],
                ),
                const Footer(),
              ],
            ),
          ),
          // Fixed on top of the Stack, tracking _scrollController so it
          // hides/reveals exactly like it does on your other pages.
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
