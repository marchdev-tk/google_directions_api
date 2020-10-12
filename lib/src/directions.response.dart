// Copyright (c) 2020, the MarchDev Toolkit project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'directions.dart';

GeoCoord _getGeoCoordFromMap(Map<String, dynamic> map) => map == null
    ? null
    : GeoCoord(
        double.tryParse(map['lat']?.toString()),
        double.tryParse(map['lng']?.toString()),
      );

/// Directions responses contain the following root elements:
///
///  * `status` contains metadata on the request. See [DirectionsStatus].
///  * `geocodedWaypoints` contains an array with details about the
/// geocoding of origin, destination and waypoints. See
/// [GeocodedWaypoint].
///  * `routes` contains an array of routes from the origin to the
/// destination. See [DirectionsRoute]. Routes consist of nested Legs
/// and Steps.
///  * `availableTravelModes` contains an array of available travel modes.
/// This field is returned when a request specifies a travel mode and
/// gets no results. The array contains the available travel modes in
/// the countries of the given set of waypoints. This field is not
/// returned if one or more of the waypoints are via: waypoints.
///
///  * `errorMessages` contains more detailed information about the reasons
/// behind the given status code.
class DirectionsResult {
  const DirectionsResult({
    this.routes,
    this.geocodedWaypoints,
    this.status,
    this.errorMessage,
    this.availableTravelModes,
  });

  factory DirectionsResult.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : DirectionsResult(
          routes: (map['routes'] as List)
              ?.mapList((_) => DirectionsRoute.fromMap(_)),
          geocodedWaypoints:
              (map[''] as List)?.mapList((_) => GeocodedWaypoint.fromMap(_)),
          status: DirectionsStatus(map['status']),
          errorMessage: map['error_message'] as String,
          availableTravelModes: (map['available_travel_modes'] as List)
              ?.mapList((_) => TravelMode(_)));

  /// When the Directions API returns results, it places them within a
  /// (JSON) routes array. Even if the service returns no results (such
  /// as if the origin and/or destination doesn't exist) it still
  /// returns an empty routes array. (XML responses consist of zero or
  /// more <route> elements.)
  ///
  /// Each element of the routes array contains a single result from
  /// the specified origin and destination. This route may consist of
  /// one or more legs depending on whether any waypoints were specified.
  /// As well, the route also contains copyright and warning information
  /// which must be displayed to the user in addition to the routing
  /// information.
  final List<DirectionsRoute> routes;

  /// Details about the geocoding of every waypoint, as well as origin
  /// and destination, can be found in the (JSON) geocoded_waypoints
  /// array. These can be used to infer why the service would return
  /// unexpected or no routes.
  ///
  /// Elements in the geocoded_waypoints array correspond, by their
  /// zero-based position, to the origin, the waypoints in the order
  /// they are specified, and the destination.
  final List<GeocodedWaypoint> geocodedWaypoints;

  /// The status field within the Directions response object contains
  /// the status of the request, and may contain debugging information
  /// to help you track down why the Directions service failed. The
  /// status field may contain the following values:
  ///  * [DirectionsStatus.ok] indicates the response contains a valid
  /// result.
  ///  * [DirectionsStatus.notFound] indicates at least one of the
  /// locations specified in the request's origin, destination, or
  /// waypoints could not be geocoded.
  ///  * [DirectionsStatus.zeroResults] indicates no route could be
  /// found between the origin and destination.
  ///  * [DirectionsStatus.maxWaypointExceeded] indicates that too
  /// many waypoints were provided in the request. For applications
  /// using the Directions API as a web service, or the [directions
  /// service in the Maps JavaScript API][maps_js_api], the maximum
  /// allowed number of waypoints is 25, plus the origin and destination.
  ///  * [DirectionsStatus.maxRouteLengthExceeded] indicates the
  /// requested route is too long and cannot be processed. This error
  /// occurs when more complex directions are returned. Try reducing
  /// the number of waypoints, turns, or instructions.
  ///  * [DirectionsStatus.invalidRequest] indicates that the provided
  /// request was invalid. Common causes of this status include an
  /// invalid parameter or parameter value.
  ///  * [DirectionsStatus.overDailyLimit] indicates any of the following:
  ///     * The API key is missing or invalid.
  ///     * Billing has not been enabled on your account.
  ///     * A self-imposed usage cap has been exceeded.
  ///     * The provided method of payment is no longer valid (for example,
  /// a credit card has expired).
  ///     * See the [Maps FAQ][faq] to learn how to fix this.
  ///  * [DirectionsStatus.overQueryLimit] indicates the service has
  /// received too many requests from your application within the
  /// allowed time period.
  ///  * [DirectionsStatus.requestDenied] indicates that the service
  /// denied use of the directions service by your application.
  ///  * [DirectionsStatus.unknownError] indicates a directions request
  /// could not be processed due to a server error. The request may
  /// succeed if you try again.
  ///
  /// [faq]: https://developers.google.com/maps/faq#over-limit-key-error
  /// [maps_js_api]: https://developers.google.com/maps/documentation/javascript/directions
  final DirectionsStatus status;

  /// When the status code is other than OK, there may be an additional
  /// `errorMessage` field within the Directions response object. This
  /// field contains more detailed information about the reasons behind
  /// the given status code.
  final String errorMessage;

  /// Contains an array of available travel modes. This field is returned
  /// when a request specifies a travel mode and gets no results. The array
  /// contains the available travel modes in the countries of the given set
  /// of waypoints. This field is not returned if one or more of the
  /// waypoints are via: waypoints. See details below.
  final List<TravelMode> availableTravelModes;
}

/// When the Directions API returns results, it places them within a
/// (JSON) routes array. Even if the service returns no results (such
/// as if the origin and/or destination doesn't exist) it still
/// returns an empty routes array. (XML responses consist of zero or
/// more <route> elements.)
///
/// Each element of the routes array contains a single result from
/// the specified origin and destination. This route may consist of
/// one or more legs depending on whether any waypoints were specified.
/// As well, the route also contains copyright and warning information
/// which must be displayed to the user in addition to the routing
/// information.
///
/// Each route within the routes field may contain the following fields:
///
///  * `summary` contains a short textual description for the route,
/// suitable for naming and disambiguating the route from alternatives.
///  * `legs` contains an array which contains information about a
/// leg of the route, between two locations within the given route.
/// A separate leg will be present for each waypoint or destination
/// specified. (A route with no waypoints will contain exactly one
/// leg within the legs array.) Each leg consists of a series of
/// steps. (See [Leg].)
///  * `waypointOrder` contains an array indicating the order of any
/// waypoints in the calculated route. This waypoints may be reordered
/// if the request was passed optimize:true within its waypoints parameter.
///  * `overviewPolyline` contains a single points object that holds
/// an [encoded polyline][enc_polyline] representation of the route.
/// This polyline is an approximate (smoothed) path of the resulting
/// directions.
///  * `bounds` contains the viewport bounding box of the
/// [overviewPolyline].
///  * `copyrights` contains the copyrights text to be displayed for
/// this route. You must handle and display this information yourself.
///  * `warnings` contains an array of warnings to be displayed when
/// showing these directions. You must handle and display these
/// warnings yourself.
///  * `fare`: If present, contains the total fare (that is, the total
/// ticket costs) on this route. This property is only returned for
/// transit requests and only for routes where fare information is
/// available for all transit legs. The information includes:
///   * `currency`: An [ISO 4217 currency code][iso4217] indicating the
/// currency that the amount is expressed in.
///   * `value`: The total fare amount, in the currency specified above.
///   * `text`: The total fare amount, formatted in the requested language.
///
/// **Note**: The Directions API only returns fare information for
/// requests that contain either an API key or a client ID and digital
/// signature.
///
/// [enc_polyline]: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
/// [iso4217]: https://en.wikipedia.org/wiki/ISO_4217
class DirectionsRoute {
  const DirectionsRoute({
    this.bounds,
    this.copyrights,
    this.legs,
    this.overviewPolyline,
    this.summary,
    this.warnings,
    this.waypointOrder,
    this.fare,
  });

