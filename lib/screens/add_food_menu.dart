import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qbmatic/utility/my_constant.dart';
import 'package:qbmatic/utility/my_style.dart';
import 'package:qbmatic/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFoodMenu extends StatefulWidget {
  @override
  _AddFoodMenuState createState() => _AddFoodMenuState();
}

class _AddFoodMenuState extends State<AddFoodMenu> {
  String nameFood, price, detail;
  File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("เพิ่มรายการเมนูอาหาร"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            shotTitleFood("รูปอาหาร"),
            groupImages(),
            shotTitleFood("รายละเอียดอาหาร"),
            nameForm(),
            MyStyle().mySizebox(),
            priceForm(),
            MyStyle().mySizebox(),
            detailForm(),
            MyStyle().mySizebox(),
            saveButton()
          ],
        ),
      ),
    );
  }

  Widget saveButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton.icon(
        color: MyStyle().primaryColor,
        onPressed: () {
          print("Save food menu.");
          if (file == null) {
            normalDialog(context, "กรุณาเลือกรูปภาพ");
          } else if (nameFood == null ||
              nameFood.isEmpty ||
              price == null ||
              price.isEmpty ||
              detail == null ||
              detail.isEmpty) {
            normalDialog(context, "กรุณากรอกข้อมูลให้ครบ");
          } else {
            uploadFoodAndInsertData();
          }
        },
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        label: Text(
          "Save food menu.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<Null> uploadFoodAndInsertData() async {
    String urlUpload = MyConstant().domain + '/saveFood.php';
    Random random = Random();
    int i = random.nextInt(100000000);
    String nameFile = 'food$i.jpg';

    try {
      Map<String, dynamic> map = Map();
      map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
      FormData formData = FormData.fromMap(map);

      await Dio().post(urlUpload, data: formData).then((value) async {
        String urlPathImage = '/Food/$nameFile';
        SharedPreferences preferences = await SharedPreferences.getInstance();
        String idShop = preferences.getString("id");
        String url = MyConstant().domain +
            '/addFood.php?isAdd=true&idShop=$idShop&NameFood=$nameFood&PathImage=$urlPathImage&Price=$price&Detail=$detail';

        await Dio().get(url).then((value) => Navigator.pop(context));
      });
    } catch (e) {}
  }

  Widget nameForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) => nameFood = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.fastfood),
            labelText: "ชื่ออาหาร",
            border: OutlineInputBorder(),
          ),
        ),
      );

  Widget priceForm() => Container(
        width: 250.0,
        child: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) => price = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.attach_money),
            labelText: "ราคาอาหาร",
            border: OutlineInputBorder(),
          ),
        ),
      );

  Widget detailForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) => detail = value.trim(),
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.details),
            labelText: "รายละเอียดอาหาร",
            border: OutlineInputBorder(),
          ),
        ),
      );

  Row groupImages() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: () => chooseImage(ImageSource.camera),
        ),
        Container(
          width: 250.0,
          height: 250.0,
          child: file == null
              ? Image.asset('images/myimage.png')
              : Image.file(file),
        ),
        IconButton(
          icon: Icon(Icons.add_photo_alternate),
          onPressed: () => chooseImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Future<Null> chooseImage(ImageSource source) async {
    try {
      var object = await ImagePicker().getImage(
        source: source,
        maxHeight: 800.0,
        maxWidth: 800.0,
      );

      setState(() {
        file = File(object.path);
      });
    } catch (e) {
      print(e);
    }
  }

  Widget shotTitleFood(String string) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          MyStyle().showTitleH2(string),
        ],
      ),
    );
  }
}
