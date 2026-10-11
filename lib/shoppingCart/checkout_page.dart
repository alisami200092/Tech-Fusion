import 'package:flutter/material.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:provider/provider.dart';
import 'payment.dart'; // Make sure this matches your CreditCardPage file name
import 'order_summary_page.dart';
import 'cart_provider.dart';
import 'cart_item.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0;

  // Shipping Information
  final _shippingFormKey = GlobalKey<FormState>();
  String _name = '';
  String _address = '';
  String _city = '';
  String _state = '';
  String _country = '';
  String _zipCode = '';

  // Payment Information
  String _paymentMethod = 'Card'; // 'Card' or 'COD'
  Map<String, String> _paymentDetails = {};

  void _nextStep() {
    if (_currentStep == 0) {
      if (_shippingFormKey.currentState!.validate()) {
        _shippingFormKey.currentState!.save();
        setState(() => _currentStep += 1);
      }
    } else if (_currentStep == 1) {
      // If COD is selected, bypass the card form and move to summary
      if (_paymentMethod == 'COD') {
        _onPaymentComplete({'method': 'Cash on Delivery'});
      }
      // If Card is selected, the CreditCardPage widget will trigger _onPaymentComplete internally
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _onPaymentComplete(Map<String, String> paymentDetails) {
    // 1. Store the details in the state and move to the Summary Page
    // Note: We DO NOT save to Firebase here. That happens on the OrderSummaryPage!
    setState(() {
      _paymentDetails = paymentDetails;
      _currentStep += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final List<CartItem> cartItems = cartProvider.items.values.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Checkout',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(primary: Color(0xFF000033)),
        ),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepCancel: _prevStep,

          // ===== CUSTOM BUTTON CONTROLS =====
          controlsBuilder: (context, ControlsDetails controls) {
            // LOGIC: Only show the Stepper's "Continue" button on the Shipping Step (0)
            // OR if they select Cash on Delivery on the Payment Step (1).
            bool showContinueButton = _currentStep == 0 ||
                (_currentStep == 1 && _paymentMethod == 'COD');

            return Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: [
                  if (showContinueButton)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF000033),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: controls.onStepContinue,
                        child: Text(
                            _currentStep == 1 && _paymentMethod == 'Card'
                                ? 'CONFIRM CARD'
                                : 'CONTINUE',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (showContinueButton && _currentStep != 0)
                    const SizedBox(width: 12),

                  // The BACK button always stays visible
                  if (_currentStep != 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: controls.onStepCancel,
                        child: const Text('BACK',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            );
          },
          // ==================================

          steps: [
            Step(
              title: const Text('Shipping'),
              content: _buildShippingForm(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.editing,
            ),
            Step(
              title: const Text('Payment'),
              content: _buildPaymentMethodSelector(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.editing,
            ),
            Step(
              title: const Text('Summary'),
              content: OrderSummaryPage(
                cartItems: cartItems,
                paymentDetails: _paymentDetails,
                shippingDetails: {
                  'name': _name,
                  'address': _address,
                  'city': _city,
                  'state': _state,
                  'country': _country,
                  'zipCode': _zipCode,
                },
              ),
              isActive: _currentStep >= 2,
              state: _currentStep == 2 ? StepState.editing : StepState.complete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingForm() {
    return Form(
      key: _shippingFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shipping Details',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000033))),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Full Name',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none)),
            validator: (value) => value!.isEmpty ? 'Required' : null,
            onSaved: (value) => _name = value!,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Address',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none)),
            validator: (value) => value!.isEmpty ? 'Required' : null,
            onSaved: (value) => _address = value!,
          ),
          const SizedBox(height: 12),
          CSCPicker(
            layout: Layout.vertical,
            flagState: CountryFlag.DISABLE,
            dropdownDecoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: Colors.grey.shade50),
            disabledDropdownDecoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: Colors.grey.shade100),
            onCountryChanged: (country) => setState(() => _country = country),
            onStateChanged: (state) => setState(() => _state = state ?? ''),
            onCityChanged: (city) => setState(() => _city = city ?? ''),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Zip Code',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none)),
            validator: (value) => value!.isEmpty ? 'Required' : null,
            onSaved: (value) => _zipCode = value!,
          ),
        ],
      ),
    );
  }

  // The new Payment Method UI
  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Payment Method',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000033))),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12)),

          // ===== THE FIX: NEW FLUTTER RADIOGROUP WIDGET =====
          child: RadioGroup<String>(
            groupValue: _paymentMethod,
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _paymentMethod = value);
              }
            },
            child: Column(
              children: [
                const RadioListTile<String>(
                  title: Text('Credit / Debit Card',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  value: 'Card',
                  // Notice we removed groupValue and onChanged from here!
                  activeColor: Color(0xFF000033),
                ),
                const Divider(height: 1),
                const RadioListTile<String>(
                  title: Text('Cash on Delivery (COD)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  value: 'COD',
                  // Notice we removed groupValue and onChanged from here!
                  activeColor: Color(0xFF000033),
                ),
              ],
            ),
          ),
          // ==================================================
        ),
        const SizedBox(height: 24),
        // If they select Card, show the Credit Card form widget here
        if (_paymentMethod == 'Card')
          CreditCardPage(onPaymentComplete: _onPaymentComplete),

        // If they select COD, show a simple confirmation message
        if (_paymentMethod == 'COD')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.local_shipping, color: Color(0xFF000033)),
                SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'You will pay for your items when they are delivered to your address.',
                        style: TextStyle(color: Color(0xFF000033)))),
              ],
            ),
          ),
      ],
    );
  }
}
