import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateProducttPage extends StatefulWidget {
  @override
  _CreateProducttPageState createState() => _CreateProducttPageState();
}

class _CreateProducttPageState extends State<CreateProducttPage> {
  String _productId = '';
  String _priceId = '';
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productAmountController = TextEditingController();

  Future<void> _createProduct() async {
    if (_formKey.currentState!.validate()) {
      final productName = _productNameController.text;
      final productAmount = double.parse(_productAmountController.text);

      final secretKey = 'test_sk_sZRIC6WRbCDtzhyWOuchvM7h71e69pXyBczHk6wn';
      final url = Uri.parse('https://pay.chargily.net/test/api/v2/products');
      final headers = {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/json',
      };
      final body = json.encode({
        'name': productName,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _productId = data['id'];
        });
        await _createPrice(productAmount);
      } else {
        print('Error creating product: ${response.body}');
      }
    }
  }

  Future<void> _createPrice(double productAmount) async {
    final secretKey = 'test_sk_sZRIC6WRbCDtzhyWOuchvM7h71e69pXyBczHk6wn';
    final url = Uri.parse('https://pay.chargily.net/test/api/v2/prices');
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'amount': (productAmount * 100).round(),
      'currency': 'dzd',
      'product_id': _productId,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _priceId = data['id'];
      });
    } else {
      print('Error creating price: ${response.body}');
    }
  }

  Future<void> _createCheckout() async {
    if (_priceId.isNotEmpty) {
      final secretKey = 'test_sk_sZRIC6WRbCDtzhyWOuchvM7h71e69pXyBczHk6wn';
      final url = Uri.parse('https://pay.chargily.net/test/api/v2/checkouts');
      final headers = {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/json',
      };
      final body = json.encode({
        'items': [
          {
            'price': _priceId,
            'quantity': 1,
          }
        ],
        'success_url': 'https://your-cool-website.com/payments/success',
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Handle the checkout session data as needed
        print('Checkout session created: ${data['id']}');
      } else {
        print('Error creating checkout session: ${response.body}');
      }
    } else {
      print(
          'Price ID is not available. Please create a product and price first.');
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productAmountController,
                decoration: InputDecoration(labelText: 'Product Amount'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product amount';
                  }
                  return null;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _createProduct,
                child: Text('Create Product'),
              ),
              if (_productId.isNotEmpty) ...[
                SizedBox(height: 16),
                Text('Product ID: $_productId'),
              ],
              if (_priceId.isNotEmpty) ...[
                SizedBox(height: 16),
                Text('Price ID: $_priceId'),
              ],
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _priceId.isNotEmpty ? _createCheckout : null,
                child: Text('Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
