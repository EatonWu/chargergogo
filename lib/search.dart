
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
part 'search.g.dart';

class SearchBarAndResultsWidget extends StatefulWidget{
  final Function() onSearchOpen;
  final Function() onSearchClose;
  final GoogleMapController mapController;
  final ShopBannerController shopBannerController;
  final BoxController boxController;
  List<Widget>? children = [];

  SearchBarAndResultsWidget({
    super.key,
    required this.onSearchOpen,
    required this.onSearchClose,
    required this.mapController,
    required this.shopBannerController,
    required this.boxController,
    this.children,
    });


  @override
  _SearchBarAndResultsWidgetState createState() => _SearchBarAndResultsWidgetState();
}

@JsonSerializable()
class CGGSearchShop {
CGGSearchShop({
    required this.shop_id,
    required this.shop_name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory CGGSearchShop.fromJson(Map<String, dynamic> json) => _$CGGSearchShopFromJson(json);
  Map<String, dynamic> toJson() => _$CGGSearchShopToJson(this);

  final String shop_id;
  final String shop_name;
  final String address;
  final double lat;
  final double lng;

  String getShopName() {
    return shop_name;
  }

  String getAddress() {
    return address;
  }

  double getLat() {
    return lat;
  }

  double getLng() {
    return lng;
  }

  String getShopID() {
    return shop_id;
  }

}


@JsonSerializable()
class CGGSearchData {
  CGGSearchData({
    required this.shops,
  });

  factory CGGSearchData.fromJson(Map<String, dynamic> json) => _$CGGSearchDataFromJson(json);
  Map<String, dynamic> toJson() => _$CGGSearchDataToJson(this);

  CGGSearchData getEmpty() {
    return CGGSearchData(shops: []);
  }

  final List<CGGSearchShop> shops;
}

@JsonSerializable()
class GetSearchAPIResponse {
  GetSearchAPIResponse({
    required this.ec,
    required this.em,
    required this.timestamp,
    required this.data,
    required this.msg,
  });

  factory GetSearchAPIResponse.fromJson(Map<String, dynamic> json) => _$GetSearchAPIResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GetSearchAPIResponseToJson(this);

  final int ec;
  final String em;
  final int timestamp;
  final CGGSearchData data;
  final String msg;
}

Future<CGGSearchData> getSearchQueryResults(String query) async {
  var googleLocationsURL = 'https://api.chargergogo.com/api/v2/shop/search?address=$query';
  try {
    final response = await http.get(Uri.parse(googleLocationsURL));
    if (response.statusCode == 200) {
      return GetSearchAPIResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>).data;
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  print("Returning empty data");
  return CGGSearchData(shops: []);
}

class SingleResultTile extends StatelessWidget {
  final CGGSearchShop shop;
  final GoogleMapController mapController;
  Function()? onTap = () => {};
  SingleResultTile({super.key, required this.shop, this.onTap, required this.mapController});

  // set default for onTap


  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(shop.shop_name),
        subtitle: Text(shop.address),
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(shop.lat, shop.lng),
                zoom: 18
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchBarAndResultsWidgetState extends State<SearchBarAndResultsWidget> {
  List<CGGSearchShop> _searchResults = [];
  List<CGGSearchShop> _tempSearchResults = [];
  final TextEditingController _searchController = TextEditingController();
  bool searchOpen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double suggestionHeight = (_searchResults.length * 70.0).clamp(0, 500);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          TapRegion(
            onTapInside: (event) {
              if (!searchOpen) {
                widget.onSearchOpen();
                searchOpen = true;
              }
              setState(() {
                if (_searchResults.isEmpty) {
                  _searchResults = _tempSearchResults;
                }
              });
            },
            onTapOutside: (event) {
              if (searchOpen) {
                widget.onSearchClose();
                searchOpen = false;
              }
              setState(() {
                if (_searchResults.isNotEmpty) {
                  _tempSearchResults = _searchResults;
                  _searchResults = [];
                }
              });
            },
            child: Container(
              child: Column(
                children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'Search...',
                    // squircle border:
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      CGGSearchData results = await getSearchQueryResults(value);
                      setState(() {
                        _searchResults = results.shops;
                      });
                    }
                  },
                ),
                if (searchOpen) Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: suggestionHeight,
                    child: Stack(
                      children:[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                return SingleResultTile(shop: _searchResults[index],
                                  mapController: widget.mapController,
                                  onTap: () async {
                                    await locations.getCGGShopData(_searchResults[index].shop_id).then((value) {
                                      widget.shopBannerController.setShop(value);
                                      if (value != null) {
                                        widget.shopBannerController.currentlySelectedShopProfile = value.profile;
                                      }
                                    });
                                    // print("Tapped on ${_searchResults[index].shop_name}");
                                    if (searchOpen) {
                                      widget.onSearchClose();
                                      searchOpen = false;
                                    }
                                    setState(() {
                                      widget.boxController.showBox();
                                      // set search text
                                      _searchController.text = _searchResults[index].address;
                                      if (_searchResults.isNotEmpty) {
                                        _tempSearchResults = _searchResults;
                                        _searchResults = [];
                                      }
                                    });
                                  }
                                );
                              },
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),
                ),
              ],),
            ),
          ),
          if (widget.children != null && !searchOpen) ...widget.children!,
        ],
      ),
    );
  }
}   