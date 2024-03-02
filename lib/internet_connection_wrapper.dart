import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetConnectionWrapper extends StatefulWidget {
  final Widget child;

  const InternetConnectionWrapper({Key? key, required this.child})
      : super(key: key);

  @override
  _InternetConnectionWrapperState createState() =>
      _InternetConnectionWrapperState();
}

class _InternetConnectionWrapperState extends State<InternetConnectionWrapper> {
  late bool _isConnected;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isConnected ? widget.child : _buildNoInternetWidget();
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'No Internet Connection',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
