import 'package:flutter/material.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:chargergogo/locations.dart' as locations;
import 'package:chargergogo/search.dart' as search_bar;
import 'package:chargergogo/searchBanner.dart' as searchBanner;
import 'package:flutter/widgets.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(const MyApp());
}

List<TimeOfDay>? parseTimeRange(String timeRange) {
  // Split the string by '-'
  final parts = timeRange.split('-');
  if (parts.length != 2) {
    return null; // Invalid format
  }

  // Parse start and end times
  final startTime = _parseTimeOfDay(parts[0]);
  final endTime = _parseTimeOfDay(parts[1]);

  if (startTime != null && endTime != null) {
    return [startTime, endTime];
  }

  return null; // If parsing failed
}

TimeOfDay? _parseTimeOfDay(String time) {
  final parts = time.split(':');
  if (parts.length != 2) {
    return null; // Invalid format
  }

  // Convert parts to integers
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);

  if (hour != null && minute != null) {
    return TimeOfDay(hour: hour % 24, minute: minute % 60);
  }

  return null; // If parsing failed
}

//

String formatTimeRange(String timeRange) {
  // Split the time range into opening and closing times
  List<String> times = timeRange.split('-');
  if (times.length != 2) {
    throw ArgumentError('Invalid time range format');
  }

  // Parse the opening and closing times
  TimeOfDay openingTime = _parseTime(times[0].trim());
  TimeOfDay closingTime = _parseTime(times[1].trim());

  // Handle edge cases
  if (openingTime.hour == 0 && openingTime.minute == 0 && closingTime.hour == 0 && closingTime.minute == 0) {
    return '12:00AM - 12:00AM'; // Open all day
  }
  if (closingTime.hour == 24 && closingTime.minute == 0) {
    closingTime = TimeOfDay(hour: 23, minute: 59); // Treat 24:00 as 23:59
  }

  // Convert to 12-hour format with AM/PM
  String openingTimeFormatted = _formatTime(openingTime);
  String closingTimeFormatted = _formatTime(closingTime);

  return '$openingTimeFormatted - $closingTimeFormatted';
}

TimeOfDay _parseTime(String time) {
  List<String> parts = time.split(':');
  if (parts.length != 2) {
    throw ArgumentError('Invalid time format');
  }
  int hour = int.parse(parts[0]);
  int minute = int.parse(parts[1]);
  return TimeOfDay(hour: hour, minute: minute);
}

String _formatTime(TimeOfDay time) {
  final hours = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minutes = time.minute.toString().padLeft(2, '0');
  final period = time.hour < 12 ? 'AM' : 'PM';
  return '$hours:$minutes$period';
}

BitmapDescriptor getIconFromTimeRange(String timeRange, BitmapDescriptor icon, BitmapDescriptor transparent_icon){
  var split = parseTimeRange(timeRange);
  var currentHour = DateTime.now().hour;

  if (split == null) {
    return icon;
  }
  var openHour = split[0].hour;
  var closeHour = split[1].hour;

  if (openHour == 0 && closeHour == 0) {
    return icon;
  }

  if (currentHour < openHour || currentHour >= closeHour) {
    return transparent_icon;
  }
  return icon;
}

