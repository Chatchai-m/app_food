import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:qbmatic/model/user_model.dart';
import 'package:qbmatic/utility/my_constant.dart';
import 'package:qbmatic/utility/my_style.dart';
import 'package:qbmatic/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditInfoShop extends StatefulWidget {
  @override
  _EditInfoShopState createState() => _EditInfoShopState();
}

class _EditInfoShopState extends State<EditInfoShop> {
  UserModel userModel;
  String nameShop, address, phone, urlPicture;
  Location location = Location();
  double lat, lng;
  File file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readCurrentInfo();

    location.onLocationChanged.listen((event) {
      setState(() {
        lat = event.latitude;
        lng = event.longitude;
        print("lat = $lat, lng = $lng");
      });
    });
  }

  Future<Null> readCurrentInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');

    String url = '${MyConstant().domain}/getUserWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      print(result);
      setState(() {
        userModel = UserModel.fromJson(result[0]);
        nameShop = userModel.nameShop;
        address = userModel.address;
        phone = userModel.phone;
        urlPicture = userModel.urlPicture;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ปรับปรุง รายละเอียดร้าน"),
      ),
      body: userModel == null ? MyStyle().showProgress() : showContent(),
    );
  }

  Widget showContent() => SingleChildScrollView(
        child: Column(
          children: <Widget>[
            nameShopForm(),
            showImage(),
            addressForm(),
            phoneForm(),
            lat == null ? MyStyle().showProgress() : showMap(),
            editButton()
          ],
        ),
      );

  Widget editButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton.icon(
        color: MyStyle().primaryColor,
        onPressed: () => confirmDialog(),
        icon: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        label: Text(
          'ปรับปรุงรายละเอียด',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<Null> confirmDialog() async {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: Text("คุณแน่ใจว่าจะ ปรับปรุงรายละเอียดร้าน ?"),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlineButton(
                      onPressed: () {
                        Navigator.pop(context);
                        editThread();
                      },
                      child: Text("แน่ใจ"),
                    ),
                    OutlineButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("ไม่แน่ใจ"),
                    ),
                  ],
                )
              ],
            ));
  }

  Future<Null> editThread() async {
    if (file != null) {
      Random random = Random();
      int i = random.nextInt(100000000);
      String nameFile = 'editFood$i.jpg';

      urlPicture = '/Shop/$nameFile';
      String urlUpload = MyConstant().domain + '/saveShop.php';

      Map<String, dynamic> map = Map();
      map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
      FormData formData = FormData.fromMap(map);
      await Dio().post(urlUpload, data: formData);
    }

    String id = userModel.id;
    String url = MyConstant().domain +
        '/editUserWhereId.php?isAdd=true&id=$id&NameShop=$nameShop&Address=$address&Phone=$phone&UrlPicture=$urlPicture&Lat=$lat&Lng=$lng';
    Response response = await Dio().get(url);
    if (response.toString() == 'true') {
      Navigator.pop(context);
    } else {
      normalDialog(context, "ไม่สามารถอัปเดตข้อมูลได้ กรุณาลองใหม่");
    }
  }

  Set<Marker> currentMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('myMarker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: "ร้านอยู่นี่",
          snippet: 'Lat = $lat, Lng = $lng',
        ),
      )
    ].toSet();
  }

  Widget showMap() {
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 16.0,
    );

    return Container(
      margin: EdgeInsets.only(top: 16.0),
      height: 250,
      child: GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) {},
        markers: currentMarker(),
      ),
    );
  }

  Widget showImage() {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () => chooseImage(ImageSource.camera),
          ),
          Container(
            width: 200.0,
            height: 200.0,
            child: file == null
                ? Image.network(MyConstant().domain + urlPicture)
                : Image.file(file),
          ),
          IconButton(
            icon: Icon(Icons.add_photo_alternate),
            onPressed: () => chooseImage(ImageSource.gallery),
          )
        ],
      ),
    );
  }

  Future<Null> chooseImage(ImageSource source) async {
    try {
      var object = await ImagePicker().getImage(
        source: source,
        maxWidth: 800.0,
        maxHeight: 800.0,
      );

      setState(() {
        file = File(object.path);
      });
    } catch (e) {
      print(e);
    }
  }

  Widget nameShopForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => nameShop = value.trim(),
              initialValue: nameShop,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_box),
                border: OutlineInputBorder(),
                labelText: "ชื่อร้าน",
              ),
            ),
          ),
        ],
      );

  Widget addressForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => address = value.trim(),
              initialValue: address,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
                labelText: "ที่อยู่",
              ),
            ),
          ),
        ],
      );

  Widget phoneForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => phone = value.trim(),
              initialValue: phone,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                labelText: "เบอร์ติดต่อร้านค้า",
              ),
            ),
          ),
        ],
      );
}
