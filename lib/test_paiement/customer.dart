import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateCustomerPage extends StatefulWidget {
  @override
  _CreateCustomerPageState createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends State<CreateCustomerPage> {
  String _customerId = '';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  Future<void> _createCustomer() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final phone = _phoneController.text;
      final address = _addressController.text;

      final secretKey = 'test_sk_sZRIC6WRbCDtzhyWOuchvM7h71e69pXyBczHk6wn';
      final url = Uri.parse('https://pay.chargily.net/test/api/v2/customers');
      final headers = {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/json',
      };
      final body = json.encode({
        'name': name,
        'email': email,
        'phone': phone,
        'address': {
          'country': 'US',
          'state': 'California',
          'address': address,
        },
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _customerId = data['id'];
        });
        print('Customer created: $_customerId');
      } else {
        print('Error creating customer: ${response.body}');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _createCustomer,
                child: Text('Create Customer'),
              ),
              if (_customerId.isNotEmpty) ...[
                SizedBox(height: 16),
                Text('Customer ID: $_customerId'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
