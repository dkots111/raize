import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:raize/QRScanAPI.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:barcode_scan/barcode_scan.dart';

import 'models/EventModel.dart';

class DetailWidget extends StatefulWidget {
  final EventModel eventModel;

  DetailWidget({@required  this.eventModel});
  @override
  _MyAppState createState() => new _MyAppState(eventModel);
}

class _MyAppState extends State<DetailWidget> {

  EventModel eventModel;
  _MyAppState(EventModel eventModel){
    this.eventModel = eventModel;
  }

  String _reader = '';
  Color _resultColor;
  Permission permission = Permission.Camera;
  AssetImage _statusImg = new AssetImage('');

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Image.network(eventModel.banner,
          height: 150,
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Text(
            eventModel.description,
            style: TextStyle(fontSize: 20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Text(
            eventModel.duration.start.date,
            style: TextStyle(fontSize: 20),
          ),
        ),
        RaisedButton(
          textColor: Colors.blue,
          child: new Text(
            "Navigation",
            textAlign: TextAlign.center,
          ),
          onPressed: () {},
        ),
        RaisedButton(
            textColor: Colors.blue,
            child: new Text("Check In"),
            onPressed: scan //scanOrDisable(true),
        ),
        new Row(
          children: <Widget>[
            new Text(
              '$_reader',
              softWrap: true,
              style: new TextStyle(fontSize: 20.0, color: _resultColor),
            ),
            new Image(
              image: _statusImg,
              height: 50,
              width: 50,
              fit: BoxFit.fill,
            ),
          ],
        ),
      ],
    );
  }

  requestPermission() async {
    PermissionStatus result =
    await SimplePermissions.requestPermission(permission);
    setState(
          () => new SnackBar(
        backgroundColor: Colors.red,
        content: new Text(" $result"),
      ),
    );
  }

  scan() async {
    try {
      String reader = await BarcodeScanner.scan();

      if (!mounted) {
        return;
      }
      bool userAuthenticated = await QRScanAPI.checkIn(reader);
      setState(() => showScanResults(userAuthenticated));
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        requestPermission();
      } else {
        setState(() => _reader = "unknown exception $e");
      }
    } on FormatException {
      setState(() => () => new SnackBar(
        backgroundColor: Colors.red,
        content: new Text("Scan Cancelled!"),
      ));
    } catch (e) {
      setState(() => _reader = 'Unknown error: $e');
    }
  }

  showScanResults(bool userAuthenticated) {
    if (userAuthenticated) {
      this._reader = "Approved..";
      this._resultColor = Colors.green;
      _statusImg = new AssetImage('assets/img_approved_candidate.jpeg');
    } else {
      this._reader = "Please contact Orgnaizer!";
      this._resultColor = Colors.red;
      _statusImg = new AssetImage('assets/img_rejected_candidate.jpeg');
    }
  }
}