import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:chargergogo/locations.dart' as locations;
import 'package:chargergogo/search.dart' as search_bar;
import 'package:chargergogo/searchBanner.dart' as searchBanner;

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

  if (openHour >= currentHour && currentHour >= closeHour) {
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
  locations.CGGShop? currentlySelectedShop; 
  locations.CGGShopProfile? currentlySelectedShopProfile;

  void setShop(locations.CGGShop shop) {
    currentlySelectedShop = shop;
    notifyListeners();
  }

  void setShopProfile(locations.CGGShopProfile? shopProfile) {
    currentlySelectedShopProfile = shopProfile;
    notifyListeners();
  }

  void clearShopProfile() {
    currentlySelectedShopProfile = null;
    notifyListeners();
  }
}

class _MyAppState extends State<MyApp> {
  GoogleMapController? mapController;
  ShopBannerController shopBannerController = ShopBannerController();

  final LatLng _center = const LatLng(36.1716, -115.1391);
  // final LatLng _center = const LatLng(56.172249, 10.187372)
  final Map<String, Marker> _all_markers = {};
  final Map<String, Marker> _open_markers = {};
  Map<String, Marker> current_markers = {};
  bool searchIsOpen = false;
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
      _all_markers.clear();
      _open_markers.clear();

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
            if (shopBannerController.currentlySelectedShop == null || shopBannerController.currentlySelectedShop?.id != shop.id) {
              // print("Currently selected shop: ${currentlySelectedShop?.id}");
              
              shopBannerController.currentlySelectedShop = shop;
              shopBannerController.currentlySelectedShopProfile = await locations.getCGGShopProfile(shop.id);
            }

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
        _all_markers[shop.id] = marker;
        if (nowInTimeRange(shop.business_hours)) {
          _open_markers[shop.id] = marker;
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
    current_markers = _all_markers;
    // print("marker quantity: ${_markers.length}");
    return Stack(
      children: [
        GoogleMap(
            scrollGesturesEnabled: !searchIsOpen,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            markers: current_markers.values.toSet(),
          ),
        // center the text at the bottom of the screen
        PositionedDirectional(
          top: 0,
          end: 0,
          child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            mapController == null? const Center() : searchBarAndResults(zoomScrollControl, mapController!),
          ]),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: shopBannerController.currentlySelectedShopProfile == null ? 
            Text("No Shop Selected") : 
            searchBanner.ShopBanner(shopBannerController: shopBannerController,),
          )
        )
      ]
    );
  }

  Widget searchBarAndResults(googleMapZoomScrollController zoomScrollControl, GoogleMapController mapController) {
    return Padding( 
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          width: 300,
          child: search_bar.SearchBarAndResultsWidget(
            onSearchOpen: () {
              setState(() {
                print("search is open");
                searchIsOpen = true;
              });
            },
            onSearchClose: () {
              print("search is closed");
              setState(() {
                searchIsOpen = false;
              });
            },
            mapController: mapController,
            shopBannerController: shopBannerController,
          )),
      );
  }

}