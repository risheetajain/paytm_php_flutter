import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paytm Gateway Flutter & Php Template',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PaytmIntegration(),
    );
  }
}

class PaytmIntegration extends StatefulWidget {
  const PaytmIntegration({Key? key}) : super(key: key);

  @override
  _PaytmIntegrationState createState() => _PaytmIntegrationState();
}

class _PaytmIntegrationState extends State<PaytmIntegration> {
  String result = "";
  final TextEditingController _amountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Please Enter Amount to do payment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              maxLength: 5,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(),
                  border: OutlineInputBorder()),
              autofocus: true,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Please Enter valid Amount";
                }
              },
            ),
            ElevatedButton(
                child: const Text("PAYTM"),
                onPressed: () {
                  initiateTransaction().then(
                    (value) {
                      debugPrint(value);
                      if (value["success"] == true) {
                        AllInOneSdk.startTransaction(
                                value["mid"],
                                value["orderId"],
                                value["amount"],
                                value["txnToken"],
                                value["callbackUrl"],
                                value["isStaging"],
                                true)
                            .then((paymentResponse) {
                          result = paymentResponse.toString();
                        }).catchError((onError) {
                          if (onError is PlatformException) {
                            setState(() {
                              result = onError.message! +
                                  " \n " +
                                  onError.details!.toString();
                            });
                          } else {
                            setState(() {
                              result = onError.toString();
                            });
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please Try Again ")));
                      }
                    },
                  );
                }),
            const SizedBox(
              height: 12,
            ),
            if (result.isNotEmpty) Text("Your Response : $result")
          ],
        ),
      ),
    );
  }

  Future initiateTransaction() async {
    try {
      var url = "http://192.168.1.81/paytm_php_flutter/Php/";
      FormData formData = FormData.fromMap({"amount": _amountController.text});
      var response = await Dio().post(url, data: formData);

      return response.data;
    } on TimeoutException {
      return {"mesage": 'The connection has timed out, Please try again!'};
    } on SocketException {
      return {"message": "Internet Issue! No Internet connection 😑"};
    } catch (e) {
      debugPrint("dio error$e");
      return {"message": "Connection Problem"};
    }
  }
}
