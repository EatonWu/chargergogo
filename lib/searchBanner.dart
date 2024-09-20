import 'package:chargergogo/main.dart';
import 'package:flutter/material.dart';
import 'package:chargergogo/locations.dart' as locations;
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';

class ShopBanner extends StatefulWidget {
  ShopBannerController shopBannerController;
  BoxController boxController;
  Function()? onBannerOpen;
  Function()? onBannerClose;
  googleMapZoomScrollController mapController;
  ShopBanner({Key? key, required this.shopBannerController, required this.boxController, required this.mapController, this.onBannerOpen, this.onBannerClose}) : super(key: key);

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
    // return Container(
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       border: Border(
    //         top: BorderSide(width: 1.0, color: Colors.black),
    //         left: BorderSide(width: 1.0, color: Colors.black),
    //         right: BorderSide(width: 1.0, color: Colors.black),
    //       ),
    //       borderRadius: BorderRadius.only(
    //         topLeft: Radius.circular(10),
    //         topRight: Radius.circular(10),
    //       )
    //     ),
      return Container(
        width: 500,
        height: 500,
        child: TapRegion(
          onTapOutside: (event) {
            print("Tapping Outside");
            widget.boxController.hideBox();
          },
          onTapInside: (event) {
            print("Tapping Inside");
          },
          child: SlidingBox(
              controller: widget.boxController,
              minHeight: 0,
              onBoxHide: () {
                if (widget.onBannerClose != null) {
                  widget.onBannerClose!();
                }
              },
              onBoxShow: () {
                if (widget.onBannerOpen != null) {
                  widget.onBannerOpen!();
                }
              },
              onBoxSlide: (double slideAmount) {
                if (slideAmount == 0) {
                  widget.boxController.hideBox();
                }
                // print("Box Slid: $slideAmount");
              },
              body: Text(widget.shopBannerController.currentlySelectedShopProfile!.shop_name)),
        ),
          );
  }
}

