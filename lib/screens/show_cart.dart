import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qbmatic/model/cart_model.dart';
import 'package:qbmatic/utility/my_constant.dart';
import 'package:qbmatic/utility/my_style.dart';
import 'package:qbmatic/utility/normal_dialog.dart';
import 'package:qbmatic/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ShowCart extends StatefulWidget {
  @override
  _ShowCartState createState() => _ShowCartState();
}

class _ShowCartState extends State<ShowCart> {
  List<CartModel> cartModels = List();
  int total = 0;
  bool status = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readSQLite();
  }

  Future<Null> readSQLite() async {
    total = 0;
    var object = await SQLiteHelper().readAllDataFromSQLite();
    for (var model in object) {
      // string
      String sumString = model.sum;
      total += int.parse(sumString);
    }

    setState(() {
      status = false;
      cartModels = object;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ตะกร้าของฉัน"),
      ),
      body: cartModels.length == 0
          ? Center(child: Text("ตะกร้าว่างเปล่า"))
          : buildContent(),
    );
  }

  Widget buildContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildNameShop(),
            buildHeadTitle(),
            buildListFood(),
            Divider(),
            buildTotal(),
            MyStyle().mySizebox(),
            buildClearCartButton(),
            builOrdertButton()
          ],
        ),
      ),
    );
  }

  Widget buildClearCartButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 150.0,
          child: RaisedButton.icon(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Colors.red.shade600,
            onPressed: () {
              confirmDeleteAllData();
            },
            icon: Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
            label: Text(
              "Clear ตะกร้า",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget builOrdertButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 150.0,
          child: RaisedButton.icon(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: MyStyle().darkColor,
            onPressed: () {
              orderThread();
            },
            icon: Icon(
              Icons.fastfood,
              color: Colors.white,
            ),
            label: Text(
              "Order",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTotal() => Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [MyStyle().showTitleH2("Total : ")],
            ),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3Red(total.toString()),
          ),
        ],
      );

  Widget buildNameShop() {
    return Container(
      margin: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              MyStyle().showTitleH2("ร้าน ${cartModels[0].nameShop}"),
            ],
          ),
          Row(
            children: [
              MyStyle()
                  .showTitleH3('ระยะทาง = ${cartModels[0].distance} กิโลเมตร'),
            ],
          ),
          Row(
            children: [
              MyStyle()
                  .showTitleH3('ค่าขนส่ง = ${cartModels[0].transport} บาท'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHeadTitle() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: MyStyle().showTitleH3("รายการอาหาร"),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3("ราคา"),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3("จำนวน"),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3("รวม"),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().mySizebox(),
          ),
        ],
      ),
    );
  }

  Widget buildListFood() => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: cartModels.length,
        itemBuilder: (context, index) => Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(cartModels[index].nameFood),
            ),
            Expanded(
              flex: 1,
              child: Text(cartModels[index].price),
            ),
            Expanded(
              flex: 1,
              child: Text(cartModels[index].amount),
            ),
            Expanded(
              flex: 1,
              child: Text(cartModels[index].sum),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () async {
                  int id = cartModels[index].id;
                  print("id = $id");
                  await SQLiteHelper().deleteDataWhereId(id).then((value) {
                    print("Success delete id = $id");
                    readSQLite();
                  });
                },
              ),
            )
          ],
        ),
      );

  Future<Null> confirmDeleteAllData() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text("คุณต้องการลบรายการอาหารทั้งหทด ?"),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                color: MyStyle().primaryColor,
                onPressed: () async {
                  Navigator.pop(context);
                  await SQLiteHelper().deleteAllData().then((value) {
                    readSQLite();
                  });
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                label: Text(
                  "ยืนยัน",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                color: Colors.red.shade500,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                label: Text(
                  "ยกเลิก",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<Null> orderThread() async {
    DateTime dateTime = DateTime.now();
    String orderDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    String idShop = cartModels[0].idShop;
    String nameShop = cartModels[0].nameShop;
    String distance = cartModels[0].distance;
    String transport = cartModels[0].transport;

    List<String> idFoods = List();
    List<String> nameFoods = List();
    List<String> prices = List();
    List<String> amounts = List();
    List<String> sums = List();

    for (var model in cartModels) {
      idFoods.add(model.idFood);
      nameFoods.add(model.nameFood);
      prices.add(model.price);
      amounts.add(model.amount);
      sums.add(model.sum);
    }

    String idFood = idFoods.toString();
    String nameFood = nameFoods.toString();
    String price = prices.toString();
    String amount = amounts.toString();
    String sum = sums.toString();

    String idRider = '';
    String status = 'UserOrder';

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');
    String nameUser = preferences.getString('Name');

    print("orderDateTime = ${orderDateTime}, idFood = ${idFood}");
    print(
        "nameFood = ${nameFood}, price = ${price}, amount = ${amount}, sum = ${sum}");

    String url = MyConstant().domain +
        '/addOrder.php?isAdd=true&orderDateTime=$orderDateTime&idUser=$idUser&nameUser=$nameUser&idShop=$idShop&nameShop=$nameShop&distance=$distance&transport=$transport&idFood=$idFood&nameFood=$nameFood&price=$price&amount=$amount&sum=$sum&idRider=$idRider&status=$status';
    await Dio().get(url).then((value) async {
      print(value);
      if (value.toString() == 'true') {
        Toast.show(
          "Order completed",
          context,
          duration: Toast.LENGTH_LONG,
        );
        await SQLiteHelper().deleteAllData().then((value) {
          readSQLite();
        });
      } else {
        normalDialog(context, "ไม่สามารถสั่งได้กรุณาลองใหม่");
      }
    });
  }
}
