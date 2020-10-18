import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qbmatic/model/user_model.dart';
import 'package:qbmatic/screens/show_shop_food_menu.dart';
import 'package:qbmatic/utility/my_constant.dart';
import 'package:qbmatic/utility/my_style.dart';

class ShowListShopAll extends StatefulWidget {
  @override
  _ShowListShopAllState createState() => _ShowListShopAllState();
}

class _ShowListShopAllState extends State<ShowListShopAll> {
  List<UserModel> userModels = List();
  List<Widget> shopCards = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readShop();
  }

  Future<Null> readShop() async {
    String url = MyConstant().domain +
        '/getUserWhereChooseType.php?isAdd=true&chooseType=Shop';

    print(url);
    await Dio().get(url).then((value) {
      print(value);
      var result = json.decode(value.data);
      int index = 0;
      for (var map in result) {
        UserModel model = UserModel.fromJson(map);
        if (model.nameShop.isNotEmpty) {
          print(map);
          print(model.nameShop);
          setState(() {
            userModels.add(model);
            shopCards.add(createCard(model, index));
          });
          index++;
        }
      }
    });
  }

  Widget createCard(UserModel userModel, int index) {
    return GestureDetector(
      onTap: () {
        print(index);
        MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => ShowShopFoodMenu(
                  userModel: userModel,
                ));
        Navigator.push(context, route);
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 80.0,
              height: 80.0,
              child: CircleAvatar(
                backgroundImage:
                    NetworkImage(MyConstant().domain + userModel.urlPicture),
              ),
            ),
            MyStyle().mySizebox(),
            MyStyle().showTitleH3(userModel.nameShop)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return shopCards.length == 0
        ? MyStyle().showProgress()
        : GridView.extent(
            maxCrossAxisExtent: 180.0,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            children: shopCards,
          );
  }
}
