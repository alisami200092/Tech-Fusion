import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:logging/logging.dart';

class CreditCardPage extends StatefulWidget {
  final Function(Map<String, String>) onPaymentComplete;

  const CreditCardPage({
    super.key,
    required this.onPaymentComplete,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CreditCardPageState createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  final Logger _logger = Logger('CreditCardPageLogger');

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void _configureLogger() {
    Logger.root.level = Level.ALL;
  }

  @override
  void initState() {
    super.initState();
    _configureLogger();
  }

  void _onPaymentComplete() {
    // 1. Validate the form
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // 2. Package the details to send to the Summary Page
      final paymentDetails = {
        'method': 'Card',
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cardHolderName': cardHolderName,
      };

      _logger.info('Card Details Successfully Captured');

      // 3. Pass it to the next step
      widget.onPaymentComplete(paymentDetails);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form properly')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Themed the physical card dark navy
        CreditCardWidget(
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          showBackView: isCvvFocused,
          onCreditCardWidgetChange: (CreditCardBrand brand) {},
          isHolderNameVisible: true,
          cardBgColor: const Color(0xFF000033),
          isSwipeGestureEnabled: true,
        ),
        const SizedBox(height: 16),
        CreditCardForm(
          formKey: formKey,
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          onCreditCardModelChange: (CreditCardModel data) {
            if (!mounted) return;
            setState(() {
              cardNumber = data.cardNumber;
              expiryDate = data.expiryDate;
              cardHolderName = data.cardHolderName;
              cvvCode = data.cvvCode;
              isCvvFocused = data.isCvvFocused;
            });
          },
        ),
        const SizedBox(height: 24),

        // ===== THE NEW PREMIUM BUTTON =====
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000033),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _onPaymentComplete,
            child: const Text('CONFIRM CARD & CONTINUE',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
