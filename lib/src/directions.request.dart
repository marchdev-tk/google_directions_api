// Copyright (c) 2020, the MarchDev Toolkit project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'directions.dart';

String _addIfNotNull(String name, dynamic value) =>
    value == null ? '' : '&$name=$value';

String _convertLocation(dynamic location) {
  if (location is GeoCoord) {
    return '${location.latitude},${location.longitude}';
  } else if (location is String &&
      (location.startsWith('place_id:') || location.startsWith('enc:'))) {
    return location;
  } else if (location is String) {
    location = location.replaceAll(', ', ',');
    return location
        .split(' ')
        .where((_) => _.trim().isNotEmpty == true)
        .join('+');
  }

  throw UnsupportedError(
      'Unsupported type of argument: ${location.runtimeType}');
}

/// Settings for route calculation.
///
/// `origin` and `destination` arguments are required.
class DirectionsRequest {
  const DirectionsRequest({
    @required this.origin,
    @required this.destination,
    this.travelMode,
    this.optimizeWaypoints,
    this.waypoints,
    this.alternatives,
    this.avoidTolls,
    this.avoidHighways,
    this.avoidFerries,
    this.avoidIndoor,
    this.unitSystem,
    this.region,
    this.drivingOptions,
    this.transitOptions,
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

  /// Specifies an array of intermediate locations to include
  /// along the route between the origin and destination points
  /// as pass through or stopover locations. Waypoints alter a
  /// route by directing it through the specified location(s).
  /// The API supports waypoints for these travel modes: driving,
  /// walking and bicycling; not transit.
  ///
  /// You can specify waypoints using the following values:
  ///
  ///  * Latitude/longitude coordinates (`lat`/`lng`): an explicit value
  /// pair. (`-34.92788%2C138.60008` comma, no space)
  ///  * Place ID: The unique value specific to a location.
  ///  * Address string (`Charlestown, Boston,MA`)
  ///  * Encoded polyline that can be specified by a set of any of
  /// the above. (`enc:lexeF{~wsZejrPjtye@:`)
  final List<DirectionsWaypoint> waypoints;

  /// By default, the Directions service calculates a route through
  /// the provided waypoints in their given order.
  ///
  /// If set to `true` will allow the Directions service to optimize
  /// the provided route by rearranging the waypoints in a more
  /// efficient order. (This optimization is an application of the
  /// [traveling salesperson problem][tsp].) Travel time is the primary
  /// factor which is optimized, but other factors such as distance,
  /// number of turns and many more may be taken into account when
  /// deciding which route is the most efficient. All waypoints must
  /// be stopovers for the Directions service to optimize their route.
  ///
  /// If you instruct the Directions service to optimize the order of
  /// its waypoints, their order will be returned in the waypoint_order
  /// field within the [DirectionsRoute] object. The `waypointOrder`
  /// field returns values which are zero-based.
  ///
  /// [tsp]: https://en.wikipedia.org/wiki/Travelling_salesman_problem
  final bool optimizeWaypoints;

  /// If set to `true`, specifies that the Directions service may
  /// provide more than one route alternative in the response.
  /// Note that providing route alternatives may increase the
  /// response time from the server. This is only available for
  /// requests without intermediate waypoints.
  final bool alternatives;

  /// Indicates that the calculated route should avoid toll
  /// roads/bridges.
  final bool avoidTolls;

  /// Indicates that the calculated route should avoid highways.
  final bool avoidHighways;

  /// Indicates that the calculated route should avoid ferries.
  final bool avoidFerries;

  /// Indicates that the calculated route should avoid indoor
  /// steps for walking and transit directions.
  final bool avoidIndoor;

  /// Specifies the region code, specified as a ccTLD
  /// ("top-level domain") two-character value.
  ///
  /// You can set the Directions service to return results from
  /// a specific region by using the `region` parameter. This
  /// parameter takes a [ccTLD][cctld] (country code top-level domain)
  /// argument specifying the region bias. Most ccTLD codes are
  /// identical to ISO 3166-1 codes, with some notable exceptions.
  /// For example, the United Kingdom's ccTLD is "uk" (`.co.uk`)
  /// while its ISO 3166-1 code is "gb" (technically for the entity
  /// of "The United Kingdom of Great Britain and Northern Ireland").
  ///
  /// You may utilize any domain in which the main Google Maps
  /// application has launched driving directions.
  ///
  /// [cctld]: https://en.wikipedia.org/wiki/Country_code_top-level_domain
  final String region;

  /// Specifies the unit system to use when displaying results.
  final UnitSystem unitSystem;

  /// Specifies the desired time of departure and/or desired assumption
  /// of time in traffic calculation for `non-transit` [TravelMode].
  final DrivingOptions drivingOptions;

  /// Specifies the desired time of arrival/departure and/or desired
  /// transit types and/or desired routing preference for `transit`
  /// [TravelMode].
  final TransitOptions transitOptions;

  String _convertAvoids() {
    final avoids = <String>[];

    if (avoidTolls == true) {
      avoids.add('tolls');
    }
    if (avoidHighways == true) {
      avoids.add('highways');
    }
    if (avoidFerries == true) {
      avoids.add('ferries');
    }
    if (avoidIndoor == true) {
      avoids.add('indoor');
    }

    return avoids.isEmpty ? null : avoids.join('|');
  }

  String _convertWaypoints() {
    if (waypoints?.isEmpty != false) return null;

    return (optimizeWaypoints == true ? 'optimize:true|' : '') +
        waypoints.mapList((_) => _.toString()).join('|');
  }

  @override
  String toString() => '?origin=${_convertLocation(origin)}&'
      'destination=${_convertLocation(destination)}'
      '${_addIfNotNull('mode', travelMode)}'
      '${_addIfNotNull('waypoints', _convertWaypoints())}'
      '${_addIfNotNull('alternatives', alternatives)}'
      '${_addIfNotNull('avoid', _convertAvoids())}'
      '${_addIfNotNull('units', unitSystem)}'
      '${_addIfNotNull('region', region)}'
      '${drivingOptions == null ? '' : drivingOptions.toString()}'
      '${transitOptions == null ? '' : transitOptions.toString()}';
}

/// Specifies an intermediate location to include along the route
/// between the origin and destination points as pass through
/// or stopover location. Waypoints alter a route by directing it
/// through the specified location(s).
///
/// The API **supports** waypoints for these travel modes: `driving`,
/// `walking` and `bicycling`; `not transit`.
/// You can specify waypoints using the following values:
///
///  * `location` - specifies an intermediate location to include
/// along the route between the origin and destination points.
/// Waypoints alter a route by directing it through the specified
/// location(s).
///
/// You can specify waypoints using the following values:
///
///  * Latitude/longitude coordinates (`lat`/`lng`): an explicit value
/// pair. (`-34.92788%2C138.60008` comma, no space)
///  * Place ID: The unique value specific to a location.
///  * Address string (`Charlestown, Boston,MA`)
///  * Encoded polyline that can be specified
///
///  * `stopover` - influence routes with stopover and pass through
/// points For each waypoint in the request, the directions response
/// appends an entry to the `legs` array to provide the details
/// for stopovers on that leg of the journey.
///
/// If you'd like to influence the route using waypoints without
/// adding a stopover, prefix `via:` will be added to the waypoint.
/// Waypoints prefixed with via: will not add an entry to the
/// `legs` array, but will route the journey through the waypoint.
class DirectionsWaypoint {
  const DirectionsWaypoint({
    this.location,
    this.stopover = true,
  });

  /// Specifies an intermediate location to include along the route
  /// between the origin and destination points. Waypoints alter a
  /// route by directing it through the specified location(s).
  ///
  /// You can specify waypoints using the following values:
  ///
  ///  * Latitude/longitude coordinates (`lat`/`lng`): an explicit value
  /// pair. (`-34.92788,138.60008` comma or `%2C`, no space)
  ///  * Place ID: The unique value specific to a location.
  ///  * Address string (`Charlestown, Boston,MA`)
  ///  * Encoded polyline that can be specified by a set of any of
  /// the above. (`enc:lexeF{~wsZejrPjtye@:`)
  final dynamic location;

  /// Influence routes with stopover and pass through points
  /// For each waypoint in the request, the directions response
  /// appends an entry to the `legs` array to provide the details
  /// for stopovers on that leg of the journey.
  ///
  /// If you'd like to influence the route using waypoints without
  /// adding a stopover, prefix `via:` will be added to the waypoint.
  /// Waypoints prefixed with via: will not add an entry to the
  /// `legs` array, but will route the journey through the waypoint.
  final bool stopover;

  @override
  String toString() =>
      '${stopover == true ? '' : 'via:'}${_convertLocation(location)}';
}

/// Specifies the desired time of arrival/departure and/or desired
/// transit types and/or desired routing preference for `transit`
/// [TravelMode].
///
/// May contain the following fields:
///
///  * `arrivalTime` - specifies the desired time of arrival for
/// transit directions. You can specify either `departureTime` or
/// `arrivalTime`, but not both.
///
///
///  * `departureTime` - specifies the desired time of departure.
/// The departure time may be specified in two cases:
///
///   * For requests where the travel mode is `transit`: You can
/// optionally specify one of `departureTime` or `arrivalTime`.
/// If neither time is specified, the `departureTime` defaults to
/// now (that is, the departure time defaults to the current time).
///
///   * For requests where the travel mode is `driving`: You can
/// specify the `departureTime` to receive a route and trip
/// duration (response field: `durationInTraffic`) that take
/// traffic conditions into account. The `departureTime` must be
/// set to the current time or some time in the future. It
/// cannot be in the past.
///
///   Note: If departure time is not specified, choice of route and
/// duration are based on road network and average time-independent
/// traffic conditions. Results for a given request may vary over
/// time due to changes in the road network, updated average traffic
/// conditions, and the distributed nature of the service. Results
/// may also vary between nearly-equivalent routes at any time or
/// frequency.
///
///
///  * `mode` - specifies one or more preferred modes of transit.
/// This parameter may only be specified for transit directions. The
/// parameter supports the following arguments:
///
///   * `bus` indicates that the calculated route should prefer travel
/// by bus.
///   * `subway` indicates that the calculated route should prefer
/// travel by subway.
///   * `train` indicates that the calculated route should prefer
/// travel by train.
///   * `tram` indicates that the calculated route should prefer travel
/// by tram and light rail.
///   * `rail` indicates that the calculated route should prefer travel
/// by train, tram, light rail, and subway. This is equivalent to
/// `transitMode=train|tram|subway`.
///
///
///  * `routingPreference` - specifies preferences for transit routes.
/// Using this parameter, you can bias the options returned, rather than
/// accepting the default best route chosen by the API. This parameter
/// may only be specified for transit directions. The parameter supports
/// the following arguments:
///
///   * `lessWalking` indicates that the calculated route should
/// prefer limited amounts of walking.
///   * `fewerTransfers` indicates that the calculated route should
/// prefer a limited number of transfers.
class TransitOptions {
  const TransitOptions({
    this.arrivalTime,
    this.departureTime,
    this.modes,
    this.routingPreference,
  });

  /// Specifies the desired time of arrival for transit directions.
  /// You can specify either `departureTime` or `arrivalTime`, but
  /// not both.
  final DateTime arrivalTime;

  /// Specifies the desired time of departure. The departure time
  /// may be specified in two cases:
  ///
  ///  * For requests where the travel mode is `transit`: You can
  /// optionally specify one of `departureTime` or `arrivalTime`.
  /// If neither time is specified, the `departureTime` defaults to
  /// now (that is, the departure time defaults to the current time).
  ///
  ///  * For requests where the travel mode is `driving`: You can
  /// specify the `departureTime` to receive a route and trip
  /// duration (response field: `durationInTraffic`) that take
  /// traffic conditions into account. The `departureTime` must be
  /// set to the current time or some time in the future. It
  /// cannot be in the past.
  ///
  /// Note: If departure time is not specified, choice of route and
  /// duration are based on road network and average time-independent
  /// traffic conditions. Results for a given request may vary over
  /// time due to changes in the road network, updated average traffic
  /// conditions, and the distributed nature of the service. Results
  /// may also vary between nearly-equivalent routes at any time or
  /// frequency.
  final DateTime departureTime;

  /// Specifies one or more preferred modes of transit. This parameter
  /// may only be specified for transit directions. The parameter
  /// supports the following arguments:
  ///
  ///  * `bus` indicates that the calculated route should prefer travel
  /// by bus.
  ///  * `subway` indicates that the calculated route should prefer
  /// travel by subway.
  ///  * `train` indicates that the calculated route should prefer
  /// travel by train.
  ///  * `tram` indicates that the calculated route should prefer travel
  /// by tram and light rail.
  ///  * `rail` indicates that the calculated route should prefer travel
  /// by train, tram, light rail, and subway. This is equivalent to
  /// `transitMode=train|tram|subway`.
  final List<TransitMode> modes;

  /// Specifies preferences for transit routes. Using this parameter,
  /// you can bias the options returned, rather than accepting the
  /// default best route chosen by the API. This parameter may only
  /// be specified for transit directions. The parameter supports the
  /// following arguments:
  ///
  ///  * `lessWalking` indicates that the calculated route should
  /// prefer limited amounts of walking.
  ///  * `fewerTransfers` indicates that the calculated route should
  /// prefer a limited number of transfers.
  final TransitRoutingPreference routingPreference;

  @override
  String toString() =>
      '${_addIfNotNull('arrival_time', arrivalTime.millisecondsSinceEpoch)}'
      '${_addIfNotNull('departure_time', departureTime.millisecondsSinceEpoch)}'
      '${_addIfNotNull('transit_mode', modes.map((_) => _.toString()).join('|'))}'
      '${_addIfNotNull('transit_routing_preference', routingPreference)}';
}

/// Specifies the desired time of departure and/or desired assumption
/// of time in traffic calculation for `non-transit` [TravelMode].
///
/// May contain the following fields:
///
///  * `departureTime` - specifies the desired time of departure.
/// The departure time may be specified in two cases:
///
///   * For requests where the travel mode is `transit`: You can
/// optionally specify one of `departureTime` or `arrivalTime`.
/// If neither time is specified, the `departureTime` defaults to
/// now (that is, the departure time defaults to the current time).
///
///   * For requests where the travel mode is `driving`: You can
/// specify the `departureTime` to receive a route and trip
/// duration (response field: `durationInTraffic`) that take
/// traffic conditions into account. The `departureTime` must be
/// set to the current time or some time in the future. It
/// cannot be in the past.
///
///   Note: If departure time is not specified, choice of route and
/// duration are based on road network and average time-independent
/// traffic conditions. Results for a given request may vary over
/// time due to changes in the road network, updated average traffic
/// conditions, and the distributed nature of the service. Results
/// may also vary between nearly-equivalent routes at any time or
/// frequency.
///
///
///  * `trafficModel` - specifies the assumptions to use when calculating
/// time in traffic. This setting affects the value returned in the
/// `durationInTraffic` field in the response, which contains the predicted
/// time in traffic based on historical averages. The `trafficModel`
/// parameter may only be specified for driving directions where
/// the request includes a `departureTime`.
///
///   The available values for this parameter are:
///
///   * `bestGuess` (default) indicates that the returned `durationInTraffic`
/// should be the best estimate of travel time given what is known about
/// both historical traffic conditions and live traffic. Live traffic
/// becomes more important the closer the `departureTime` is to now.
///   * `pessimistic` indicates that the returned `durationInTraffic`
/// should be longer than the actual travel time on most days, though
/// occasional days with particularly bad traffic conditions may
/// exceedthis value.
///   * `optimistic` indicates that the returned `durationInTraffic`
/// should be shorter than the actual travel time on most days, though
/// occasional days with particularly good traffic conditions may be
/// faster than this value.
///
///   The default value of `bestGuess` will give the most useful
/// predictions for the vast majority of use cases. It is possible
/// the `bestGuess` travel time prediction may be shorter than
/// `optimistic`, or alternatively, longer than `pessimistic`, due to
/// the way the `bestGuess` prediction model integrates live traffic
/// information.
class DrivingOptions {
  const DrivingOptions({
    this.departureTime,
    this.trafficModel,
  });

  /// Specifies the desired time of departure. The departure time
  /// may be specified in two cases:
  ///
  ///  * For requests where the travel mode is `transit`: You can
  /// optionally specify one of `departureTime` or `arrivalTime`.
  /// If neither time is specified, the `departureTime` defaults to
  /// now (that is, the departure time defaults to the current time).
  ///
  ///  * For requests where the travel mode is `driving`: You can
  /// specify the `departureTime` to receive a route and trip
  /// duration (response field: `durationInTraffic`) that take
  /// traffic conditions into account. The `departureTime` must be
  /// set to the current time or some time in the future. It
  /// cannot be in the past.
  ///
  /// Note: If departure time is not specified, choice of route and
  /// duration are based on road network and average time-independent
  /// traffic conditions. Results for a given request may vary over
  /// time due to changes in the road network, updated average traffic
  /// conditions, and the distributed nature of the service. Results
  /// may also vary between nearly-equivalent routes at any time or
  /// frequency.
  final DateTime departureTime;

  /// Specifies the assumptions to use when calculating time in traffic.
  /// This setting affects the value returned in the `durationInTraffic`
  /// field in the response, which contains the predicted time in
  /// traffic based on historical averages. The `trafficModel`
  /// parameter may only be specified for driving directions where
  /// the request includes a `departureTime`.
  ///
  /// Defaults to `bestGuess`.
  ///
  /// The available values for this parameter are:
  ///
  ///  * `bestGuess` (default) indicates that the returned `durationInTraffic`
  /// should be the best estimate of travel time given what is known about
  /// both historical traffic conditions and live traffic. Live traffic
  /// becomes more important the closer the `departureTime` is to now.
  ///  * `pessimistic` indicates that the returned `durationInTraffic`
  /// should be longer than the actual travel time on most days, though
  /// occasional days with particularly bad traffic conditions may
  /// exceedthis value.
  ///  * `optimistic` indicates that the returned `durationInTraffic`
  /// should be shorter than the actual travel time on most days, though
  /// occasional days with particularly good traffic conditions may be
  /// faster than this value.
  ///
  /// The default value of `bestGuess` will give the most useful
  /// predictions for the vast majority of use cases. It is possible
  /// the `bestGuess` travel time prediction may be shorter than
  /// `optimistic`, or alternatively, longer than `pessimistic`, due to
  /// the way the `bestGuess` prediction model integrates live traffic
  /// information.
  final TrafficModel trafficModel;

  @override
  String toString() =>
      '${_addIfNotNull('departure_time', departureTime.millisecondsSinceEpoch)}'
      '${_addIfNotNull('traffic_model', trafficModel)}';
}

/// Directions results contain `text` within `distance` fields
/// that may be displayed to the user to indicate the distance
/// of a particular "step" of the route. By default, this text
/// uses the unit system of the origin's country or region.
///
/// For example, a route from "Chicago, IL" to "Toronto, ONT"
/// will display results in miles, while the reverse route will
/// display results in kilometers. You may override this unit
/// system by setting one explicitly within the request's units
/// parameter, passing one of the following values:
///
/// `metric` specifies usage of the metric system. Textual
/// distances are returned using kilometers and meters.
/// `imperial` specifies usage of the Imperial (English)
/// system. Textual distances are returned using miles and feet.
///
/// Note: this unit system setting only affects the text displayed
/// within distance fields. The distance fields also contain values
/// which are always expressed in meters.
class UnitSystem {
  const UnitSystem(this._name);

  final String _name;

  static final values = <UnitSystem>[imperial, metric];

  /// Specifies usage of the metric system. Textual distances are
  /// returned using kilometers and meters.
  static const imperial = UnitSystem('IMPERIAL');

  /// Specifies usage of the Imperial (English) system. Textual
  /// distances are returned using miles and feet.
  static const metric = UnitSystem('METRIC');

  @override
  String toString() => '$_name';
}

/// Specifies one or more preferred modes of transit. This parameter
/// may only be specified for transit directions. The parameter
/// supports the following arguments:
///
///  * `bus` indicates that the calculated route should prefer travel
/// by bus.
///  * `subway` indicates that the calculated route should prefer
/// travel by subway.
///  * `train` indicates that the calculated route should prefer
/// travel by train.
///  * `tram` indicates that the calculated route should prefer travel
/// by tram and light rail.
///  * `rail` indicates that the calculated route should prefer travel
/// by train, tram, light rail, and subway. This is equivalent to
/// `transitMode=train|tram|subway`.
class TransitMode {
  const TransitMode(this._name);

  final String _name;

  static final values = <TransitMode>[
    bus,
    subway,
    train,
    tram,
    rail,
  ];

  /// Indicates that the calculated route should prefer travel
  /// by bus.
  static const bus = TransitMode('BUS');

  /// Indicates that the calculated route should prefer travel
  /// by bus.
  static const subway = TransitMode('SUBWAY');

  /// Indicates that the calculated route should prefer travel
  /// by bus.
  static const train = TransitMode('TRAIN');

  /// Indicates that the calculated route should prefer travel
  /// by bus.
  static const tram = TransitMode('TRAM');

  /// Indicates that the calculated route should prefer travel
  /// by bus.
  static const rail = TransitMode('RAIL');

  @override
  String toString() => '$_name';
}

/// Specifies preferences for transit routes. Using this parameter,
/// you can bias the options returned, rather than accepting the
/// default best route chosen by the API. This parameter may only
/// be specified for transit directions. The parameter supports the
/// following arguments:
///
///  * `lessWalking` indicates that the calculated route should
/// prefer limited amounts of walking.
///  * `fewerTransfers` indicates that the calculated route should
/// prefer a limited number of transfers.
class TransitRoutingPreference {
  const TransitRoutingPreference(this._name);

  final String _name;

  static final values = <TransitRoutingPreference>[lessWalking, fewerTransfers];

  /// Indicates that the calculated route should prefer limited
  /// amounts of walking.
  static const lessWalking = TransitRoutingPreference('less_walking');

  /// Indicates that the calculated route should prefer a limited
  /// number of transfers
  static const fewerTransfers = TransitRoutingPreference('fewer_transfers');

  @override
  String toString() => '$_name';
}

/// Specifies the assumptions to use when calculating time in traffic.
/// This setting affects the value returned in the `durationInTraffic`
/// field in the response, which contains the predicted time in
/// traffic based on historical averages. The `trafficModel`
/// parameter may only be specified for driving directions where
/// the request includes a `departureTime`.
///
/// The available values for this parameter are:
///
///  * `bestGuess` indicates that the returned `durationInTraffic`
/// should be the best estimate of travel time given what is known about
/// both historical traffic conditions and live traffic. Live traffic
/// becomes more important the closer the `departureTime` is to now.
///  * `pessimistic` indicates that the returned `durationInTraffic`
/// should be longer than the actual travel time on most days, though
/// occasional days with particularly bad traffic conditions may
/// exceedthis value.
///  * `optimistic` indicates that the returned `durationInTraffic`
/// should be shorter than the actual travel time on most days, though
/// occasional days with particularly good traffic conditions may be
/// faster than this value.
class TrafficModel {
  const TrafficModel(this._name);

  final String _name;

  static final values = <TrafficModel>[
    bestGuess,
    pessimistic,
  ];

  /// Indicates that the returned `durationInTraffic`
  /// should be the best estimate of travel time given what is known about
  /// both historical traffic conditions and live traffic. Live traffic
  /// becomes more important the closer the `departureTime` is to now.
  static const bestGuess = TrafficModel('best_guess');

  /// Indicates that the returned `durationInTraffic`
  /// should be longer than the actual travel time on most days, though
  /// occasional days with particularly bad traffic conditions may
  /// exceedthis value.
  static const pessimistic = TrafficModel('pessimistic');

  /// Indicates that the returned `durationInTraffic`
  /// should be shorter than the actual travel time on most days, though
  /// occasional days with particularly good traffic conditions may be
  /// faster than this value.
  static const optimistic = TrafficModel('optimistic');

  @override
  String toString() => '$_name';
}