  factory DirectionsRoute.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : DirectionsRoute(
          bounds: GeoCoordBounds(
            northeast: _getGeoCoordFromMap(map['bounds']['northeast']),
            southwest: _getGeoCoordFromMap(map['bounds']['southwest']),
          ),
          copyrights: map['copyrights'] as String,
          legs: (map['legs'] as List)?.mapList((_) => Leg.fromMap(_)),
          overviewPolyline: OverviewPolyline.fromMap(map['overview_polyline']),
          summary: map['summary'] as String,
          warnings: (map['warnings'] as List)?.mapList((_) => _ as String),
          waypointOrder: (map['waypointOrder'] as List)
              ?.mapList((_) => num.tryParse(_?.toString())),
          fare: Fare.fromMap(map['fare']),
        );

  /// Contains the viewport bounding box of the [overviewPolyline].
  final GeoCoordBounds bounds;

  /// Contains the copyrights text to be displayed for this route.
  /// You must handle and display this information yourself.
  final String copyrights;

  /// Contains an array which contains information about a
  /// leg of the route, between two locations within the given route.
  /// A separate leg will be present for each waypoint or destination
  /// specified. (A route with no waypoints will contain exactly one
  /// leg within the legs array.) Each leg consists of a series of
  /// steps. (See [Leg].)
  final List<Leg> legs;

  List<GeoCoord> get overviewPath =>
      overviewPolyline?.points?.isNotEmpty == true
          ? gpl
              .decodePolyline(overviewPolyline.points)
              .mapList((_) => GeoCoord._fromList(_))
          : null;

  /// Contains a single points object that holds an
  /// [encoded polyline][enc_polyline] representation of the route.
  /// This polyline is an approximate (smoothed) path of the resulting
  /// directions.
  ///
  /// [enc_polyline]: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  final OverviewPolyline overviewPolyline;

  /// Contains a short textual description for the route, suitable for
  /// naming and disambiguating the route from alternatives.
  final String summary;

  /// Contains an array of warnings to be displayed when showing these
  /// directions. You must handle and display these warnings yourself.
  final List<String> warnings;

  /// Contains an array indicating the order of any waypoints in the
  /// calculated route. This waypoints may be reordered if the request
  /// was passed `optimize:true` within its waypoints parameter.
  final List<num> waypointOrder;

  /// Contains the total fare (that is, the total
  /// ticket costs) on this route. This property is only returned for
  /// transit requests and only for routes where fare information is
  /// available for all transit legs. The information includes:
  ///   * `currency`: An [ISO 4217 currency code][iso4217] indicating the
  /// currency that the amount is expressed in.
  ///   * `value`: The total fare amount, in the currency specified above.
  ///   * `text`: The total fare amount, formatted in the requested language.
  ///
  /// [iso4217]: https://en.wikipedia.org/wiki/ISO_4217
  final Fare fare;
}

/// Details about the geocoding of every waypoint, as well as origin
/// and destination, can be found in the (JSON) geocoded_waypoints
/// array. These can be used to infer why the service would return
/// unexpected or no routes.
///
/// Elements in the geocoded_waypoints array correspond, by their
/// zero-based position, to the origin, the waypoints in the order
/// they are specified, and the destination. Each element includes
/// the following details about the geocoding operation for the
/// corresponding waypoint:
///
/// [geocoderStatus] indicates the status code resulting from the
/// geocoding operation. This field may contain the following values.
///  * "OK" indicates that no errors occurred; the address was
/// successfully parsed and at least one geocode was returned.
///  * "ZERO_RESULTS" indicates that the geocode was successful
/// but returned no results. This may occur if the geocoder was
/// passed a non-existent address.
///
/// [partialMatch] indicates that the geocoder did not return an
/// exact match for the original request, though it was able to
/// match part of the requested address. You may wish to examine
/// the original request for misspellings and/or an incomplete
/// address.
///
/// Partial matches most often occur for street addresses
/// that do not exist within the locality you pass in the
/// request. Partial matches may also be returned when a
/// request matches two or more locations in the same locality.
/// For example, "21 Henr St, Bristol, UK" will return a
/// partial match for both Henry Street and Henrietta Street.
/// Note that if a request includes a misspelled address
/// component, the geocoding service may suggest an alternative
/// address. Suggestions triggered in this way will also be
/// marked as a partial match.
///
/// [placeId] is a unique identifier that can be used with other
/// Google APIs. For example, you can use the place_id from a
/// [Google Place Autocomplete response][autocomplete_response]
/// to calculate directions to a local business. See the
/// [Place ID overview][place_id_overview].
///
/// [autocomplete_response]: https://developers.google.com/places/web-service/autocomplete#place_autocomplete_responses
/// [place_id_overview]: https://developers.google.com/places/place-id
///
/// [types] indicates the address type of the geocoding result
/// used for calculating directions. The following types are
/// returned:
///  * [street_address] indicates a precise street address.
///  * [route] indicates a named route (such as "US 101").
///  * [intersection] indicates a major intersection, usually
/// of two major roads.
///  * [political] indicates a political entity. Usually, this
/// type indicates a polygon of some civil administration.
///  * [country] indicates the national political entity, and
/// is typically the highest order type returned by the Geocoder.
///  * [administrative_area_level_1] indicates a first-order
/// civil entity below the country level. Within the United
/// States, these administrative levels are states. Not all
/// nations exhibit these administrative levels. In most cases,
/// administrative_area_level_1 short names will closely match
/// ISO 3166-2 subdivisions and other widely circulated lists;
/// however this is not guaranteed as our geocoding results are
/// based on a variety of signals and location data.
///  * [administrative_area_level_2] indicates a second-order
/// civil entity below the country level. Within the United
/// States, these administrative levels are counties. Not all
/// nations exhibit these administrative levels.
///  * [administrative_area_level_3] indicates a third-order
/// civil entity below the country level. This type indicates
/// a minor civil division. Not all nations exhibit these
/// administrative levels.
///  * [administrative_area_level_4] indicates a fourth-order
/// civil entity below the country level. This type indicates
/// a minor civil division. Not all nations exhibit these
/// administrative levels.
///  * [administrative_area_level_5] indicates a fifth-order
/// civil entity below the country level. This type indicates
/// a minor civil division. Not all nations exhibit these
/// administrative levels.
///  * [colloquial_area] indicates a commonly-used alternative
/// name for the entity.
///  * [locality] indicates an incorporated city or town
/// political entity.
///  * [sublocality] indicates a first-order civil entity below
/// a locality. For some locations may receive one of the
/// additional types: sublocality_level_1 to sublocality_level_5.
/// Each sublocality level is a civil entity. Larger numbers
/// indicate a smaller geographic area.
///  * [neighborhood] indicates a named neighborhood
///  * [premise] indicates a named location, usually a building
/// or collection of buildings with a common name
///  * [subpremise] indicates a first-order entity below a named
/// location, usually a singular building within a collection of
/// buildings with a common name
///  * [postal_code] indicates a postal code as used to address
/// postal mail within the country.
///  * [natural_feature] indicates a prominent natural feature.
///  * [airport] indicates an airport.
///  * [park] indicates a named park.
///  * [point_of_interest] indicates a named point of interest.
/// Typically, these "POI"s are prominent local entities that don't
/// easily fit in another category, such as "Empire State Building"
/// or "Eiffel Tower".
///
/// An empty list of types indicates there are no known types for
/// the particular address component, for example, Lieu-dit in
/// France.
class GeocodedWaypoint {
  const GeocodedWaypoint({
    this.geocoderStatus,
    this.partialMatch,
    this.placeId,
    this.types,
  });

