import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qbmatic/model/order_model.dart';
import 'package:qbmatic/utility/my_constant.dart';
import 'package:qbmatic/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_indicator/steps_indicator.dart';

class ShowStatusFoodOrder extends StatefulWidget {
  @override
  _ShowStatusFoodOrderState createState() => _ShowStatusFoodOrderState();
}

class _ShowStatusFoodOrderState extends State<ShowStatusFoodOrder> {
  String idUser;
  bool statusOrder = true;
  List<OrderModel> orderModels = List();
  List<List<String>> listMenuFoods = List();
  List<List<String>> listPices = List();
  List<List<String>> listAmounts = List();
  List<List<String>> listSums = List();
  List<int> totalInts = List();
  List<int> statusInts = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idUser = preferences.getString('id');
    print(idUser);
    readOrderFromIdUser();
  }

  @override
  Widget build(BuildContext context) {
    return statusOrder ? buildNonOrder() : buildContent();
  }

  Widget buildContent() => ListView.builder(
        padding: EdgeInsets.all(16.0),
        shrinkWrap: true,
        itemCount: orderModels.length,
        itemBuilder: (context, index) => Column(
          children: [
            buildNameShop(index),
            buildDatetimeOrder(index),
            buildDistance(index),
            buildTransport(index),
            buildHead(),
            buildListViewMenuFood(index),
            buildTotal(index),
            MyStyle().mySizebox(),
            buildStepIndicator(statusInts[index]),
            MyStyle().mySizebox()
          ],
        ),
      );

  Widget buildStepIndicator(int index) => Column(
        children: [
          StepsIndicator(
            lineLength: 80,
            selectedStep: index,
            nbSteps: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text("Order"),
              Text("Cooking"),
              Text("Delivery"),
              Text("Finish"),
            ],
          )
        ],
      );

  Widget buildTotal(int index) => Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [MyStyle().showTitleH3Red("รวมราคาอาหาร : ")],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyStyle().showTitleH3Purple(totalInts[index].toString())
              ],
            ),
          )
        ],
      );

  ListView buildListViewMenuFood(int index) => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: listMenuFoods[index].length,
        itemBuilder: (context, index2) => Container(
          // padding: EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(listMenuFoods[index][index2]),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(listPices[index][index2]),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(listAmounts[index][index2]),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(listSums[index][index2]),
                  ],
                ),
              )
            ],
          ),
        ),
      );

  Container buildHead() {
    return Container(
      padding: EdgeInsets.only(left: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: MyStyle().showTitleH3White("รายการอาหาร"),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3White("ราคา"),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3White("จำนวน"),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3White("ผลรวม"),
          ),
        ],
      ),
    );
  }

  Row buildTransport(int index) {
    return Row(
      children: [
        MyStyle().showTitleH3Purple(
            "ค่าขนส่ง : " + orderModels[index].transport + " บาท"),
      ],
    );
  }

  Row buildDistance(int index) {
    return Row(
      children: [
        MyStyle().showTitleH3Red(
            "ระยะทาง : " + orderModels[index].distance + " กิโลเมตร"),
      ],
    );
  }

  Row buildDatetimeOrder(int index) {
    return Row(
      children: [
        MyStyle().showTitleH3(
            "วันเวลาที่ Order : " + orderModels[index].orderDateTime),
      ],
    );
  }

  Row buildNameShop(int index) {
    return Row(
      children: [
        MyStyle().showTitleH2("ร้าน " + orderModels[index].nameShop),
      ],
    );
  }

  Center buildNonOrder() {
    return Center(
      child: Text("Non order."),
    );
  }

  Future<Null> readOrderFromIdUser() async {
    if (idUser != null) {
      String url = MyConstant().domain +
          '/getOrderWhereidUser.php?isAdd=true&idUser=$idUser';
      await Dio().get(url).then((value) {
        if (value.toString() != 'null') {
          var rs = json.decode(value.data);
          print(rs);
          for (var map in rs) {
            OrderModel model = OrderModel.fromJson(map);
            List<String> menuFoods = changeArray(model.nameFood);
            List<String> prices = changeArray(model.price);
            List<String> amounts = changeArray(model.amount);
            List<String> sums = changeArray(model.sum);

            int status = 0;
            switch (model.status) {
              case "UserOrder":
                status = 0;
                break;
              case "ShopCooking":
                status = 1;
                break;
              case "Rider":
                status = 2;
                break;
              case "Finish":
                status = 3;
                break;
            }

            int total = 0;
            for (var string in sums) {
              total = total + int.parse(string.trim());
            }

            print(total);

            print("menuFoods ===> $menuFoods");
            setState(() {
              orderModels.add(model);
              statusOrder = false;
              listMenuFoods.add(menuFoods);
              listPices.add(prices);
              listAmounts.add(amounts);
              listSums.add(sums);
              totalInts.add(total);
              statusInts.add(status);
            });
          }
        }
      });
    }
  }

  List<String> changeArray(String string) {
    List<String> list = List();
    String myString = string.substring(1, string.length - 1);
    print("myString ====> $myString");
    list = myString.split(',');
    int index = 0;
    for (var string in list) {
      list[index] = string.trim();
      index++;
    }
    return list;
  }
}
