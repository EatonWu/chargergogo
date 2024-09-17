import 'package:chargergogo/main.dart';
import 'package:flutter/material.dart';
import 'package:chargergogo/locations.dart' as locations;
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShopBanner extends StatefulWidget {
  ShopBannerController shopBannerController = ShopBannerController();
  ShopBanner({Key? key, required this.shopBannerController}) : super(key: key);

  @override
  _ShopBannerState createState() => _ShopBannerState();

}

class _ShopBannerState extends State<ShopBanner> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.black),
          left: BorderSide(width: 1.0, color: Colors.black),
          right: BorderSide(width: 1.0, color: Colors.black),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        )
      ),
      child: Column(
        children: [
          Text(widget.shopBannerController.currentlySelectedShopProfile == null
           ? "No Shop Selected" :
           widget.shopBannerController.currentlySelectedShopProfile!.shop_name),
        ],
      ),
    );
  }
}