  factory GeocodedWaypoint.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : GeocodedWaypoint(
          geocoderStatus: map['geocoder_status'] as String,
          partialMatch: map['partial_match'] == 'true',
          placeId: map['place_id'] as String,
          types: (map['types'] as List)?.mapList((_) => _ as String),
        );

  /// Indicates the status code resulting from the geocoding
  /// operation. This field may contain the following values.
  ///  * "OK" indicates that no errors occurred; the address was
  /// successfully parsed and at least one geocode was returned.
  ///  * "ZERO_RESULTS" indicates that the geocode was successful
  /// but returned no results. This may occur if the geocoder was
  /// passed a non-existent address.
  final String geocoderStatus;

  /// Indicates that the geocoder did not return an exact match
  /// for the original request, though it was able to match part
  /// of the requested address. You may wish to examine the
  /// original request for misspellings and/or an incomplete
  /// address.
  ///
  /// Partial matches most often occur for street addresses
  /// that do not exist within the locality you pass in the
  /// request. Partial matches may also be returned when a
  /// request matches two or more locations in the same locality.
  /// For example, "21 Henr St, Bristol, UK" will return a
  /// partial match for both Henry Street and Henrietta Street.
  /// Note that if a request includes a misspelled address
  /// component, the geocoding service may suggest an alternative
  /// address. Suggestions triggered in this way will also be
  /// marked as a partial match.
  final bool partialMatch;

  /// Is a unique identifier that can be used with other
  /// Google APIs. For example, you can use the place_id from a
  /// [Google Place Autocomplete response][autocomplete_response]
  /// to calculate directions to a local business. See the
  /// [Place ID overview][place_id_overview].
  ///
  /// [autocomplete_response]: https://developers.google.com/places/web-service/autocomplete#place_autocomplete_responses
  /// [place_id_overview]: https://developers.google.com/places/place-id
  final String placeId;

  /// Indicates the address type of the geocoding result
  /// used for calculating directions. The following types are
  /// returned:
  ///  * [street_address] indicates a precise street address.
  ///  * [route] indicates a named route (such as "US 101").
  ///  * [intersection] indicates a major intersection, usually
  /// of two major roads.
  ///  * [political] indicates a political entity. Usually, this
  /// type indicates a polygon of some civil administration.
  ///  * [country] indicates the national political entity, and
  /// is typically the highest order type returned by the Geocoder.
  ///  * [administrative_area_level_1] indicates a first-order
  /// civil entity below the country level. Within the United
  /// States, these administrative levels are states. Not all
  /// nations exhibit these administrative levels. In most cases,
  /// administrative_area_level_1 short names will closely match
  /// ISO 3166-2 subdivisions and other widely circulated lists;
  /// however this is not guaranteed as our geocoding results are
  /// based on a variety of signals and location data.
  ///  * [administrative_area_level_2] indicates a second-order
  /// civil entity below the country level. Within the United
  /// States, these administrative levels are counties. Not all
  /// nations exhibit these administrative levels.
  ///  * [administrative_area_level_3] indicates a third-order
  /// civil entity below the country level. This type indicates
  /// a minor civil division. Not all nations exhibit these
  /// administrative levels.
  ///  * [administrative_area_level_4] indicates a fourth-order
  /// civil entity below the country level. This type indicates
  /// a minor civil division. Not all nations exhibit these
  /// administrative levels.
  ///  * [administrative_area_level_5] indicates a fifth-order
  /// civil entity below the country level. This type indicates
  /// a minor civil division. Not all nations exhibit these
  /// administrative levels.
  ///  * [colloquial_area] indicates a commonly-used alternative
  /// name for the entity.
  ///  * [locality] indicates an incorporated city or town
  /// political entity.
  ///  * [sublocality] indicates a first-order civil entity below
  /// a locality. For some locations may receive one of the
  /// additional types: sublocality_level_1 to sublocality_level_5.
  /// Each sublocality level is a civil entity. Larger numbers
  /// indicate a smaller geographic area.
  ///  * [neighborhood] indicates a named neighborhood
  ///  * [premise] indicates a named location, usually a building
  /// or collection of buildings with a common name
  ///  * [subpremise] indicates a first-order entity below a named
  /// location, usually a singular building within a collection of
  /// buildings with a common name
  ///  * [postal_code] indicates a postal code as used to address
  /// postal mail within the country.
  ///  * [natural_feature] indicates a prominent natural feature.
  ///  * [airport] indicates an airport.
  ///  * [park] indicates a named park.
  ///  * [point_of_interest] indicates a named point of interest.
  /// Typically, these "POI"s are prominent local entities that don't
  /// easily fit in another category, such as "Empire State Building"
  /// or "Eiffel Tower".
  ///
  /// An empty list of types indicates there are no known types for
  /// the particular address component, for example, Lieu-dit in
  /// France.
  final List<String> types;
}

