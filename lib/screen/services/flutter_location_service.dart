import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FlutterLocationService {
  static Future<LocationData?> getLocationData() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData? _locationData;
    // late String? _lat;
    // late String? _long;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    LocationData? locationData = await location.getLocation();

    String latitude = locationData!.latitude.toString();
    String longitude = locationData.longitude.toString();

    // save to preferences
    await _saveLocationData(latitude, longitude);
    return _locationData;
  }

  static Future<void> enableBackgroundMode() async {
    Location location = Location();
    await location.enableBackgroundMode(enable: true);
  }

  static Future<void> _saveLocationData(String lat, String lng) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lat', lat);
    prefs.setString('long', lng);
    print(
        'lat is ${prefs.getString('lat')} and long is ${prefs.getString('long')}');
  }

  Future<void> sendToLian() async {
    final url = Uri.parse(
        'https://s1.lianerp.com/api/public/user/provider-log-location');

    final headers = {
      'TokenPublic': 'bpbm',
      'Content-Type': 'application/json',
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _token = prefs.getString('token');
    final _ip = prefs.getString('ip');
    final _cellNumber = prefs.getString('cellNumber');
    final _lat = prefs.getString('lat');
    final _long = prefs.getString('long');
    final _userAgent = prefs.getString('userAgent');

    final body = jsonEncode({
      'ip': _ip,
      'phone_number': _cellNumber,
      'userAgent': _userAgent,
      'lat': _lat,
      'long': _long,
      'token': _token,
    });

    final response = await http.post(url, headers: headers, body: body);
    print('Your Lian response is ${response.body}');
    print(body);
    print('cellNumber');
    // if (response.statusCode == 200) {
    print('Your response code is ${response.statusCode}');
    // }
  }
}
