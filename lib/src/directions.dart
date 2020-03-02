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

    final url = '$_directionApiUrl${request.toParams()}&key=$apiKey';
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
    this.alternatives,
  });

  /// The address, textual latitude/longitude value, or place ID
  /// from which you wish to calculate directions.
  ///
  /// This field is required.
  ///
  ///  * If you pass an **address**, the Directions service geocodes
  /// the string and converts it to a latitude/longitude
  /// coordinate to calculate directions. This coordinate may be
  /// different from that returned by the Geocoding API, for
  /// example a building entrance rather than its center.
  ///
  ///   ```origin=24+Sussex+Drive+Ottawa+ON```
  ///
  ///  * If you pass **coordinates**, they are used unchanged to
  /// calculate directions. Ensure that no space exists between
  /// the latitude and longitude values.
  ///
  ///   ```origin=41.43206,-81.38992```
  ///
  ///  * Place IDs must be prefixed with place_id:. The place ID
  /// may only be specified if the request includes an API key or
  /// a Google Maps Platform Premium Plan client ID. You can
  /// retrieve place IDs from the Geocoding API and the Places
  /// API (including Place Autocomplete). For an example using
  /// place IDs from Place Autocomplete, see
  /// [Place Autocomplete and Directions][place_info]. For more
  ///  place IDs, see the [Place ID overview][place_overview].
  ///
  ///   ```origin=place_id:ChIJ3S-JXmauEmsRUcIaWtf4MzE```
  ///
  /// [place_info]: https://developers.google.com/maps/documentation/javascript/examples/places-autocomplete-directions
  /// [place_overview]: https://developers.google.com/places/place-id
  final dynamic origin;

  /// The address, textual latitude/longitude value, or place ID
  /// to which you wish to calculate directions. The options for
  /// the destination parameter are the same as for the [origin]
  /// parameter, described above.
  ///
  /// This field is required.
  final dynamic destination;

  /// Specifies the mode of transport to use when calculating
  /// directions. Valid values and other request details are
  /// specified in [TravelModes].
  ///
  /// Default value is [TravelMode.driving]
  final TravelMode travelMode;

  /// If set to `true`, specifies that the Directions service may
  /// provide more than one route alternative in the response.
  /// Note that providing route alternatives may increase the
  /// response time from the server. This is only available for
  /// requests without intermediate waypoints.
  final bool alternatives;

  String _convertLocation(dynamic location) {
    if (location is LatLng) {
      return '${location.latitude},${location.longitude}';
    } else if (location is String && location.startsWith('place_id:')) {
      return location;
    } else if (location is String) {
      location = location.replaceAll(',', ' ');
      return location
          .split(' ')
          .where((_) => _.trim().isNotEmpty == true)
          .join('+');
    }

    throw UnsupportedError(
        'Unsupported type of argument: ${location.runtimeType}');
  }

  String _addIfNotNull(String name, dynamic value) =>
      value == null ? '' : '&$name=$value';

  /// Converts `this` object into query string parameters.
  String toParams() => '?origin=${_convertLocation(origin)}&'
      'destination=${_convertLocation(destination)}'
      '${_addIfNotNull('mode', travelMode)}'
      '${_addIfNotNull('alternatives', alternatives)}';
}
