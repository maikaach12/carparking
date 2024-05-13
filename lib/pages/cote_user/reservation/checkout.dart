import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateProductPage extends StatefulWidget {
  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  String _productId = '';
  String _priceId = '';

  Future<void> _createProduct() async {
    final secretKey = 'test_sk_sZRIC6WRbCDtzhyWOuchvM7h71e69pXyBczHk6wn';
    final url = Uri.parse('https://pay.chargily.net/test/api/v2/products');
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'name': 'Super Product',
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _productId = data['id'];
      });
    } else {
      // Handle error
      print('Error creating product: ${response.body}');
    }
  }

  Future<void> _createPrice() async {
    final secretKey = 'test_sk_sZRIC6WRbCDtzhyWOuchvM7h71e69pXyBczHk6wn';
    final url = Uri.parse('https://pay.chargily.net/test/api/v2/prices');
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'amount': 5000,
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
      // Handle error
      print('Error creating price: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Product'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _createProduct,
              child: Text('Create Product'),
            ),
            if (_productId.isNotEmpty) ...[
              SizedBox(height: 16),
              Text('Product ID: $_productId'),
              ElevatedButton(
                onPressed: _createPrice,
                child: Text('Create Price'),
              ),
            ],
            if (_priceId.isNotEmpty) ...[
              SizedBox(height: 16),
              Text('Price ID: $_priceId'),
            ],
          ],
        ),
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _checkoutUrl = '';

  Future<void> _createCheckout() async {
    final secretKey = 'test_sk_sZRIC6WRbCDtzhyWOuchvM7h71e69pXyBczHk6wn';
    final url = Uri.parse('https://pay.chargily.net/test/api/v2/checkouts');
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'items': [
        {
          'price': '01hhy57e5j3xzce7ama8gtk7m0',
          'quantity': 1,
        },
      ],
      'success_url': 'https://your-cool-website.com/payments/success',
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _checkoutUrl = data['url'];
      });
    } else {
      // Handle error
      print('Error creating checkout: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _createCheckout,
              child: Text('Create Checkout'),
            ),
            if (_checkoutUrl.isNotEmpty) ...[
              SizedBox(height: 16),
              Text('Checkout URL: $_checkoutUrl'),
            ],
          ],
        ),
      ),
    );
  }
}
