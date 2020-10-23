import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qbmatic/model/food_model.dart';
import 'package:qbmatic/model/user_model.dart';
import 'package:qbmatic/utility/my_constant.dart';
import 'package:qbmatic/utility/my_style.dart';

class ShowMenuFood extends StatefulWidget {
  final UserModel userModel;
  ShowMenuFood({Key key, this.userModel}) : super(key: key);
  @override
  _ShowMenuFoodState createState() => _ShowMenuFoodState();
}

class _ShowMenuFoodState extends State<ShowMenuFood> {
  UserModel userModel;
  String idShop;
  List<FoodModel> foodModels = List();
  int amount = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userModel = widget.userModel;
    readFoodMenu();
  }

  Future<Null> readFoodMenu() async {
    idShop = userModel.id;
    String url = MyConstant().domain +
        '/getFoodWhereidShop.php?isAdd=true&idShop=$idShop';

    Response response = await Dio().get(url);
    print('res <===> $response');
    var result = json.decode(response.data);
    print(result);
    for (var map in result) {
      FoodModel foodModel = FoodModel.fromJson(map);
      setState(() {
        foodModels.add(foodModel);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return foodModels.length == 0
        ? MyStyle().showProgress()
        : ListView.builder(
            itemCount: foodModels.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                print("click $index");
                confirmOrder(index);
              },
              child: Row(
                children: <Widget>[
                  showFoodImage(context, index),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.width * 0.4,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                foodModels[index].nameFood,
                                style: MyStyle().mainTtile,
                              ),
                            ],
                          ),
                          Text(
                            "${foodModels[index].price} บาท",
                            style: TextStyle(
                              fontSize: 30,
                              color: MyStyle().darkColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5 -
                                    8.0,
                                child: Text(foodModels[index].detail),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Container showFoodImage(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      width: MediaQuery.of(context).size.width * 0.5 - 16.0,
      height: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
            image:
                NetworkImage(MyConstant().domain + foodModels[index].pathImage),
            fit: BoxFit.cover),
      ),
    );
  }

  Future<Null> confirmOrder(int index) async {
    amount = 1;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                foodModels[index].nameFood,
                style: MyStyle().mainH2Ttile,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                // padding: EdgeInsets.all(5.0),
                width: 180,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                      image: NetworkImage(
                          MyConstant().domain + foodModels[index].pathImage),
                      fit: BoxFit.cover),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      size: 36,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        amount++;
                      });
                    },
                  ),
                  Text(
                    amount.toString(),
                    style: MyStyle().mainTtile,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      size: 36,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        if (amount > 1) {
                          amount--;
                        }
                      });
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    width: 110.0,
                    child: RaisedButton(
                      color: MyStyle().primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Order",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    width: 110.0,
                    child: RaisedButton(
                      color: MyStyle().primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
