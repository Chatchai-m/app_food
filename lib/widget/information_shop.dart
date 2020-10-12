import 'package:flutter/material.dart';
import 'package:qbmatic/screens/add_info_shop.dart';
import 'package:qbmatic/utility/my_style.dart';

class InformationShop extends StatefulWidget {
  @override
  _InformationShopState createState() => _InformationShopState();
}

class _InformationShopState extends State<InformationShop> {
  void routeToAddInfo() {
    print("route");
    MaterialPageRoute route =
        MaterialPageRoute(builder: (context) => AddInfoShop());
    Navigator.push(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MyStyle().titleCenter(context, 'ยังไม่มี ข้อมูล กรุณาเพิ่มข้อมูล'),
        addAndEditButtom()
      ],
    );
  }

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
