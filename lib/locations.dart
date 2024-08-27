import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'locations.g.dart';

@JsonSerializable()
class LatLng {
  LatLng({
    required this.lat,
    required this.lng,
  });

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  final double lat;
  final double lng;
}

@JsonSerializable()
class Region {
  Region({
    required this.coords,
    required this.id,
    required this.name,
    required this.zoom,
  });

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
  Map<String, dynamic> toJson() => _$RegionToJson(this);

  final LatLng coords;
  final String id;
  final String name;
  final double zoom;
}

@JsonSerializable()
class Office {
  Office({
    required this.address,
    required this.id,
    required this.image,
    required this.lat,
    required this.lng,
    required this.name,
    required this.phone,
    required this.region,
  });

  factory Office.fromJson(Map<String, dynamic> json) => _$OfficeFromJson(json);
  Map<String, dynamic> toJson() => _$OfficeToJson(this);

  final String address;
  final String id;
  final String image;
  final double lat;
  final double lng;
  final String name;
  final String phone;
  final String region;
}

@JsonSerializable()
class Locations {
  Locations({
    required this.offices,
    required this.regions,
  });

  factory Locations.fromJson(Map<String, dynamic> json) =>
      _$LocationsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationsToJson(this);

  final List<Office> offices;
  final List<Region> regions;
}

Future<Locations> getGoogleOffices() async {
  const googleLocationsURL = 'https://about.google/static/data/locations.json';

  // Retrieve the locations of Google offices
  try {
    final response = await http.get(Uri.parse(googleLocationsURL));
    if (response.statusCode == 200) {
      return Locations.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }

  // Fallback for when the above HTTP request fails.
  return Locations.fromJson(
    json.decode(
      await rootBundle.loadString('assets/locations.json'),
    ) as Map<String, dynamic>,
  );
}

// -------------------------------- CGG STUFF -------------------------------------------

@JsonSerializable()
class CGGShopProfile {
  CGGShopProfile({
    required this.shop_id,
    required this.shop_name,
    required this.image_l,
    required this.address,
    required this.business_hours,
    required this.open_all_day,
    required this.close_all_day,
    required this.lat,
    required this.lng,
    required this.currency,
    required this.deposit,
    required this.shop_tel,
    required this.country_code,
  });

  factory CGGShopProfile.fromJson(Map<String, dynamic> json) => _$CGGShopProfileFromJson(json);
  Map<String, dynamic> toJson() => _$CGGShopProfileToJson(this);

  final String shop_id;
  final String shop_name;
  final String image_l;
  final String address;
  final String business_hours;
  final String open_all_day;
  final String close_all_day;
  final double lat;
  final double lng;
  final String currency;
  final String deposit;
  final String shop_tel;
  final String country_code;
}

@JsonSerializable()
  class CGGShopSlots {
    CGGShopSlots({
      required this.on,
      required this.off
    });

    factory CGGShopSlots.fromJson(Map<String, dynamic> json) => _$CGGShopSlotsFromJson(json);
    Map<String, dynamic> toJson() => _$CGGShopSlotsToJson(this);

    final int on;
    final int off;
  }

@JsonSerializable()
class CggShopData {
  CggShopData({
    required this.profile,
    required this.pricing_str,
    required this.display_type,
    required this.slots,
    required this.available,
  });

  factory CggShopData.fromJson(Map<String, dynamic> json) => _$CggShopDataFromJson(json);
  Map<String, dynamic> toJson() => _$CggShopDataToJson(this);

  final CGGShopProfile profile;
  final List<String> pricing_str;
  final String display_type;
  final List<String> slots;
  final bool available;
}

@JsonSerializable()
class CGGShop {
  CGGShop({
    required this.id,
    required this.lat,
    required this.lng,
    required this.business_hours
  });

  factory CGGShop.fromJson(Map<String, dynamic> json) => _$CGGShopFromJson(json);
  Map<String, dynamic> toJson() => _$CGGShopToJson(this);

  final String id;
  final double lat;
  final double lng;
  final String business_hours;
}

@JsonSerializable()
class CGGShops {
  CGGShops({
    required this.shops,
  });

  factory CGGShops.fromJson(Map<String, dynamic> json) =>
      _$CGGShopsFromJson(json);
  Map<String, dynamic> toJson() => _$CGGShopsToJson(this);

  final List<CGGShop> shops;
}

Future<CGGShops> getCGGShops() async {
  const cggShopsURL = 'https://api.chargergogo.com/api/v2/nearby/shoplist';

  // Retrieve the locations of Google offices
   // build headers
    // curl "https://api.chargergogo.com/api/v2/nearby/shoplist" -X POST -H
    // "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0"
    // -H "Accept: application/json, text/plain, */*"
    // -H "Accept-Language: en-US,en;q=0.5"
    // -H "Accept-Encoding: gzip, deflate, br, zstd"
    // -H "Content-Type: application/x-www-form-urlencoded"
    // -H "lang: en"
    // -H "Origin: https://app.chargergogo.com"
    // -H "Connection: keep-alive"
    // -H "Referer: https://app.chargergogo.com/"
    // -H "Cookie: messagesUtk=3319ed76fa2e4326957b013333ab36ce"
    // -H "Sec-Fetch-Dest: empty" -H "Sec-Fetch-Mode: cors"
    // -H "Sec-Fetch-Site: same-site"
    // -H "TE: trailers"
  try {
    final response = await http.get(Uri.parse(cggShopsURL),
    headers: {
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0",
      "Accept": "application/json, text/plain, */*",
      "Accept-Language": "en-US,en;q=0.5",
      "Accept-Encoding": "gzip, deflate, br, zstd",
      "Content-Type": "application/x-www-form-urlencoded",
      "lang": "en",
      "Origin": "https://app.chargergogo.com",
      "Connection": "keep-alive",
      "Referer": "https://app.chargergogo.com/",
      "Sec-Fetch-Dest": "empty",
      "Sec-Fetch-Mode": "cors",
      "Sec-Fetch-Site": "same-site",
      "TE": "trailers" 
    }
    );
    if (response.statusCode == 200) {
      return CGGShops.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }

  // Fallback for when the above HTTP request fails.
  return CGGShops.fromJson(
    json.decode(
      await rootBundle.loadString('assets/shops.json'),
    ) as Map<String, dynamic>,
  );
}