/// Each element in the legs array specifies a single leg of the
/// journey from the origin to the destination in the calculated
/// route. For routes that contain no waypoints, the route will
/// consist of a single "leg," but for routes that define one or
/// more waypoints, the route will consist of one or more legs,
/// corresponding to the specific legs of the journey.
///
/// Each leg within the legs field(s) may contain the following
/// fields:
///
///  * `steps` contains an array of steps denoting information
/// about each separate step of the leg of the journey.
/// (See [Step])
///
///  * `distance` indicates the total distance covered by this
/// leg, as a field with the following elements:
///   * `value` indicates the distance in meters
///   * `text` contains a human-readable representation of the
/// distance, displayed in units as used at the origin (or as
/// overridden within the `units` parameter in the request).
/// (For example, miles and feet will be used for any origin
/// within the United States.) Note that regardless of what
/// unit system is displayed as text, the `distance.value`
/// field always contains a value expressed in meters.
///
///   These fields may be absent if the distance is unknown.
///
///
///  * `duration` indicates the total duration of this leg,
/// as a field with the following elements:
///   * `value` indicates the duration in seconds.
///   * `text` contains a human-readable representation of the
/// duration.
///
///   These fields may be absent if the duration is unknown.
///
///
///  * `durationInTraffic` indicates the total duration of this
/// leg. This value is an estimate of the time in traffic based on
/// current and historical traffic conditions. See the `trafficModel`
/// request parameter for the options you can use to request that
/// the returned value is optimistic, pessimistic, or a best-guess
/// estimate. The duration in traffic is returned only if all of
/// the following are true:
///
///   * The request includes a valid API key, or a valid Google Maps
///   * Platform Premium Plan client ID and signature.
///   * The request does not include stopover waypoints. If the
/// request includes waypoints, they must be prefixed with `via:`
/// to avoid stopovers.
///   * The request is specifically for driving directions—the
/// `mode` parameter is set to `driving`.
///   * The request includes a `departureTime` parameter.
///   * Traffic conditions are available for the requested route.
///
///   The `durationInTraffic` contains the following fields:
///   * `value` indicates the duration in seconds.
///   * `text` contains a human-readable representation of the duration.
///
///  * `arrivalTime` contains the estimated time of arrival for this
/// leg. This property is only returned for transit directions. The
/// result is returned as a [Time] object with three properties:
///   * `value` the time specified as a [DateTime] object.
///   * `text` the time specified as a [String]. The time is displayed
/// in the time zone of the transit stop.
///   * `timeZone` contains the time zone of this station. The value
/// is the name of the time zone as defined in the [IANA Time Zone
/// Database][iana], e.g. `"America/New_York"`.
///
///  * `departureTime` contains the estimated time of departure for
/// this leg, specified as a [Time] object. The departureTime
/// is only available for transit directions.
///
///  * `startLocation` contains the latitude/longitude coordinates
/// of the origin of this leg. Because the Directions API calculates
/// directions between locations by using the nearest transportation
/// option (usually a road) at the start and end points,
/// `startLocation` may be different than the provided origin of this
/// leg if, for example, a road is not near the origin.
///
///  * `endLocation` contains the latitude/longitude coordinates of
/// the given destination of this leg. Because the Directions API
/// calculates directions between locations by using the nearest
/// transportation option (usually a road) at the start and end points,
/// `endLocation` may be different than the provided destination of
/// this leg if, for example, a road is not near the destination.
///
///  * `startAddress` contains the human-readable address (typically
/// a street address) resulting from reverse geocoding the
/// `startLocation` of this leg.
///
///  * `endAddress` contains the human-readable address (typically a
/// street address) from reverse geocoding the `endLocation` of
/// this leg.
///
/// [iana]: http://www.iana.org/time-zones
class Leg {
  const Leg({
    this.arrivalTime,
    this.departureTime,
    this.distance,
    this.duration,
    this.durationInTraffic,
    this.endAddress,
    this.endLocation,
    this.startAddress,
    this.startLocation,
    this.steps,
  });

  factory Leg.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : Leg(
          arrivalTime: Time.fromMap(map['arrival_time']),
          departureTime: Time.fromMap(map['departure_time']),
          distance: Distance.fromMap(map['distance']),
          duration: DirectionsDuration.fromMap(map['duration']),
          durationInTraffic:
              DirectionsDuration.fromMap(map['duration_in_trafic']),
          endAddress: map['end_address'] as String,
          endLocation: _getGeoCoordFromMap(map['end_location']),
          startAddress: map['start_address'] as String,
          startLocation: _getGeoCoordFromMap(map['start_location']),
          steps: (map['steps'] as List)?.mapList((_) => Step.fromMap(_)),
        );

  /// Contains the estimated time of arrival for this leg. This property
  /// is only returned for transit directions. The result is returned as
  /// a [Time] object with three properties:
  ///   * `value` the time specified as a [DateTime] object.
  ///   * `text` the time specified as a string. The time is displayed
  /// in the time zone of the transit stop.
  ///   * `timeZone` contains the time zone of this station. The value
  /// is the name of the time zone as defined in the [IANA Time Zone
  /// Database][iana], e.g. `"America/New_York"`.
  final Time arrivalTime;

  /// Contains the estimated time of departure for
  /// this leg, specified as a [Time] object. The departureTime
  /// is only available for transit directions.
  final Time departureTime;

  /// Indicates the total distance covered by this leg, as a
  /// field with the following elements:
  ///   * `value` indicates the distance in meters
  ///   * `text` contains a human-readable representation of the
  /// distance, displayed in units as used at the origin (or as
  /// overridden within the `units` parameter in the request).
  /// (For example, miles and feet will be used for any origin
  /// within the United States.) Note that regardless of what
  /// unit system is displayed as text, the `distance.value`
  /// field always contains a value expressed in meters.
  ///
  /// These fields may be absent if the distance is unknown.
  final Distance distance;

  /// Indicates the total duration of this leg, as a field with
  /// the following elements:
  ///   * `value` indicates the duration in seconds.
  ///   * `text` contains a human-readable representation of the
  /// duration.
  ///
  /// These fields may be absent if the duration is unknown.
  final DirectionsDuration duration;

  /// Indicates the total duration of this leg. This value is an
  /// estimate of the time in traffic based on current and historical
  /// traffic conditions. See the `trafficModel` request parameter
  /// for the options you can use to request that the returned value
  /// is optimistic, pessimistic, or a best-guess estimate. The
  /// duration in traffic is returned only if all of the following
  /// are true:
  ///
  ///   * The request includes a valid API key, or a valid Google Maps
  ///   * Platform Premium Plan client ID and signature.
  ///   * The request does not include stopover waypoints. If the
  /// request includes waypoints, they must be prefixed with `via:`
  /// to avoid stopovers.
  ///   * The request is specifically for driving directions—the
  /// `mode` parameter is set to `driving`.
  ///   * The request includes a `departureTime` parameter.
  ///   * Traffic conditions are available for the requested route.
  ///
  ///   The `durationInTraffic` contains the following fields:
  ///   * `value` indicates the duration in seconds.
  ///   * `text` contains a human-readable representation of the duration.
  final DirectionsDuration durationInTraffic;

  /// Contains the human-readable address (typically a street address)
  /// from reverse geocoding the `endLocation` of this leg.
  final String endAddress;

