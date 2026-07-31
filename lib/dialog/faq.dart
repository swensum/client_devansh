import 'package:flutter/material.dart';

const Color _kFaqAccent = Color.fromRGBO(245, 171, 30, 1);

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

const List<_FaqItem> _kFaqs = [
  _FaqItem(
    question: "Where is Devansh Suppliers located?",
    answer:
        "We're located in Sukhanagar, Butwal, Nepal. You're welcome to visit "
        "our store to see our full range of cabinet and door hardware in "
        "person.",
  ),
  _FaqItem(
    question: "How can I contact customer support?",
    answer:
        "You can reach us by phone at +977 9857033614 or +977 9857081383, "
        "or by email at info@devanshhardware.com. Our team is available "
        "Sunday to Friday, 10 AM to 6 PM.",
  ),
  _FaqItem(
    question: "Do you provide after-sales support?",
    answer:
        "Yes. If you run into any issue with a product you've purchased "
        "from us — fitting, finish, or a defect — reach out to our support "
        "team and we'll help you sort it out.",
  ),
  _FaqItem(
    question: "How can I place an order?",
    answer:
        "You can place an order through our website or you can send a message"
        " on our WhatsApp numbers: 9857033614, 9857081383\n\n"

"Note: Direct calls and WhatsApp messages are encouraged."
  ),
];

/// Company FAQ section — sits between the Blog section and the Footer on
/// the home page.
class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
         decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.0, 0.65],
              ),
            ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Frequently Asked Questions",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Container(height: 3, width: 60, color: _kFaqAccent),
              const SizedBox(height: 14),
              Text(
                "Answers to what people usually ask us.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 44),
              Column(
                children: [
                  for (int i = 0; i < _kFaqs.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == _kFaqs.length - 1 ? 0 : 12,
                      ),
                      child: _FaqTile(faq: _kFaqs[i]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final _FaqItem faq;
  const _FaqTile({required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isOpen = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isOpen || _isHovered
                ? _kFaqAccent
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _isOpen = !_isOpen),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.faq.question,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: _isOpen ? _kFaqAccent : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _isOpen ? 0.5 : 0.0,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: _isOpen ? _kFaqAccent : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState:
                  _isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Text(
                  widget.faq.answer,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.7,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
              ),
              secondChild: const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}