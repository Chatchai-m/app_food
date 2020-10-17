import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qbmatic/model/user_model.dart';
import 'package:qbmatic/screens/add_info_shop.dart';
import 'package:qbmatic/screens/edit_info_shop.dart';
import 'package:qbmatic/utility/my_constant.dart';
import 'package:qbmatic/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InformationShop extends StatefulWidget {
  @override
  _InformationShopState createState() => _InformationShopState();
}

class _InformationShopState extends State<InformationShop> {
  UserModel userModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataUser();
  }

  Future<Null> readDataUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');

    String url = '${MyConstant().domain}/getUserWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      setState(() {
        userModel = UserModel.fromJson(result[0]);
      });
    });
  }

  void routeToAddInfo() {
    print("route");
    Widget widget = userModel.nameShop.isEmpty ? AddInfoShop() : EditInfoShop();
    MaterialPageRoute route = MaterialPageRoute(builder: (context) => widget);
    Navigator.push(context, route).then((value) => readDataUser());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        userModel == null
            ? MyStyle().showProgress()
            : (userModel.nameShop == null || userModel.nameShop.isEmpty)
                ? showNoData(context)
                : showListInfoShop(),
        addAndEditButtom()
      ],
    );
  }

  Widget showListInfoShop() => Column(
        children: <Widget>[
          MyStyle().showTitleH2("รายละเอียดร้าน ${userModel.nameShop}"),
          showImage(),
          Row(
            children: [
              MyStyle().showTitleH2("ที่อยู่ของร้าน"),
            ],
          ),
          Row(
            children: [
              Text(userModel.address),
            ],
          ),
          MyStyle().mySizebox(),
          showMap()
        ],
      );

  Container showImage() {
    return Container(
      width: 200.0,
      height: 200.0,
      child: Image.network(MyConstant().domain + userModel.urlPicture),
    );
  }

  Set<Marker> shopMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('myShop'),
          position:
              LatLng(double.parse(userModel.lat), double.parse(userModel.lng)),
          infoWindow: InfoWindow(
            title: "ตำแหน่งร้านของคุณ",
            snippet: "ละติจูด = $userModel.lat, ลองติจูด = $userModel.lng",
          ))
    ].toSet();
  }

  Widget showMap() {
    double lat = double.parse(userModel.lat);
    double lng = double.parse(userModel.lng);
    LatLng latLng = LatLng(lat, lng);

    CameraPosition position = CameraPosition(target: latLng, zoom: 16.0);

    return Expanded(
      // padding: EdgeInsets.all(10.0),
      // height: 300.0,
      child: GoogleMap(
          initialCameraPosition: position,
          mapType: MapType.normal,
          onMapCreated: (controller) {},
          markers: shopMarker()),
    );
  }

  Widget showNoData(BuildContext context) =>
      MyStyle().titleCenter(context, 'ยังไม่มี ข้อมูล กรุณาเพิ่มข้อมูล');

  Row addAndEditButtom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.only(right: 16.0, bottom: 16.0),
              child: FloatingActionButton(
                child: Icon(Icons.edit),
                onPressed: () {
                  routeToAddInfo();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