  /// Contains the latitude/longitude coordinates of the given
  /// destination of this leg. Because the Directions API calculates
  /// directions between locations by using the nearest transportation
  /// option (usually a road) at the start and end points,
  /// `endLocation` may be different than the provided destination of
  /// this leg if, for example, a road is not near the destination.
  final GeoCoord endLocation;

  /// Contains the human-readable address (typically a street address)
  /// resulting from reverse geocoding the `startLocation` of this leg.
  final String startAddress;

  /// Contains the latitude/longitude coordinates of the origin of this
  /// leg. Because the Directions API calculates directions between
  /// locations by using the nearest transportation option (usually a
  /// road) at the start and end points, `startLocation` may be
  /// different than the provided origin of this leg if, for example,
  /// a road is not near the origin.
  final GeoCoord startLocation;

  /// contains an array of steps denoting information about each
  /// separate step of the leg of the journey.
  final List<Step> steps;
}

/// Each element in the steps array defines a single step of the
/// calculated directions. A step is the most atomic unit of a
/// direction's route, containing a single step describing a specific,
/// single instruction on the journey. E.g. "Turn left at W. 4th St."
/// The step not only describes the instruction but also contains
/// distance and duration information relating to how this step
/// relates to the following step. For example, a step denoted as
/// "Merge onto I-80 West" may contain a duration of "37 miles" and
/// "40 minutes," indicating that the next step is 37 miles/40
/// minutes from this step.
///
/// When using the Directions API to search for transit directions,
/// the steps array will include additional transit details in the
/// form of a transit_details array. If the directions include
/// multiple modes of transportation, detailed directions will be
/// provided for walking or driving steps in an inner steps array.
/// For example, a walking step will include directions from the
/// start and end locations: "Walk to Innes Ave & Fitch St". That
/// step will include detailed walking directions for that route
/// in the inner steps array, such as: "Head north-west", "Turn
/// left onto Arelious Walker", and "Turn left onto Innes Ave".
///
/// Each step within the steps field(s) may contain the following
/// fields:
///
///  * `instructions` contains formatted instructions for this step,
/// presented as a text string. (Corresponds to instructions in
/// the [Directions.Step interface][directions_step_interface].)
///
///  * `distance` contains the distance covered by this step until
/// the next step. (See the discussion of this field in Directions
/// Legs above.) This field may be undefined if the distance is
/// unknown.
///
///  * `duration` contains the typical time required to perform the
/// step, until the next step. (See the description in Directions
/// Legs above.) This field may be undefined if the duration is
/// unknown.
///
///  * `startLocation` contains the location of the starting point
/// of this step, as a single set of lat and lng fields.
///
///  * `endLocation` contains the location of the last point of this
/// step, as a single set of lat and lng fields.
///
///  * `path` contains a sequence of GeoCoords describing the
/// course of this step.
///
///  * `steps` contains detailed directions for walking or driving
/// steps in transit directions. Substeps are only available when
/// travelMode is set to "transit". The inner steps array is of
/// the same type as steps.
///
///  * `transitDetails` contains transit specific information.
/// This field is only returned with `travelMode` is set to
/// "transit". See Transit Details below. (Corresponds to transit
/// in the [Directions.Step interface][directions_step_interface].)
///
///  * `travelMode` contains the type of travel mode used.
///
/// [directions_step_interface]: https://developers.google.com/maps/documentation/javascript/reference/directions#DirectionsStep
/// [enc_polyline]: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
class Step {
  const Step({
    this.distance,
    this.duration,
    this.endLocation,
    this.instructions,
    this.path,
    this.startLocation,
    this.steps,
    this.transit,
    this.travelMode,
  });

  factory Step.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : Step(
          distance: Distance.fromMap(map['distance']),
          duration: DirectionsDuration.fromMap(map['duration']),
          endLocation: _getGeoCoordFromMap(map['end_location']),
          startLocation: _getGeoCoordFromMap(map['start_location']),
          instructions: map['html_instructions'] as String,
          path: (map['path'] as List)?.mapList((_) => _getGeoCoordFromMap(_)),
          steps: (map['steps'] as List)?.mapList((_) => Step.fromMap(_)),
          transit: TransitDetails.fromMap(map['transit']),
          travelMode: TravelMode(map['travel_mode']),
        );

  /// Contains the distance covered by this step until the next
  /// step. This field may be undefined if the distance is unknown.
  final Distance distance;

  /// Contains the typical time required to perform the step,
  /// until the next step. This field may be undefined if the
  /// duration is unknown.
  final DirectionsDuration duration;

  /// Contains the location of the last point of this step, as a
  /// single set of lat and lng fields.
  final GeoCoord endLocation;

  /// Contains the location of the starting point of this step, as
  /// a single set of lat and lng fields.
  final GeoCoord startLocation;

  /// Contains formatted instructions for this step,
  /// presented as a text string. (Corresponds to instructions in
  /// the [Directions.Step interface][directions_step_interface].)
  final String instructions;

  /// Contains a sequence of GeoCoords describing the course of this step.
  final List<GeoCoord> path;

  /// Contains detailed directions for walking or driving
  /// steps in transit directions. Substeps are only available when
  /// travelMode is set to "transit". The inner steps array is of
  /// the same type as steps.
  final List<Step> steps;

  /// Contains transit specific information.
  /// This field is only returned with `travelMode` is set to
  /// "transit". See Transit Details below. (Corresponds to transit
  /// in the [Directions.Step interface][directions_step_interface].)
  final TransitDetails transit;

  /// Contains the type of travel mode used.
  final TravelMode travelMode;
}

