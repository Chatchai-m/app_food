import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qbmatic/model/food_model.dart';
import 'package:qbmatic/utility/my_constant.dart';
import 'package:qbmatic/utility/normal_dialog.dart';

class EditFoodMenu extends StatefulWidget {
  final FoodModel foodModel;
  EditFoodMenu({Key key, this.foodModel}) : super(key: key);

  @override
  _EditFoodMenuState createState() => _EditFoodMenuState();
}

class _EditFoodMenuState extends State<EditFoodMenu> {
  FoodModel foodModel;

  File file;
  String name, price, detail, pathImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    foodModel = widget.foodModel;
    name = foodModel.nameFood;
    price = foodModel.price;
    detail = foodModel.detail;
    pathImage = foodModel.pathImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: uploadButton(),
      appBar: AppBar(
        title: Text("ปรับปรุง เมนู ${foodModel.nameFood}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            nameFood(),
            groupImage(),
            priceFood(),
            detailFood(),
          ],
        ),
      ),
    );
  }

  FloatingActionButton uploadButton() {
    return FloatingActionButton(
      onPressed: () {
        if (name.isEmpty || price.isEmpty || detail.isEmpty) {
          normalDialog(context, "กรุณากรอกให้ครับ ทุกช่องคะ");
        } else {
          confirmEdit();
        }
      },
      child: Icon(Icons.cloud_upload),
    );
  }

  Future<Null> confirmEdit() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text("คุณต้องการจะเปลี่ยนแปลง เมนูอาหาร ?"),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  editValueOnMySQL();
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
                ),
                label: Text("Yes"),
              ),
              FlatButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.clear,
                  color: Colors.red,
                ),
                label: Text("No"),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<Null> editValueOnMySQL() async {
    try {
      if (file != null) {
        String urlUpload = MyConstant().domain + '/saveFood.php';
        Random random = Random();
        int i = random.nextInt(100000000);
        String nameFile = 'editFood$i.jpg';

        Map<String, dynamic> map = Map();
        map['file'] =
            await MultipartFile.fromFile(file.path, filename: nameFile);
        FormData formData = FormData.fromMap(map);

        pathImage = '/Food/${nameFile}' ;
        await Dio().post(urlUpload, data: formData);
      }

      String url = MyConstant().domain +
          '/editFoodWhereId.php?isAdd=true&id=${foodModel.id}&nameFood=$name&pathImage=$pathImage&price=$price&detail=$detail';

      print(url);
      await Dio().get(url).then((value) => Navigator.pop(context));
    } catch (e) {
      print(e);
    }
  }

  Widget groupImage() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () => chooseImage(ImageSource.camera)),
          Container(
            margin: EdgeInsets.only(top: 5.0),
            // padding: EdgeInsets.all(5.0),
            width: 250.0,
            height: 250.0,
            child: file == null
                ? Image.network(
                    MyConstant().domain + foodModel.pathImage,
                    fit: BoxFit.cover,
                  )
                : Image.file(file),
          ),
          IconButton(
              icon: Icon(Icons.add_photo_alternate),
              onPressed: () => chooseImage(ImageSource.gallery))
        ],
      );

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

  Widget nameFood() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => name = value.trim(),
              initialValue: foodModel.nameFood,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.fastfood),
                border: OutlineInputBorder(),
                labelText: "ชื่อ เมนูอาหาร",
              ),
            ),
          ),
        ],
      );

  Widget priceFood() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => price = value.trim(),
              keyboardType: TextInputType.number,
              initialValue: foodModel.price,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
                labelText: "ราคาอาหาร",
              ),
            ),
          ),
        ],
      );

  Widget detailFood() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => detail = value.trim(),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              initialValue: foodModel.detail,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.details),
                border: OutlineInputBorder(),
                labelText: "รายละเอียดอาหาร",
              ),
            ),
          ),
        ],
      );
}
