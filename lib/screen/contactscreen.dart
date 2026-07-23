
import 'dart:ui_web' as ui_web;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devansh/components/footer.dart';
import 'package:devansh/components/header.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:web/web.dart' as web;

const double _kHeaderHeight = 100;

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;
  bool _submitted = false;

  // Once true, stays true — one-shot reveal, doesn't replay on re-scroll.
  bool _visible = false;

  static const _accent = Color.fromRGBO(245, 171, 30, 1);

  void _handleVisibility(VisibilityInfo info) {
    if (!_visible && info.visibleFraction > 0.2) {
      setState(() => _visible = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSubmitting = true);

  try {
    await FirebaseFirestore.instance.collection('contact_messages').add({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'message': _messageController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'read': false, // admin panel can use this to flag unread messages
    });

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });

    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _messageController.clear();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _submitted = false);
    });
  } catch (e) {
  debugPrint('Contact submit error: $e');   // add this line
  if (!mounted) return;
  setState(() => _isSubmitting = false);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Failed to send message. Please try again.")),
  );
}
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: _kHeaderHeight), // reserve space
                _buildContactBody(),
                const _MapSection(),
                const _Divider(),
                const Footer(),
              ],
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Header(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBody() {
    return VisibilityDetector(
      key: const Key('contact-section-visibility'),
      onVisibilityChanged: _handleVisibility,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 700),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black.withValues(alpha: 0.95), Colors.black.withValues(alpha: 0.85)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                final info = _buildContactInfo();
                final form = _buildForm();

                return isWide
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 5, child: info),
                            const SizedBox(width: 40),
                            Expanded(flex: 5, child: form),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          info,
                          const SizedBox(height: 40),
                          form,
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return _RevealOnVisible(
      visible: _visible,
      delay: const Duration(milliseconds: 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How can we help you?",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accent.withValues(alpha: 0.5),
                    _accent,
                    _accent.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 36),

            _infoBlock(
              icon: Icons.phone_outlined,
              lead: "Have any questions? Reach us by phone",
              lines: const ["9857033614", "9857081383"],
            ),
            const SizedBox(height: 40),

            _infoBlock(
              icon: Icons.email_outlined,
              lead: "We're here for you !! Just get answers",
              lines: const ["tradersnebha@gmail.com"],
            ),
            const SizedBox(height: 40),

            _infoBlock(
              icon: Icons.location_on_outlined,
              lead: "Explore us by visiting our stores",
              lines: const ["sukhanagar, butwal, Nepal"],
            ),
            const SizedBox(height: 40),

            _infoBlock(
              icon: Icons.access_time_outlined,
              lead: "We are open 6 days a week",
              lines: const ["Sun-Fri (10:00 AM – 6:00 PM)"],
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _infoBlock({
    required IconData icon,
    required String lead,
    required List<String> lines,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _accent.withValues(alpha: 0.4), width: 1),
          ),
          child: Icon(icon, color: _accent, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lead,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (int i = 0; i < lines.length; i++)
                    Text(
                      i == lines.length - 1 ? lines[i] : "${lines[i]},",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return _RevealOnVisible(
      visible: _visible,
      delay: const Duration(milliseconds: 150),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Contact us to find out more",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildField(
                controller: _nameController,
                label: "Your Name",
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? "Please enter your name" : null,
              ),
              const SizedBox(height: 18),
              _buildField(
                controller: _emailController,
                label: "Email Address",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Please enter your email";
                  final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
                  if (!emailRegex.hasMatch(value.trim())) return "Enter a valid email";
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _buildField(
                controller: _phoneController,
                label: "Phone Number",
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? "Please enter your phone number"
                    : null,
              ),
              const SizedBox(height: 18),
              _buildField(
                controller: _addressController,
                label: "Address",
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? "Please enter your address" : null,
              ),
              const SizedBox(height: 18),
              _buildField(
                controller: _messageController,
                label: "Your Message",
                maxLines: 5,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? "Please enter a message" : null,
              ),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              if (_submitted) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: _accent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Thanks! Your message has been sent.",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: _accent,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child: _isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
            )
          : const Text(
              "Send Message",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 2,
      color: const Color.fromRGBO(245, 171, 30, 1),
    );
  }
}
class _MapSection extends StatefulWidget {
  const _MapSection();

  @override
  State<_MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<_MapSection> {
  static const _viewType = 'company-location-map';
  static bool _factoryRegistered = false;
static const _mapEmbedSrc =
    'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d940.724856269087!2d83.47113613039252!3d27.689691028367275!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3996877946082bab%3A0x78a9b9e3b3448eb6!2sDevansh%20Suppliers!5e1!3m2!1sen!2snp!4v1784795275180!5m2!1sen!2snp';
  static const _accent = Color.fromRGBO(245, 171, 30, 1);

  @override
  void initState() {
    super.initState();
    if (!_factoryRegistered) {
      _factoryRegistered = true;
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src = _mapEmbedSrc
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 70),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Find Our Store",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _accent.withValues(alpha: 0.5),
                      _accent,
                      _accent.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const HtmlElementView(viewType: _viewType),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevealOnVisible extends StatefulWidget {
  final bool visible;
  final Duration delay;
  final Widget child;

  const _RevealOnVisible({
    required this.visible,
    required this.delay,
    required this.child,
  });

  @override
  State<_RevealOnVisible> createState() => _RevealOnVisibleState();
}

class _RevealOnVisibleState extends State<_RevealOnVisible> {
  bool _scheduled = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _maybeSchedule();
  }

  @override
  void didUpdateWidget(covariant _RevealOnVisible oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeSchedule();
  }

  void _maybeSchedule() {
    if (widget.visible && !_scheduled) {
      _scheduled = true;
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _started = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      opacity: _started ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        offset: _started ? Offset.zero : const Offset(0, 0.15),
        child: widget.child,
      ),
    );
  }
}