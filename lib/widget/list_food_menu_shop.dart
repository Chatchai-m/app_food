import 'package:flutter/material.dart';
import 'package:qbmatic/screens/add_food_menu.dart';

class ListFoodMenuShop extends StatefulWidget {
  @override
  _ListFoodMenuShopState createState() => _ListFoodMenuShopState();
}

class _ListFoodMenuShopState extends State<ListFoodMenuShop> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [Text('Order list food.'), addMenuButton()],
    );
  }

  Widget addMenuButton() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.only(
                  bottom: 16.0,
                  right: 16.0,
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    MaterialPageRoute route =
                        MaterialPageRoute(builder: (context) => AddFoodMenu());
                    Navigator.push(context, route);
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ],
          ),
        ],
      );
}
