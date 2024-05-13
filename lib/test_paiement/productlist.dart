import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerListPage extends StatefulWidget {
  @override
  _CustomerListPageState createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  List<Map<String, dynamic>> _customers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final secretKey = 'test_pk_QDalrOh9PiXCq2I9q8z9vHTEaCmBJATQjr6qQbTt';
    final url = Uri.parse('https://pay.chargily.net/test/api/v2/customers');
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final customers = data['data'].map((customer) {
        return {
          'id': customer['id'],
          'name': customer['name'],
          // Add other customer properties as needed
        };
      }).toList();

      setState(() {
        _customers = customers;
      });
    } else {
      print('Error fetching customers: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer List'),
      ),
      body: ListView.builder(
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return ListTile(
            title: Text(customer['name']),
            // subtitle: Text('ID: ${customer['id']}'),
          );
        },
      ),
    );
  }
}
