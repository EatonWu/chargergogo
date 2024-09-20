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
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ShopBanner extends StatefulWidget {
  ShopBannerController shopBannerController;
  BoxController boxController;
  Function()? onBannerOpen;
  Function()? onBannerClose;
  googleMapZoomScrollController mapController;
  ShopBanner(
      {Key? key,
      required this.shopBannerController,
      required this.boxController,
      required this.mapController,
      this.onBannerOpen,
      this.onBannerClose})
      : super(key: key);

  @override
  _ShopBannerState createState() => _ShopBannerState();
}

class _ShopBannerDisplay extends StatefulWidget {
  final locations.CGGShopProfile? shopProfile;

  _ShopBannerDisplay({Key? key, required this.shopProfile}) : super(key: key);

  @override
  _ShopBannerDisplayState createState() => _ShopBannerDisplayState();
}

class _ShopBannerDisplayState extends State<_ShopBannerDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: (widget.shopProfile == null) ? Container() : Column(
        children: [
          // image
          Image.network(widget.shopProfile!.image_l,
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Center(child: Text('Error loading image'));
              },
          ),
          Text(widget.shopProfile!.shop_name),
          Text(widget.shopProfile!.address),
        ],
      ),
    );
  }
}

class _ShopBannerState extends State<ShopBanner> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      child: TapRegion(
        onTapOutside: (event) {
          print("Tapping Outside");

          if (widget.boxController.isBoxVisible) {
            widget.boxController.hideBox();
          }
          setState(() {
            widget.mapController.scrollEnabled = true;
            widget.mapController.zoomEnabled = true;
          });
        },
        onTapInside: (event) {
          setState(() {
            widget.mapController.scrollEnabled = false;
            widget.mapController.zoomEnabled = false;
          });
          if (kDebugMode) {
            print("Tapping Inside");
          }
        },
        child: SlidingBox(
            style: BoxStyle.shadow,
            // green border for the box
            controller: widget.boxController,
            minHeight: 0,
            draggableIcon : Icons.arrow_drop_down,
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
              if (slideAmount == 0 && widget.boxController.isBoxVisible) {
                widget.boxController.hideBox();
              }
            },
            body: Center(
              child: _ShopBannerDisplay(
                shopProfile: widget.shopBannerController.currentlySelectedShopProfile,
              ),
            ),
        ),
      ),
    );
  }
}
