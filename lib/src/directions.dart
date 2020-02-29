// Copyright (c) 2020, the MarchDev Toolkit project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';

import 'package:meta/meta.dart';

import 'package:flinq/flinq.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show LatLng, LatLngBounds;

part 'directions.dto.dart';

/// This service is used to calculate route between two points
class DirectionsService {
  static const _directionApiUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  static String _apiKey;

  /// Initializer of [GoogleMap].
  ///
  /// `Required` if `Directions API` on `Mobile device` will be needed.
  /// For other cases, could be ignored.
  static void init(String apiKey) => _apiKey = apiKey;

  /// Gets an google API key
  static String get apiKey => _apiKey;

  /// Calculates route between two points.
  ///
  /// `request` argument contains origin and destination points
  /// and also settings for route calculation.
  ///
  /// `callback` argument will be called when route calculations finished.
  Future<void> route(
    DirectionsRequest request,
    void Function(DirectionsResult, DirectionsStatus) callback,
  ) async {
    assert(() {
      if (request == null) {
        throw ArgumentError.notNull('request');
      }

      if (request == null) {
        throw ArgumentError.notNull('callback');
      }

      return true;
    }());

    final url = '$_directionApiUrl${request.toParams()}&key=${apiKey}';
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw HttpException('${response.statusCode} (${response.reasonPhrase})',
          uri: response.request.url);
    }

    final result = DirectionsResult.fromMap(json.decode(response.body));

    callback(result, result.status);
  }
}

/// Settings for route calculation.
///
/// `origin` and `destination` arguments are required.
class DirectionsRequest {
  const DirectionsRequest({
    @required this.origin,
    @required this.destination,
    this.travelMode,
  });

  /// As a value of location could be used:
  ///  * [LatLng]
  ///  * [String]
  ///
  /// PlaceId should be passe with the following format:
  ///
  ///   `place_id:ChIJ3S-JXmauEmsRUcIaWtf4MzE`
  final dynamic origin;

  /// As a value of location could be used:
  ///  * [LatLng]
  ///  * [String]
  ///
  /// PlaceId should be passed with the following format:
  ///
  ///   `place_id:ChIJ3S-JXmauEmsRUcIaWtf4MzE`
  final dynamic destination;

  /// Specifies the mode of transport to use when calculating
  /// directions. Valid values and other request details are
  /// specified in [TravelModes].
  ///
  /// Default value is [TravelMode.driving]
  final TravelMode travelMode;

  String _convertLocation(dynamic location) {
    if (location is LatLng) {
      return '${location.latitude},${location.longitude}';
    } else if (location is String) {
      location = location.replaceAll(',', ' ');
      return location.split(' ').join('+');
    }

    throw UnsupportedError(
        'Unsupported type of argument: ${location.runtimeType}');
  }

  String _addIfNotNull(String name, dynamic value) =>
      value == null ? '' : '&$name=$value';

  /// Converts `this` object into query string parameters.
  String toParams() => '?origin=${_convertLocation(origin)}&'
      'destination=${_convertLocation(destination)}'
      '${_addIfNotNull('mode', travelMode)}';
}
