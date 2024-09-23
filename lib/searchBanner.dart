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
  const _ShopBannerDisplay({super.key, required this.shopData});

  @override
  _ShopBannerDisplayState createState() => _ShopBannerDisplayState();
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
    var timeRangeColor;
    // nowInTimeRange(widget.shopData!.profile.business_hours) ? Colors.green : Colors.red
    if (widget.shopData != null) {
      timeRangeColor = nowInTimeRange(widget.shopData!.profile.business_hours) ? Colors.green : Colors.red;
    }
    else {
      timeRangeColor = Colors.red;
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
                          color: timeRangeColor,
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
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 120,
                          maxWidth: 120,
                        ),
                        child: DisplayTypeWidget(
                          displayType: widget.shopData!.display_type,
                        ),
                    ),
                  )
                )
              ],
              // create a squared rectangle with white background that says open or closed depending on the shopData on the top right of the stack
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 13.0,
              left: 16.0,
              right: 16.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 550,
              ),
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.shopData!.profile.shop_name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                        Text(widget.shopData!.profile.address,
                        style:
                          const TextStyle(
                            color: Color.fromARGB(0xFF, 0x57, 0x57, 0x57),
                          )
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
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
                                      color: timeRangeColor,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // get screen width using media query
                                  // var screenWidth = MediaQuery.sizeOf(context).width;
                                  // bool isSmallScreen = screenWidth < 600;
                                  // print("Screen width: $screenWidth");
                    
                                  return Wrap(
                                    // Change direction based on screen width
                                    direction: Axis.horizontal,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: formatPricingStrings(widget.shopData!.pricing_str).map((price) {
                                          return Text(
                                            price,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 16.0, right: 60.0),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          AvailabilityQuantityDisplayWidget(
                                            onSlots: widget.shopData!.slots.on,
                                            offSlots: widget.shopData!.slots.off,
                                            color: timeRangeColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: timeRangeColor, width: 2),
                      foregroundColor: timeRangeColor,
                    ),
                    onPressed: () {
                      if (kDebugMode) {
                        print("Directions");
                      }
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.directions),
                        Text('Directions'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 32.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: timeRangeColor, width: 2),
                      foregroundColor: timeRangeColor,
                    ),
                    onPressed: () {
                      if (kDebugMode) {
                        print("Scan");
                      }
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.qr_code_scanner),
                        Text('Scan'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
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
    return SizedBox(
      width: 600,
      height: 700,
      child: TapRegion(
        onTapOutside: (event) {
          // print("Tapping Outside");
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
            // print("Tapping Inside");
          }
        },
        child: SlidingBox(
            style: BoxStyle.shadow,
            // green border for the box
            controller: widget.boxController,
            minHeight: 0,
            maxHeight: 500,
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

class AvailabilityQuantityDisplayWidget extends StatelessWidget {
  final int onSlots;
  final int offSlots;
  final MaterialColor color;

  AvailabilityQuantityDisplayWidget({
    super.key,
    required this.onSlots,
    required this.offSlots,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
        color: Colors.grey.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text(
                  'Available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.electric_bolt_rounded),
                    Container(
                      width: 4,
                    ),
                    Text(
                      '$onSlots',
                      style: TextStyle(
                        fontSize: 20,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0,),
              child: Container(
                width: 1,
                height: 40,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            Column(
              children: [
                const Text(
                  'Return Slots',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.double_arrow),
                    Container(
                      width: 4,
                    ),
                    Text(
                      '$offSlots',
                      style: TextStyle(
                        fontSize: 20,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class DisplayTypeWidget extends StatelessWidget {
  final String displayType;

  const DisplayTypeWidget({super.key, required this.displayType});


  Image getImage(String displayType) {
    final Map<String, String> displayTypeToUrl = {
      "C8": "https://static.chargergogo.com/static/prod-app/assets/assets/images/c8.8638cde1.png",
      "C8 Pro": "https://static.chargergogo.com/static/prod-app/assets/assets/images/c8p.f8fd3669.png",
      "C40 Pro": "https://static.chargergogo.com/static/prod-app/assets/assets/images/c40.20f37302.png",
      "C32 Pro": "https://static.chargergogo.com/static/prod-app/assets/assets/images/c32.7c162811.png",
      "C20 Pro": "https://cdn.prod.website-files.com/60aedb2a10130f4caabac218/666737cc2d1e3474adb525c7_C20.png",
      "C64": "https://cdn.prod.website-files.com/60aedb2a10130f4caabac218/666737210b9d0dc8ef021f33_C64.png",
    };

    if (displayTypeToUrl.containsKey(displayType)) {
      return Image.network(displayTypeToUrl[displayType]!,
          fit: BoxFit.contain,
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Image.asset("default_c8.png");
          }
      );
    } else {
      return Image.asset("default_c8.png");
    }
  }

  @override
  Widget build(BuildContext context) {

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 120,
        maxWidth: 120,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Text(displayType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              flex: 1,
              child: getImage(displayType),
            ),
          ],
        ),
      ),
    );
  }
}

class ClickableTelLink extends StatelessWidget {
  final String phoneNumber;
  final MaterialColor color;
  const ClickableTelLink({super.key, required this.phoneNumber, required this.color});

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapInside: (event) async {
        final Uri telUri = Uri(
          scheme: 'tel',
          path: phoneNumber,
        );
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        } else {
          throw 'Could not launch $telUri';
        }
      },
      child: Text(
        phoneNumber,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


List<String> formatPricingStrings(List<String> pricingStrs) {
  return pricingStrs.map((str) {
    return str.startsWith('-') ? str.substring(1).trim() : str.trim();
  }).toList();
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