/// Transit directions return additional information that is not
/// relevant for other modes of transportation. These additional
/// properties are exposed through the `transit` object,
/// returned as a field of an element in the `steps` array. From
/// the [TransitDetails] object you can access additional
/// information about the transit stop, transit line and transit
/// agency.
///
/// A `transit` object may contain the following fields:
///
///  * `arrivalStop` and `departureStop` contains information about
/// the stop/station for this part of the trip. Stop details can
/// include:
///   * `name` the name of the transit station/stop. eg. "Union
/// Square".
///   * `location` the location of the transit station/stop,
/// represented as a lat and lng field.
///
///  * `arrivalTime` and `departureTime` contain the arrival or
/// departure times for this leg of the journey, specified as the
/// following three properties:
///   * `text` the time specified as a string. The time is
/// displayed in the time zone of the transit stop.
///   * `value` the time specified as Unix time, or seconds
/// since midnight, January 1, 1970 UTC.
///   * `timeZone` contains the time zone of this station.
/// The value is the name of the time zone as defined in the
/// [IANA Time Zone Database][iana], e.g. `"America/New_York"`.
///
///  * `headsign` specifies the direction in which to travel on
/// this line, as it is marked on the vehicle or at the departure
/// stop. This will often be the terminus station.
///
///  * `headway` specifies the expected number of seconds between
/// departures from the same stop at this time. For example, with
/// a headway value of 600, you would expect a ten minute wait if
/// you should miss your bus.
///
///  * `numStops` contains the number of stops in this step,
/// counting the arrival stop, but not the departure stop.
/// For example, if your directions involve leaving from Stop A,
/// passing through stops B and C, and arriving at stop D,
/// `numStops` will return 3.
///
///  * `tripShortName` contains the text that appears in schedules
/// and sign boards to identify a transit trip to passengers. The
/// text should uniquely identify a trip within a service day. For
/// example, "538" is the `tripShortName` of the Amtrak train that
/// leaves San Jose, CA at 15:10 on weekdays to Sacramento, CA.
///
///  * `line` contains information about the transit line used in this
/// step, and may include the following properties:
///   * `name` contains the full name of this transit line. eg.
/// "7 Avenue Express".
///   * `shortName` contains the short name of this transit line.
/// This will normally be a line number, such as "M7" or "355".
///   * `color` contains the color commonly used in signage for this
/// transit line. The color will be specified as a hex string such
/// as: #FF0033.
///   * `agencies` is an array containing a single [TransitAgency]
///  object. The DirectionsTransitAgency] object provides information
/// about the operator of the line, including the following properties:
///     * `name` contains the name of the transit agency.
///     * `phone` contains the phone number of the transit agency.
///     * `url` contains the URL for the transit agency.
///
///   You must display the names and URLs of the transit agencies
/// servicing the trip results.
///
///
///   * `url` contains the URL for this transit line as provided by
/// the transit agency.
///   * `icon` contains the URL for the icon associated with this line.
///   * `textColor` contains the color of text commonly used for
/// signage of this line. The color will be specified as a hex string.
///   * `vehicle` contains the type of vehicle used on this line.
/// This may include the following properties:
///     * `name` contains the name of the vehicle on this line. eg. "Subway."
///     * `type` contains the type of vehicle that runs on this line.
/// See the Vehicle Type documentation for a complete list of supported values.
///     * `icon` contains the URL for an icon associated with this vehicle type.
///     * `localIcon` contains the URL for the icon associated with this
/// vehicle type, based on the local transport signage.
///
/// [iana]: http://www.iana.org/time-zones
class TransitDetails {
  const TransitDetails({
    this.arrivalStop,
    this.departureStop,
    this.arrivalTime,
    this.departureTime,
    this.headsign,
    this.headway,
    this.line,
    this.numStops,
    this.tripShortName,
  });

  factory TransitDetails.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : TransitDetails(
          arrivalStop: TransitStop.fromMap(map['arrival_stop']),
          departureStop: TransitStop.fromMap(map['departure_stop']),
          arrivalTime: Time.fromMap(map['arrival_time']),
          departureTime: Time.fromMap(map['departure_time']),
          headsign: map['headsign'] as String,
          headway: map['headway'] as num,
          line: TransitLine.fromMap(map['line']),
          numStops: map['num_stops'] as num,
          tripShortName: map['trip_short_name'] as String,
        );

  /// Contains information about the stop/station for this part of
  /// the trip. Stop details can include:
  ///   * `name` the name of the transit station/stop. eg. "Union
  /// Square".
  ///   * `location` the location of the transit station/stop,
  /// represented as a lat and lng field.
  final TransitStop arrivalStop;

  /// Contains information about the stop/station for this part of
  /// the trip. Stop details can include:
  ///   * `name` the name of the transit station/stop. eg. "Union
  /// Square".
  ///   * `location` the location of the transit station/stop,
  /// represented as a lat and lng field.
  final TransitStop departureStop;

  /// Contain the arrival times for this leg of the journey,
  /// specified as the following three properties:
  ///   * `text` the time specified as a string. The time is
  /// displayed in the time zone of the transit stop.
  ///   * `value` the time specified as Unix time, or seconds
  /// since midnight, January 1, 1970 UTC.
  ///   * `timeZone` contains the time zone of this station.
  /// The value is the name of the time zone as defined in the
  /// [IANA Time Zone Database][iana], e.g. `"America/New_York"`.
  ///
  /// [iana]: http://www.iana.org/time-zones
  final Time arrivalTime;

  /// Contain the departure times for this leg of the journey,
  /// specified as the following three properties:
  ///   * `text` the time specified as a string. The time is
  /// displayed in the time zone of the transit stop.
  ///   * `value` the time specified as Unix time, or seconds
  /// since midnight, January 1, 1970 UTC.
  ///   * `timeZone` contains the time zone of this station.
  /// The value is the name of the time zone as defined in the
  /// [IANA Time Zone Database][iana], e.g. `"America/New_York"`.
  ///
  /// [iana]: http://www.iana.org/time-zones
  final Time departureTime;

  /// Specifies the direction in which to travel on this line,
  /// as it is marked on the vehicle or at the departure stop.
  /// This will often be the terminus station.
  final String headsign;

  /// Specifies the expected number of seconds between departures
  /// from the same stop at this time. For example, with a
  /// headway value of 600, you would expect a ten minute wait if
  /// you should miss your bus.
  final num headway;

  /// Contains information about the transit line used in this step.
  final TransitLine line;

  /// Contains the number of stops in this step, counting the
  /// arrival stop, but not the departure stop. For example,
  /// if your directions involve leaving from Stop A, passing
  /// through stops B and C, and arriving at stop D, `numStops`
  /// will return 3.
  final num numStops;

  /// Contains the text that appears in schedules and sign boards
  /// to identify a transit trip to passengers. The text should
  /// uniquely identify a trip within a service day. For example,
  /// "538" is the `tripShortName` of the Amtrak train that leaves
  ///  San Jose, CA at 15:10 on weekdays to Sacramento, CA.
  final String tripShortName;
}

/// Contains information about the transit line used in this
/// step, and may include the following properties:
///   * `name` contains the full name of this transit line. eg.
/// "7 Avenue Express".
///   * `shortName` contains the short name of this transit line.
/// This will normally be a line number, such as "M7" or "355".
///   * `color` contains the color commonly used in signage for this
/// transit line. The color will be specified as a hex string such
/// as: #FF0033.
///   * `agencies` is an array containing a single [TransitAgency]
/// object. The [TransitAgency] object provides information
/// about the operator of the line, including the following properties:
///     * `name` contains the name of the transit agency.
///     * `phone` contains the phone number of the transit agency.
///     * `url` contains the URL for the transit agency.
///
///   You must display the names and URLs of the transit agencies
/// servicing the trip results.
///
///
///   * `url` contains the URL for this transit line as provided by
/// the transit agency.
///   * `icon` contains the URL for the icon associated with this line.
///   * `textColor` contains the color of text commonly used for
/// signage of this line. The color will be specified as a hex string.
///   * `vehicle` contains the type of vehicle used on this line.
/// This may include the following properties:
///     * `name` contains the name of the vehicle on this line. eg. "Subway."
///     * `type` contains the type of vehicle that runs on this line.
/// See the Vehicle Type documentation for a complete list of supported values.
///     * `icon` contains the URL for an icon associated with this vehicle type.
///     * `localIcon` contains the URL for the icon associated with this
/// vehicle type, based on the local transport signage.
class TransitLine {
  const TransitLine({
    this.name,
    this.shortName,
    this.color,
    this.agencies,
    this.url,
    this.icon,
    this.textColor,
    this.vehicle,
  });

