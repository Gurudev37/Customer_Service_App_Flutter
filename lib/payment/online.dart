import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_service_app_flutter/payment/payment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class OnlinePaymentScreen extends StatefulWidget {
  static const String id = "online_payment";
  final String username;
  final String mobileNumber;
  final String serviceName;
  final String email;
  OnlinePaymentScreen({
    required this.username,
    required this.mobileNumber,
    required this.serviceName,
    required this.email,
  });

  @override
  State<OnlinePaymentScreen> createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnlinePaymentScreen> {
  final ordersCollection = FirebaseFirestore.instance.collection('orders');

  void _placeOrder(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ordersCollection = FirebaseFirestore.instance.collection('orders');
      final documentName = user.email;
      final locationData = await _getLocationData(); // Get user location

      Map<String, dynamic> orderData = {
        'username': widget.username,
        'mobileNumber': widget.mobileNumber,
        'serviceName': widget.serviceName,
        'email': widget.email,
        'paymentMethod': 'Cash on Delivery',
        'timestamp': FieldValue.serverTimestamp(),
        'userLocation': locationData, // Include location data in the order
      };

      await ordersCollection.doc(documentName).set(orderData);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentOnlineScreen(
                  username: widget.username,
                )),
      );
    }
  }

  Future<Map<String, double>> _getLocationData() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }

    _locationData = await location.getLocation();
    return {
      'latitude': _locationData.latitude!,
      'longitude': _locationData.longitude!,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF090B1C),
        leading: Icon(
          Icons.miscellaneous_services,
          size: 35.0,
          color: Colors.white,
        ),
        title: Text(
          'Payment',
          style: TextStyle(fontSize: 25.0),
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 240,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                shadowColor: Colors.pink,
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Color(0xFF0F112A),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Username: ${widget.username}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Mobile Number: ${widget.mobileNumber}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Service Name: ${widget.serviceName}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _placeOrder(context);
                            },
                            child: Text('Place Order'),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xFF1C1E42)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150.0),
            child: Icon(
              Icons.miscellaneous_services,
              size: 160,
            ),
          ),
        ],
      ),
    );
  }
}
