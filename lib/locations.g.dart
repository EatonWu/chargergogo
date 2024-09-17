// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatLng _$LatLngFromJson(Map<String, dynamic> json) => LatLng(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$LatLngToJson(LatLng instance) => <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };

Region _$RegionFromJson(Map<String, dynamic> json) => Region(
      coords: LatLng.fromJson(json['coords'] as Map<String, dynamic>),
      id: json['id'] as String,
      name: json['name'] as String,
      zoom: (json['zoom'] as num).toDouble(),
    );

Map<String, dynamic> _$RegionToJson(Region instance) => <String, dynamic>{
      'coords': instance.coords,
      'id': instance.id,
      'name': instance.name,
      'zoom': instance.zoom,
    };

Office _$OfficeFromJson(Map<String, dynamic> json) => Office(
      address: json['address'] as String,
      id: json['id'] as String,
      image: json['image'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String,
      phone: json['phone'] as String,
      region: json['region'] as String,
    );

Map<String, dynamic> _$OfficeToJson(Office instance) => <String, dynamic>{
      'address': instance.address,
      'id': instance.id,
      'image': instance.image,
      'lat': instance.lat,
      'lng': instance.lng,
      'name': instance.name,
      'phone': instance.phone,
      'region': instance.region,
    };

Locations _$LocationsFromJson(Map<String, dynamic> json) => Locations(
      offices: (json['offices'] as List<dynamic>)
          .map((e) => Office.fromJson(e as Map<String, dynamic>))
          .toList(),
      regions: (json['regions'] as List<dynamic>)
          .map((e) => Region.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LocationsToJson(Locations instance) => <String, dynamic>{
      'offices': instance.offices,
      'regions': instance.regions,
    };

CGGShopProfile _$CGGShopProfileFromJson(Map<String, dynamic> json) =>
    CGGShopProfile(
      shop_id: json['shop_id'] as String,
      shop_name: json['shop_name'] as String,
      image_l: json['image_l'] as String,
      address: json['address'] as String,
      business_hours: json['business_hours'] as String,
      open_all_day: json['open_all_day'] as bool,
      close_all_day: json['close_all_day'] as bool,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      currency: json['currency'] as String,
      deposit: (json['deposit'] as num).toInt(),
      shop_tel: json['shop_tel'] as String,
      country_code: json['country_code'] as String,
    );

Map<String, dynamic> _$CGGShopProfileToJson(CGGShopProfile instance) =>
    <String, dynamic>{
      'shop_id': instance.shop_id,
      'shop_name': instance.shop_name,
      'image_l': instance.image_l,
      'address': instance.address,
      'business_hours': instance.business_hours,
      'open_all_day': instance.open_all_day,
      'close_all_day': instance.close_all_day,
      'lat': instance.lat,
      'lng': instance.lng,
      'currency': instance.currency,
      'deposit': instance.deposit,
      'shop_tel': instance.shop_tel,
      'country_code': instance.country_code,
    };

CGGShopProfileResponse _$CGGShopProfileResponseFromJson(
        Map<String, dynamic> json) =>
    CGGShopProfileResponse(
      ec: (json['ec'] as num).toInt(),
      em: json['em'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      data: CggShopData.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$CGGShopProfileResponseToJson(
        CGGShopProfileResponse instance) =>
    <String, dynamic>{
      'ec': instance.ec,
      'em': instance.em,
      'timestamp': instance.timestamp,
      'data': instance.data,
      'msg': instance.msg,
    };

CGGShopSlots _$CGGShopSlotsFromJson(Map<String, dynamic> json) => CGGShopSlots(
      on: (json['on'] as num).toInt(),
      off: (json['off'] as num).toInt(),
    );

Map<String, dynamic> _$CGGShopSlotsToJson(CGGShopSlots instance) =>
    <String, dynamic>{
      'on': instance.on,
      'off': instance.off,
    };

CggShopData _$CggShopDataFromJson(Map<String, dynamic> json) => CggShopData(
      profile: CGGShopProfile.fromJson(json['profile'] as Map<String, dynamic>),
      pricing_str: (json['pricing_str'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      display_type: json['display_type'] as String,
      slots: CGGShopSlots.fromJson(json['slots'] as Map<String, dynamic>),
      available: json['available'] as bool,
    );

Map<String, dynamic> _$CggShopDataToJson(CggShopData instance) =>
    <String, dynamic>{
      'profile': instance.profile,
      'pricing_str': instance.pricing_str,
      'display_type': instance.display_type,
      'slots': instance.slots,
      'available': instance.available,
    };

CGGShop _$CGGShopFromJson(Map<String, dynamic> json) => CGGShop(
      id: json['id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      business_hours: json['business_hours'] as String,
    );

Map<String, dynamic> _$CGGShopToJson(CGGShop instance) => <String, dynamic>{
      'id': instance.id,
      'lat': instance.lat,
      'lng': instance.lng,
      'business_hours': instance.business_hours,
    };

CGGShops _$CGGShopsFromJson(Map<String, dynamic> json) => CGGShops(
      shops: (json['shops'] as List<dynamic>?)
              ?.map((e) => CGGShop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CGGShop>[],
    );

Map<String, dynamic> _$CGGShopsToJson(CGGShops instance) => <String, dynamic>{
      'shops': instance.shops,
    };

GetShoplistAPIResponse _$GetShoplistAPIResponseFromJson(
        Map<String, dynamic> json) =>
    GetShoplistAPIResponse(
      ec: (json['ec'] as num).toInt(),
      em: json['em'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      data: CGGShops.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetShoplistAPIResponseToJson(
        GetShoplistAPIResponse instance) =>
    <String, dynamic>{
      'ec': instance.ec,
      'em': instance.em,
      'timestamp': instance.timestamp,
      'data': instance.data,
    };
