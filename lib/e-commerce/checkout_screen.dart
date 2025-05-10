import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class CheckoutScreen extends StatefulWidget {
  final List cartItems;
  final double total;

  const CheckoutScreen({
    Key? key,
    required this.cartItems,
    required this.total,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = 'pk_test_51RMvGX2X6RxEBjjs9omLjRSyOgx8vhna2A7JgX2FaBhoRJSbZ3iSrHK3JQIqZaI1dyHO9m9LOR3YhB32K38pmKSc007JOBx2am'; // Replace with your actual key
    Stripe.merchantIdentifier = 'merchant.com.example';
    Stripe.urlScheme = 'flutterstripe';
    Stripe.instance.applySettings();
  }

  Future<void> _payWithStripe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      // 1. Create payment intent on your backend
      final response = await http.post(
        Uri.parse('https://your-backend.com/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (widget.total * 100).toInt(),
          'currency': 'pkr',
          'email': _emailController.text.trim(),
          'metadata': {
            'customer_name': _nameController.text.trim(),
            'customer_phone': _phoneController.text.trim(),
            'delivery_address': _addressController.text.trim(),
          }
        }),
      );

      // Validate response
      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent: ${response.body}');
      }

      final responseData = json.decode(response.body);
      if (responseData['clientSecret'] == null) {
        throw Exception('Invalid server response');
      }

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: responseData['clientSecret'],
          merchantDisplayName: 'My Furry Friend',
          customerId: responseData['customerId'],
          customerEphemeralKeySecret: responseData['ephemeralKey'],
          style: ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );

      // 3. Display payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Handle successful payment
      await _placeOrder(
        paymentMethod: 'Stripe',
        paymentId: responseData['paymentIntentId'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
    } on StripeException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Error: ${e.error.localizedMessage}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _placeOrder({
    required String paymentMethod,
    String? paymentId,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      // Convert cart items safely
      final orderItems = widget.cartItems.map((item) {
        final data = item is DocumentSnapshot
            ? item.data() as Map<String, dynamic>?
            : item as Map<String, dynamic>?;

        return {
          'id': data?['id']?.toString() ?? '',
          'name': data?['name']?.toString() ?? 'Unknown Product',
          'price': (data?['price'] as num?)?.toDouble() ?? 0.0,
          'quantity': (data?['quantity'] as int?) ?? 1,
          'image': data?['image']?.toString() ?? '',
        };
      }).toList();

      // Save order to Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        'customerName': _nameController.text.trim(),
        'customerEmail': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'total': widget.total,
        'timestamp': Timestamp.now(),
        'status': paymentMethod == 'COD' ? 'pending' : 'paid',
        'paymentMethod': paymentMethod,
        'paymentId': paymentId,
        'items': orderItems,
      });

      // Clear cart after successful order (implement according to your app structure)
      // Navigator.popUntil(context, (route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Billing Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixText: '+92 ',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (!RegExp(r'^03\d{9}$').hasMatch(value)) {
                    return 'Enter a valid 11-digit Pakistani phone number starting with 03';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.cartItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item['name']} (x${item['quantity']})'),
                    Text('₹${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${widget.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else ...[
                ElevatedButton.icon(
                  onPressed: () => _placeOrder(paymentMethod: 'COD'),
                  icon: const Icon(Icons.payment),
                  label: const Text('Place Order (COD)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _payWithStripe,
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Pay Online with Stripe'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}