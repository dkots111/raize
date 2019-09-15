import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raize/qr_scan_state.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/event_model.dart';

class DetailWidget extends StatefulWidget {
  final EventModel eventModel;


  DetailWidget({@required this.eventModel});
  @override
  _MyAppState createState() => _MyAppState(eventModel);
}

class _MyAppState extends State<DetailWidget> {
  EventModel eventModel;
  _MyAppState(EventModel eventModel) {
    this.eventModel = eventModel;
  }

  String _reader = '';
  Color _resultColor;
  Permission permission = Permission.Camera;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            eventModel.title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            eventModel.description,
            style: TextStyle(
                fontSize: 20
            ),
          ),
        ),
        SizedBox(height: 90.0),
        Container(
          alignment: Alignment.bottomCenter,
          child: (eventModel.host)? SizedBox(
            width: 350.0,
            height: 50.0,
            child: RaisedButton(
              child:
               Text('Scan',
                 style: TextStyle(
                     color: Colors.white
                 ),
               ) ,
              color: Colors.blue,
              onPressed: scan(true),
            ),
          ):SizedBox(height: 0.0),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.bottomCenter,
          child: (eventModel.host)? SizedBox(
            width: 350.0,
            height: 50.0,
            child: RaisedButton(
              color: Colors.blue,
              child: Text('Swag',
              style: TextStyle(
                color: Colors.white
              ),
              ),
              onPressed: scan(false),
            ),
          ):SizedBox(height:0.0),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 350.0,
            height: 50.0,
            child: OutlineButton(
              color: Colors.white,
              borderSide: BorderSide(color: Colors.blue),
              child: Text('Navigation',
                style: TextStyle(
                    color: Colors.blue
                ),),
              onPressed: _launchMapsUrl,
            ),
          ),
        ),
        SizedBox(height: 30.0),
        Container(
        child : Row(
          children: <Widget>[
            Text(
              '$_reader',
              softWrap: true,
              style: TextStyle(fontSize: 20.0, color: _resultColor),
            ),

          ],
        ),
        )
      ],
    );
  }

  requestPermission() async {
    PermissionStatus result =
        await SimplePermissions.requestPermission(permission);
    setState(
      () => SnackBar(
        backgroundColor: Colors.red,
        content: Text(" $result"),
      ),
    );
  }

  scan(bool) async {
    try {
      String qrData = await BarcodeScanner.scan();

      if (!mounted) {
        return;
      }
      print("scan result: $qrData");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScanState(qrData: qrData,isRegistration: bool),
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        requestPermission();
      } else {
        setState(() => _reader = "unknown exception $e");
      }
    } on FormatException {
      setState(() => () => SnackBar(
            backgroundColor: Colors.red,
            content: Text("Scan Cancelled!"),
          ));
    } catch (e) {
      setState(() => _reader = 'Unknown error: $e');
    }
  }


  _launchMapsUrl() async {
    final url = 'https://goo.gl/maps/3D42ABqcuTG6t9kLA';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