  factory TransitLine.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : TransitLine(
          name: map['name'] as String,
          shortName: map['short_name'] as String,
          color: map['color'] as String,
          agencies: (map['agencies'] as List)
              ?.mapList((_) => TransitAgency.fromMap(_)),
          url: map['url'] as String,
          icon: map['icon'] as String,
          textColor: map['text_color'] as String,
          vehicle: Vehicle.fromMap(map['vehicle']),
        );

  /// Contains the full name of this transit line. eg. "7 Avenue Express".
  final String name;

  /// Contains the short name of this transit line. This will normally be
  /// a line number, such as "M7" or "355".
  final String shortName;

  /// Contains the color commonly used in signage for this transit line.
  /// The color will be specified as a hex string such as: #FF0033.
  final String color;

  /// Is an array containing a single [TransitAgency] object.
  /// The [TransitAgency] object provides information
  /// about the operator of the line, including the following properties:
  ///  * `name` contains the name of the transit agency.
  ///  * `phone` contains the phone number of the transit agency.
  ///  * `url` contains the URL for the transit agency.
  ///
  ///   You must display the names and URLs of the transit agencies
  /// servicing the trip results.
  final List<TransitAgency> agencies;

  /// Contains the URL for this transit line as provided by the transit agency.
  final String url;

  /// Contains the URL for the icon associated with this line.
  final String icon;

  /// Contains the color of text commonly used for signage of this line.
  /// The color will be specified as a hex string.
  final String textColor;

  /// Contains the type of vehicle used on this line.
  /// This may include the following properties:
  ///  * `name` contains the name of the vehicle on this line. eg. "Subway."
  ///  * `type` contains the type of vehicle that runs on this line.
  /// See the [VehicleType] documentation for a complete list of
  /// supported values.
  ///  * `icon` contains the URL for an icon associated with this vehicle type.
  ///  * `localIcon` contains the URL for the icon associated with this
  /// vehicle type, based on the local transport signage.
  final Vehicle vehicle;
}

/// Contains a single points object that holds an
/// [encoded polyline][enc_polyline] representation of the route.
/// This polyline is an approximate (smoothed) path of the resulting
/// directions.
///
/// [enc_polyline]: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
class OverviewPolyline {
  const OverviewPolyline({this.points});

  factory OverviewPolyline.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : OverviewPolyline(
          points: map['points'] as String,
        );

  /// Contains [encoded polyline][enc_polyline] representation of the
  /// route. This polyline is an approximate (smoothed) path of the
  /// resulting directions.
  ///
  /// [enc_polyline]: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  final String points;
}

/// Details about the total distance covered by this leg, with the
/// following elements:
///   * `value` indicates the distance in meters
///   * `text` contains a human-readable representation of the
/// distance, displayed in units as used at the origin (or as
/// overridden within the `units` parameter in the request).
/// (For example, miles and feet will be used for any origin
/// within the United States.) Note that regardless of what
/// unit system is displayed as text, the `distance.value`
/// field always contains a value expressed in meters.
class Distance {
  const Distance({this.text, this.value});

  factory Distance.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : Distance(
          text: map['text'] as String,
          value: map['value'],
        );

  /// Contains a human-readable representation of the
  /// distance, displayed in units as used at the origin (or as
  /// overridden within the `units` parameter in the request).
  /// (For example, miles and feet will be used for any origin
  /// within the United States.) Note that regardless of what
  /// unit system is displayed as text, the `distance.value`
  /// field always contains a value expressed in meters.
  final String text;

  /// Indicates the distance in meters
  final num value;
}

/// Details about the total duration, with the following elements:
///   * `value` indicates the duration in seconds.
///   * `text` contains a human-readable representation of the
/// duration.
class DirectionsDuration {
  const DirectionsDuration({this.text, this.value});

  factory DirectionsDuration.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : DirectionsDuration(
          text: map['text'] as String,
          value: map['value'],
        );

  /// Contains a human-readable representation of the duration.
  final String text;

  /// Indicates the duration in seconds.
  final num value;
}

/// Details about the time, with the following elements:
///   * `value` the time specified as a [DateTime] object.
///   * `text` the time specified as a [String]. The time is displayed
/// in the time zone of the transit stop.
///   * `timeZone` contains the time zone of this station. The value
/// is the name of the time zone as defined in the [IANA Time Zone
/// Database][iana], e.g. `"America/New_York"`.
///
/// [iana]: http://www.iana.org/time-zones
class Time {
  const Time({
    this.text,
    this.timeZone,
    this.value,
  });

  factory Time.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : Time(
          text: map['text'] as String,
          timeZone: map['time_zone'] as String,
          value: DateTime.tryParse(map['value'] as String),
        );

  /// The time specified as a [String]. The time is displayed in the time
  /// zone of the transit stop.
  final String text;

  /// Contains the time zone of this station. The value is the name
  /// of the time zone as defined in the [IANA Time Zone Database][iana],
  /// e.g. `"America/New_York"`.
  ///
  /// [iana]: http://www.iana.org/time-zones
  final String timeZone;

  /// The time specified as a [DateTime] object.
  final DateTime value;
}

/// Contains the total fare (that is, the total
/// ticket costs) on this route. This property is only returned for
/// transit requests and only for routes where fare information is
/// available for all transit legs. The information includes:
///   * `currency`: An [ISO 4217 currency code][iso4217] indicating the
/// currency that the amount is expressed in.
///   * `value`: The total fare amount, in the currency specified above.
///   * `text`: The total fare amount, formatted in the requested language.
///
/// [iso4217]: https://en.wikipedia.org/wiki/ISO_4217
class Fare {
  const Fare({
    this.text,
    this.currency,
    this.value,
  });

  factory Fare.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : Fare(
          text: map['text'] as String,
          currency: map['currency'] as String,
          value: map['value'] as num,
        );

  /// The total fare amount, formatted in the requested language.
  final String text;

  /// An [ISO 4217 currency code][iso4217] indicating the
  /// currency that the amount is expressed in.
  final String currency;

  /// The total fare amount, in the currency specified above.
  final num value;
}

/// Contains information about the stop/station for this part of
/// the trip. Stop details can include:
///   * `name` the name of the transit station/stop. eg. "Union
/// Square".
///   * `location` the location of the transit station/stop,
/// represented as a lat and lng field.
class TransitStop {
  const TransitStop({this.name, this.location});

  factory TransitStop.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : TransitStop(
          name: map['name'] as String,
          location: _getGeoCoordFromMap(map['location']),
        );

  /// The name of the transit station/stop. eg. "Union Square".
  final String name;

