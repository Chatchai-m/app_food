import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qbmatic/model/user_model.dart';
import 'package:qbmatic/utility/my_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderListShop extends StatefulWidget {
  @override
  _OrderListShopState createState() => _OrderListShopState();
}

class _OrderListShopState extends State<OrderListShop> {

  @override
  Widget build(BuildContext context) {
    return Text('Order list food.');
  }
}
