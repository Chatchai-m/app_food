import 'package:flutter/material.dart';
import 'package:qbmatic/utility/my_style.dart';
import 'package:qbmatic/utility/signout_process.dart';
import 'package:qbmatic/widget/show_list_shop_all.dart';
import 'package:qbmatic/widget/show_status_food_order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainUser extends StatefulWidget {
  @override
  _MainUserState createState() => _MainUserState();
}

class _MainUserState extends State<MainUser> {
  String nameUser;
  Widget currentWidget;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentWidget = ShowListShopAll();
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nameUser = preferences.getString('Name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nameUser == null ? 'Main User' : '$nameUser login'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                signOutProcess(context);
              })
        ],
      ),
      drawer: showDrawer(),
      body: currentWidget,
    );
  }

  Drawer showDrawer() => Drawer(
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                showHead(),
                meneListShop(),
                meneStatusFood(),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                meneSignOut(),
              ],
            )
          ],
        ),
      );

  ListTile meneListShop() {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          currentWidget = ShowListShopAll();
        });
      },
      leading: Icon(Icons.home),
      title: Text("แสดงร้านค้า"),
      subtitle: Text("แสดงร้านค้า ที่สามารถสั่งอาหารได้"),
    );
  }

  ListTile meneStatusFood() {
    return ListTile(
      onTap: () {
        setState(() {
          currentWidget = ShowStatusFoodOrder();
        });
        Navigator.pop(context);
      },
      leading: Icon(Icons.restaurant_menu),
      title: Text("แสดงรายการอาหารที่สั่ง"),
      subtitle: Text("แสดงรายการอาหารที่สั่ง และยังไม่ได้มาส่ง"),
    );
  }

  Widget meneSignOut() {
    return Container(
      decoration: BoxDecoration(color: Colors.red.shade700),
      child: ListTile(
        onTap: () => signOutProcess(context),
        leading: Icon(
          Icons.exit_to_app,
          color: Colors.white,
        ),
        title: Text(
          "Sign Out",
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          "ออกจากแอป",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  UserAccountsDrawerHeader showHead() {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDecoration('user.jpg'),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text(
        nameUser == null ? "Name Login" : nameUser,
        style: TextStyle(color: Colors.white),
      ), accountEmail: null,
      //accountEmail: Text(
      //  'Please Login',
      //  style: TextStyle(color: MyStyle().darkColor),
      //),
    );
  }
}
