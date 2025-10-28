import 'package:aamarpay/aamarpay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class MyPayment extends StatefulWidget {
  const MyPayment({super.key});

  @override
  State<MyPayment> createState() => _MyPaymentState();
}

class _MyPaymentState extends State<MyPayment> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Aamarpay(

          returnUrl: (String url) {
            if (kDebugMode) {
              print(url);
            }
          },

          isLoading: (bool loading) {
            setState(() {
              isLoading = loading;
            });
          },

          status: (EventState event, String message) {
            if (kDebugMode) {
              print(event);
            }
            if (event == EventState.success) {}
          },
          cancelUrl: "example.com/payment/cancel",
          successUrl: "example.com/payment/confirm",
          failUrl: "example.com/payment/fail",
          customerEmail: "riadrayhan111@gmail.com",
          customerMobile: "01615573020",
          customerName: "Riad Rayhan",
          signature: "37da1e291ac2612ee91cd9736e4ce4f5",
          storeID: "subeasy",
          transactionAmount: "200",

          transactionID: "${DateTime.now().millisecondsSinceEpoch}",
          description: "test",

          isSandBox: false,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
            color: Colors.orange,
            height: 50,
            child: Center(
              child: Text(
                "Payment",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

