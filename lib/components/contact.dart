import 'package:flutter/material.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;
  bool _submitted = false;

  static const _accent = Color.fromRGBO(245, 171, 30, 1);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });

    _nameController.clear();
    _emailController.clear();
    _messageController.clear();

    // Resets the success message after a few seconds so the form is
    // ready to use again.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _submitted = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          constraints: const BoxConstraints(maxWidth: 1000),
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
                          Expanded(flex: 4, child: info),
                          const SizedBox(width: 50),
                          Expanded(flex: 6, child: form),
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
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Get In Touch",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_accent.withValues(alpha: 0.5), _accent, _accent.withValues(alpha: 0.5)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Have a question about a product, an order, or just want to "
          "share feedback? Send us a message and our team will get back "
          "to you shortly.",
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 32),
        _contactRow(Icons.email_outlined, "support@devansh.com"),
        const SizedBox(height: 18),
        _contactRow(Icons.phone_outlined, "+91 98765 43210"),
        const SizedBox(height: 18),
        _contactRow(Icons.location_on_outlined, "New Delhi, India"),
      ],
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
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
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
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
          children: [
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