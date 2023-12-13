import 'package:flutter/material.dart';
import './enter_cellphone.dart';
import './homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import './location_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'location_service.dart';
// import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './logout_page.dart';
import 'package:persian/persian.dart';
import './header.dart';
import '../constans.dart';
import './services/order_service.dart';
import './services/flutter_location_service.dart';
import 'package:location/location.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class AdminPage extends StatefulWidget {
  // const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  String text = "Stop Service";
  late String _cellNumber = '';
  late String _userAgent;
  late String _ip;
  // late bool _checkVpn;
  late Timer _timer;
  late String? _lat;
  late String? _long;
  List<Order> orders = [
    Order(
      id: 1011,
      name: 'Order 1',
      details: 'سرویسکار: مهدی فولادی\n'
          'تاریخ درخواست سرویس: 22 مهرماه 1402\n'
          'نحوه آشنایی: گوگل\n'
          'آدرس: علامه طباطبایی، خیابان آستانه، کوچه پنجم شرقی، پلاک 7، واحد 3',
    ),
    Order(
      id: 1012,
      name: 'Order 2',
      details: 'سرویسکار: مهدی فولادی\n'
          'تاریخ درخواست سرویس: 22 مهرماه 1402\n'
          'نحوه آشنایی: گوگل\n'
          'آدرس: علامه طباطبایی، خیابان آستانه، کوچه پنجم شرقی، پلاک 7، واحد 3',
    ),
    Order(
      id: 1013,
      name: 'Order 3',
      details: 'سرویسکار: مهدی فولادی\n'
          'تاریخ درخواست سرویس: 22 مهرماه 1402\n'
          'نحوه آشنایی: گوگل\n'
          'آدرس: علامه طباطبایی، خیابان آستانه، کوچه پنجم شرقی، پلاک 7، واحد 3',
    ),
    Order(
      id: 1014,
      name: 'Order 4',
      details: 'سرویسکار: مهدی فولادی\n'
          'تاریخ درخواست سرویس: 22 مهرماه 1402\n'
          'نحوه آشنایی: گوگل\n'
          'آدرس: علامه طباطبایی، خیابان آستانه، کوچه پنجم شرقی، پلاک 7، واحد 3',
    ),
    Order(
      id: 1015,
      name: 'Order 5',
      details: 'سرویسکار: مهدی فولادی\n'
          'تاریخ درخواست سرویس: 22 مهرماه 1402\n'
          'نحوه آشنایی: گوگل\n'
          'آدرس: علامه طباطبایی، خیابان آستانه، کوچه پنجم شرقی، پلاک 7، واحد 3',
    ),
    Order(
      id: 1016,
      name: 'Order 6',
      details: 'سرویسکار: مهدی فولادی\n'
          'تاریخ درخواست سرویس: 22 مهرماه 1402\n'
          'نحوه آشنایی: گوگل\n'
          'آدرس: علامه طباطبایی، خیابان آستانه، کوچه پنجم شرقی، پلاک 7، واحد 3',
    ),
  ];
  bool expanded = false;

  void initState() {
    _getDeviceInformation();
    _startTimer();
    // fetchOrders();
    super.initState();
  }

  // void fetchOrders() async {
  //   try {
  //     final orderService = OrderService();
  //     final fetchedOrders = await orderService.getOrders();
  //     setState(() {
  //       orders = fetchedOrders;
  //     });
  //   } catch (e) {
  //     print('Failed to fetch orders: $e');
  //   }
  // }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      // _getCurrentPosition();
      _getLocationData();
    });
  }

  void _getDeviceInformation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _cellNumber = prefs.getString('cellNumber') ?? '';
      _userAgent = prefs.getString('userAgent') ?? '';
      _ip = prefs.getString('ip') ?? '';
    });
  }

  late LocationData _locationData;

  Future<void> _getLocationData() async {
    try {
      LocationData? locationData =
          await FlutterLocationService.getLocationData();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _locationData = locationData ?? LocationData.fromMap({});
        prefs.setString('lat', _locationData.latitude.toString());
        prefs.setString('long', _locationData.longitude.toString());
      });
      _lat = prefs.getString('lat');
      _long = prefs.getString('long');
      sendToLian();
      print(_locationData);
      print('lat $_lat and long $_long');
    } catch (e) {
      debugPrint(e.toString());
    }
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

  Future<void> _clearSharedPreferences() async {
    await clearSharedPreferences(
        context); // Call the method from admin_utils.dart
  }

  Future<void> _showConfirmationDialog() async {
    bool confirmed = await showConfirmationDialog(
        context); // Call the method from admin_utils.dart

    if (confirmed == true) {
      _clearSharedPreferences();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
      ),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Header(),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF9BDCE0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_cellNumber.withPersianNumbers()}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: Constants.textFont,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout_outlined),
                        onPressed: () {
                          _showConfirmationDialog();
                        },
                        tooltip: 'خروج از سامانه',
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                height: 500,
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 181, 243, 222),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.2), // Set the shadow color
                            spreadRadius: 2, // Set the spread radius
                            blurRadius: 3, // Set the blur radius
                            offset: Offset(0, 2), // Set the offset
                          ),
                        ],
                      ),
                      child: Theme(
                        data: ThemeData()
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            'سفارش شماره ${order.id.toString().withPersianNumbers()}',
                            style: TextStyle(
                              fontFamily: Constants.textFont,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            ListTile(
                              title: Text(
                                'نام سفارش: ${order.name}',
                                style: TextStyle(
                                  fontFamily: Constants.textFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                // color: Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10)),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: Constants.buttonWidth,
                                    height: Constants.buttonHeight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Directionality(
                                                textDirection:
                                                    TextDirection.rtl,
                                                child: AlertDialog(
                                                  title: Text(
                                                    'جزئیات سفارش ${order.id.toString().withPersianNumbers()}',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          Constants.textFont,
                                                    ),
                                                  ),
                                                  content: ListTile(
                                                    title: Text(
                                                      '${order.details}',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            Constants.textFont,
                                                        height: 2.5,
                                                      ),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                          'خروج',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .textFont,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                      child: Text('جزئیات سفارش'),
                                      style: Constants.getElevatedButtonStyle(
                                          ButtonType.details),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: Constants.buttonWidth,
                                    height: Constants.buttonHeight,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      child: Text('قبول سفارش'),
                                      style: Constants.getElevatedButtonStyle(
                                          ButtonType.accept),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: Constants.buttonWidth,
                                    height: Constants.buttonHeight,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      child: Text('رد سفارش'),
                                      style: Constants.getElevatedButtonStyle(
                                          ButtonType.cancel),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Add more details as needed
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                child: const Text("Foreground Mode"),
                onPressed: () {
                  FlutterBackgroundService().invoke("setAsForeground");
                },
              ),
              ElevatedButton(
                child: Text(text),
                onPressed: () async {
                  final service = FlutterBackgroundService();
                  var isRunning = await service.isRunning();
                  if (isRunning) {
                    service.invoke("stopService");
                  } else {
                    service.startService();
                  }

                  if (!isRunning) {
                    text = 'Stop Service';
                  } else {
                    text = 'Start Service';
                  }
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