bool nowInTimeRange(String timeRange) {
  var split = parseTimeRange(timeRange);
  var currentHour = DateTime.now().hour;

  if (split == null) {
    return true;
  }
  var openHour = split[0].hour;
  var closeHour = split[1].hour;

  if (openHour == 0 && closeHour == 0) {
    return true;
  }

  if (openHour >= currentHour || currentHour >= closeHour) {
    return false;
  }
  return true;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class googleMapZoomScrollController with ChangeNotifier {
  bool zoomEnabled = true;
  bool scrollEnabled = true;

  void toggleZoom(bool? value) {
    if (value == null) {
      zoomEnabled = !zoomEnabled;
    }
    else {
      zoomEnabled = value;
    }
    notifyListeners();
  }

  void toggleScroll(bool? value) {
    if (value == null) {
      scrollEnabled = !scrollEnabled;
    }
    else {
      scrollEnabled = value;
    }
    notifyListeners();
  }

  void disableAll() {
    zoomEnabled = false;
    scrollEnabled = false;
    notifyListeners();
  }

  googleMapZoomScrollController() {
    zoomEnabled = true;
    scrollEnabled = true;
  }
}

class ShopBannerController with ChangeNotifier {
  locations.CggShopData? currentlySelectedShop;
  locations.CGGShopProfile? currentlySelectedShopProfile;

  void setShop(locations.CggShopData? shop) {
    if (currentlySelectedShop != shop) {
      currentlySelectedShop = shop;
      notifyListeners();
    }
  }

  void setShopProfile(locations.CGGShopProfile? shopProfile) {
    if (currentlySelectedShopProfile != shopProfile) {
      currentlySelectedShopProfile = shopProfile;
      notifyListeners();
    }
  }

  void clearShopProfile() {
    if (currentlySelectedShopProfile != null) {
      currentlySelectedShopProfile = null;
      notifyListeners();
    }
  }
}

class _MyAppState extends State<MyApp> {
  GoogleMapController? mapController;
  ShopBannerController shopBannerController = ShopBannerController();
  BoxController boxController = BoxController();
  final LatLng _center = const LatLng(36.1716, -115.1391);
  // final LatLng _center = const LatLng(56.172249, 10.187372)
  final Map<String, Marker> _allMarkers = {};
  final Map<String, Marker> _openMarkers = {};
  Map<String, Marker> _currentMarkers = {};
  bool showClosedSwitch = true;
  bool searchIsOpen = false;
  bool bannerIsOpen = false;
  late googleMapZoomScrollController zoomScrollControl = googleMapZoomScrollController();
  // locations.CGGShop? currentlySelectedShop;
  // locations.CGGShopProfile? currentlySelectedShopProfile;
  
  // set current time
  final currentHour = DateTime.now().hour;

  @override
  void initState() {
    super.initState();
    zoomScrollControl = googleMapZoomScrollController();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    // final googleOffices = await locations.getGoogleOffices();
    final cggShops = await locations.getCGGShops();

    var icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(60, 60)), 'cgg_logo.png');

    var transparent_icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(60, 60)), 'transparent_cgg_logo.png');

    setState(() {
      _allMarkers.clear();
      _openMarkers.clear();

      // cgg stuff
      for (final shop in cggShops.shops) {
        var chosenIcon = getIconFromTimeRange(shop.business_hours, icon, transparent_icon);
        final marker = Marker(
          markerId: MarkerId(shop.id),
          icon: chosenIcon,
          position: LatLng(shop.lat, shop.lng),
          // infoWindow: InfoWindow(
          //   title: shop.id,
          //   snippet: shop.business_hours,
          // ),
          onTap: () async {
            await locations.getCGGShopData(shop.id).then(
                (value) => {
                  shopBannerController.currentlySelectedShop = value,
                  if (value != null) {
                    shopBannerController.currentlySelectedShopProfile = value.profile
                  }
                }
            );

            boxController.showBox();
            bannerIsOpen = true;

            if (mapController != null) {
              var oldZoom = await mapController!.getZoomLevel();
              // first set camera position to zoom out by 1
              mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(shop.lat, shop.lng),
                    zoom: 18
                  ),
                ),
              );
              setState(() {
              });
            }
          },
        );
        _allMarkers[shop.id] = marker;
        if (nowInTimeRange(shop.business_hours)) {
          _openMarkers[shop.id] = marker;
        }
      }
    });
    setState(() => mapController = controller);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Chargergogo Demo App'),
          elevation: 2,
        ),
        body: cggMapPage(),
      ),
    );
  }

  Widget cggMapPage() {
    _currentMarkers = showClosedSwitch ? _allMarkers : _openMarkers;
    // print("marker quantity: ${_markers.length}");
    return Stack(
      children: [
        GoogleMap(
          scrollGesturesEnabled: !searchIsOpen && !bannerIsOpen,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: _currentMarkers.values.toSet(),
        ),
        // ** SEARCH BAR ** //
        PositionedDirectional(
          top: 0,
          end: 0,
          child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  mapController == null? Container() : searchBarAndResults(zoomScrollControl, mapController!),
                ],
              ),
              // hide unavailable shops switch

          ]),
        ),
        // ** SHOP BANNER ** //
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: 
            ListenableBuilder(
              listenable: shopBannerController,
              builder: (BuildContext context, Widget? child) {
                // print("Rebuilt ShopBanner");
                return shopBannerController.currentlySelectedShopProfile == null ? 
                const Text("No Shop Selected") : 
                SizedBox(
                  width: 600,
                  height: 700,
                  child: searchBanner.ShopBanner(
                    onBannerOpen: () {
                      // print("Banner Opened");
                      setState(() {
                        bannerIsOpen = true;
                      });
                    },
                    onBannerClose: () {
                      // print("Banner Closed");
                      setState(() {
                        bannerIsOpen = false;

                      });
                    },
                    shopBannerController: shopBannerController,
                    boxController: boxController,
                    mapController: zoomScrollControl
                  ));
              }) 
          )
        )
      ]
    );
  }

  Widget searchBarAndResults(googleMapZoomScrollController zoomScrollControl, GoogleMapController mapController) {
    return Padding( 
      padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          width: 300,
          child: search_bar.SearchBarAndResultsWidget(
            onSearchOpen: () {
              if (searchIsOpen) {
                return;
              }
              setState(() {
                // print("search is open");
                searchIsOpen = true;
              });
            },
            onSearchClose: () {
              // print("search is closed");
              if (!searchIsOpen) {
                return;
              }
              setState(() {
                searchIsOpen = false;
              });
            },
            mapController: mapController,
            shopBannerController: shopBannerController,
            boxController: boxController,
            children: [
              LabeledSwitch(
                label: 'Show closed stores?',
                value: showClosedSwitch,
                onChanged: (value) {
                  setState(() {
                    showClosedSwitch = value;
                    if (showClosedSwitch) {
                      _currentMarkers = _allMarkers;
                    } else {
                      _currentMarkers = _openMarkers;
                    }
                  });
                },
              ),
            ]
          )),
      );
  }

}

class LabeledSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const LabeledSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // background color
          borderRadius: BorderRadius.circular(20), // round rect
          border: Border.all(color: Colors.grey), // optional border
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}