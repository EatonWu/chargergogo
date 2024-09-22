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
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final locations.CggShopData? shopData;
  _ShopBannerDisplay({Key? key, required this.shopData}) : super(key: key);

  @override
  _ShopBannerDisplayState createState() => _ShopBannerDisplayState();
}

class ClickableTelLink extends StatelessWidget {
  final String phoneNumber;
  MaterialColor color = Colors.green;
  ClickableTelLink({required this.phoneNumber, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        } else {
          throw 'Could not launch $telUri';
        }
      },
      child: Text(
        phoneNumber,
        style: TextStyle(
          // red if hour is closed, green if open
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

String? formatPhoneNumber(String phone) {
  // Regular expression to match phone numbers in various formats
  final RegExp phoneRegExp = RegExp(r'^\(?(\d{3})\)?[-.\s]?(\d{3})[-.\s]?(\d{4})$');
  final match = phoneRegExp.firstMatch(phone);

  if (match != null) {
    // Format the phone number with dashes and parentheses
    return '(${match.group(1)}) ${match.group(2)}-${match.group(3)}';
  } else {
    // Return null if the input is invalid
    return null;
  }
}


class _ShopBannerDisplayState extends State<_ShopBannerDisplay> {

  Image getDefaultImage() {
    // return AssetMapBitmap(
    //   'assets/default_background.jpg',
    // );
    return Image.asset(
        "default_background.jpg",
        height: 150,
        fit: BoxFit.fill,
    );
  }

  @override
  Widget build(BuildContext context) {
    String? formattedPhoneNumber;
    // check if shopProfile contains an image link, if not, return the placeholder image
    if (widget.shopData != null) {
      formattedPhoneNumber = formatPhoneNumber(widget.shopData!.profile.shop_tel);
    }
    return Container(
      child: (widget.shopData == null) ? Container() : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 150,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(widget.shopData!.profile.image_l,
                  height: 150,
                  fit: BoxFit.fill,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return getDefaultImage();
                  },
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                          color: nowInTimeRange(widget.shopData!.profile.business_hours) ? Colors.green : Colors.red,
                      ),
                      child: SizedBox(
                          width: 80,
                          child: Center(
                              child: Text(nowInTimeRange(widget.shopData!.profile.business_hours) ? "Open" : "Closed",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                          ),
                      ),
                    ),
                  ),
                ),
              ],
              // create a squared rectangle with white background that says open or closed depending on the shopData on the top right of the stack
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              left: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.shopData!.profile.shop_name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
                Text(widget.shopData!.profile.address,
                style:
                  const TextStyle(
                    color: Color.fromARGB(0xFF, 0x57, 0x57, 0x57),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(formatTimeRange(widget.shopData!.profile.business_hours),),
                      ),
                    ],
                  ),
                ),
                formattedPhoneNumber == null ? Container() : Row(
                  children: [
                    const Icon(Icons.phone_outlined),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ClickableTelLink(
                          phoneNumber: formattedPhoneNumber,
                          color: nowInTimeRange(widget.shopData!.profile.business_hours) ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    var inTimeRange = true;
    if (widget.shopBannerController.currentlySelectedShop != null) {
      inTimeRange = nowInTimeRange(widget.shopBannerController.currentlySelectedShop!.profile.business_hours) || widget.shopBannerController.currentlySelectedShop!.profile.open_all_day;
    }
    else {
      inTimeRange = false;
    }
    return Container(
      width: 600,
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
          if (widget.onBannerOpen != null) {
            widget.onBannerOpen!();
          }
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
            draggableIconColor: Colors.white,
            draggableIconBackColor: inTimeRange ? Colors.green : Colors.red,
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
                shopData: widget.shopBannerController.currentlySelectedShop,
              ),
            ),
        ),
      ),
    );
  }
}
