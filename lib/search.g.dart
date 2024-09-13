// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CGGSearchShop _$CGGSearchShopFromJson(Map<String, dynamic> json) =>
    CGGSearchShop(
      shop_id: json['shop_id'] as String,
      shop_name: json['shop_name'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$CGGSearchShopToJson(CGGSearchShop instance) =>
    <String, dynamic>{
      'shop_id': instance.shop_id,
      'shop_name': instance.shop_name,
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
    };

CGGSearchData _$CGGSearchDataFromJson(Map<String, dynamic> json) =>
    CGGSearchData(
      shops: (json['shops'] as List<dynamic>)
          .map((e) => CGGSearchShop.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CGGSearchDataToJson(CGGSearchData instance) =>
    <String, dynamic>{
      'shops': instance.shops,
    };

GetSearchAPIResponse _$GetSearchAPIResponseFromJson(
        Map<String, dynamic> json) =>
    GetSearchAPIResponse(
      ec: (json['ec'] as num).toInt(),
      em: json['em'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      data: CGGSearchData.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$GetSearchAPIResponseToJson(
        GetSearchAPIResponse instance) =>
    <String, dynamic>{
      'ec': instance.ec,
      'em': instance.em,
      'timestamp': instance.timestamp,
      'data': instance.data,
      'msg': instance.msg,
    };