  /// The location of the transit station/stop, represented as a
  /// lat and lng field
  final GeoCoord location;
}

/// Provides information about the operator of the line, including
/// the following properties:
///  * `name` contains the name of the transit agency.
///  * `phone` contains the phone number of the transit agency.
///  * `url` contains the URL for the transit agency.
class TransitAgency {
  const TransitAgency({
    this.name,
    this.phone,
    this.url,
  });

  factory TransitAgency.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : TransitAgency(
          name: map['name'] as String,
          phone: map['phone'] as String,
          url: map['url'] as String,
        );

  /// Contains the name of the transit agency.
  final String name;

  /// Contains the phone number of the transit agency.
  final String phone;

  /// Contains the URL for the transit agency.
  final String url;
}

/// Contains the type of vehicle used on this line.
/// This may include the following properties:
///  * `name` contains the name of the vehicle on this line. eg. "Subway."
///  * `type` contains the type of vehicle that runs on this line.
/// See the [VehicleType] documentation for a complete list of
/// supported values.
///  * `icon` contains the URL for an icon associated with this vehicle type.
///  * `localIcon` contains the URL for the icon associated with this
/// vehicle type, based on the local transport signage.
class Vehicle {
  const Vehicle({
    this.name,
    this.type,
    this.icon,
    this.localIcon,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) => map == null
      ? null
      : Vehicle(
          name: map['name'] as String,
          type: VehicleType(map['type']),
          icon: map['icon'] as String,
          localIcon: map['localIcon'] as String,
        );

  /// Contains the name of the vehicle on this line. eg. "Subway."
  final String name;

  /// Contains the type of vehicle that runs on this line.
  final VehicleType type;

  /// Contains the URL for an icon associated with this vehicle type.
  final String icon;

  /// Contains the URL for the icon associated with this
  /// vehicle type, based on the local transport signage.
  final String localIcon;
}

/// The status field within the Directions response object contains
/// the status of the request, and may contain debugging information
/// to help you track down why the Directions service failed.
class DirectionsStatus {
  const DirectionsStatus(this._name);

  final String _name;

  static final values = <DirectionsStatus>[
    invalidRequest,
    maxWaypointExceeded,
    notFound,
    ok,
    overQueryLimit,
    requestDenied,
    unknownError,
    zeroResults
  ];

  /// Indicates the response contains a valid result.
  static const ok = DirectionsStatus('OK');

  /// Indicates at least one of the locations specified in the
  /// request's origin, destination, or waypoints could not be geocoded.
  static const notFound = DirectionsStatus('NOT_FOUND');

  /// Indicates no route could be found between the origin and destination.
  static const zeroResults = DirectionsStatus('ZERO_RESULTS');

  /// Indicates that too many waypoints were provided in the request.
  /// For applications using the Directions API as a web service, or
  /// the [directions service in the Maps JavaScript API][maps_js_api],
  /// the maximum allowed number of waypoints is 25, plus the origin
  /// and destination.
  static const maxWaypointExceeded = DirectionsStatus('MAX_WAYPOINTS_EXCEEDED');

  /// Indicates the requested route is too long and cannot be processed.
  /// This error occurs when more complex directions are returned. Try
  /// reducing the number of waypoints, turns, or instructions.
  static const maxRouteLengthExceeded =
      DirectionsStatus('MAX_ROUTE_LENGTH_EXCEEDED');

  /// Indicates that the provided request was invalid. Common causes of
  /// this status include an invalid parameter or parameter value.
  static const invalidRequest = DirectionsStatus('INVALID_REQUEST');

  /// Indicates any of the following:
  ///     * The API key is missing or invalid.
  ///     * Billing has not been enabled on your account.
  ///     * A self-imposed usage cap has been exceeded.
  ///     * The provided method of payment is no longer valid (for example,
  /// a credit card has expired).
  ///     * See the [Maps FAQ][faq] to learn how to fix this.
  static const overDailyLimit = DirectionsStatus('OVER_DAILY_LIMIT');

  /// Indicates the service has received too many requests from your
  /// application within the allowed time period.
  static const overQueryLimit = DirectionsStatus('OVER_QUERY_LIMIT');

  /// Indicates that the service denied use of the directions service
  /// by your application.
  static const requestDenied = DirectionsStatus('REQUEST_DENIED');

  /// Indicates a directions request could not be processed due to a
  /// server error. The request may succeed if you try again.
  static const unknownError = DirectionsStatus('UNKNOWN_ERROR');

  @override
  int get hashCode => _name.hashCode;

  @override
  bool operator ==(dynamic other) =>
      other is DirectionsStatus && _name == other._name;

  @override
  String toString() => '$_name';
}

/// Type of vehicle.
class VehicleType {
  const VehicleType(this._name);

  final String _name;

  static final values = <VehicleType>[
    bus,
    cableCard,
    commuterTrain,
    ferry,
    funicular,
    gondolaLift,
    heavyRail,
    highSpeedTrain,
    intercityBus,
    metroRail,
    monorail,
    other,
    rail,
    shareTaxi,
    subway,
    tram,
    trolleybus,
  ];

  /// Bus.
  static const bus = VehicleType('BUS');

  /// A vehicle that operates on a cable, usually on the ground.
  /// Aerial cable cars may be of the type GONDOLA_LIFT.
  static const cableCard = VehicleType('CABLE_CAR');

  /// Commuter rail.
  static const commuterTrain = VehicleType('COMMUTER_TRAIN');

  /// Ferry.
  static const ferry = VehicleType('FERRY');

  /// A vehicle that is pulled up a steep incline by a cable.
  static const funicular = VehicleType('FUNICULAR');

  /// An aerial cable car.
  static const gondolaLift = VehicleType('GONDOLA_LIFT');

  /// Heavy rail.
  static const heavyRail = VehicleType('HEAVY_RAIL');

  /// High speed train.
  static const highSpeedTrain = VehicleType('HIGH_SPEED_TRAIN');

  /// Intercity bus.
  static const intercityBus = VehicleType('INTERCITY_BUS');

  /// Light rail.
  static const metroRail = VehicleType('METRO_RAIL');

  /// Monorail.
  static const monorail = VehicleType('MONORAIL');

  /// Other vehicles.
  static const other = VehicleType('OTHER');

  /// Rail.
  static const rail = VehicleType('RAIL');

  /// Share taxi is a sort of bus transport with ability to drop
  /// off and pick up passengers anywhere on its route. Generally
  /// share taxi uses minibus vehicles.
  static const shareTaxi = VehicleType('SHARE_TAXI');

  /// Underground light rail.
  static const subway = VehicleType('SUBWAY');

  /// Above ground light rail.
  static const tram = VehicleType('TRAM');

  /// Trolleybus.
  static const trolleybus = VehicleType('TROLLEYBUS');

  @override
  int get hashCode => _name.hashCode;

  @override
  bool operator ==(dynamic other) =>
      other is VehicleType && _name == other._name;

  @override
  String toString() => '$_name';
}
