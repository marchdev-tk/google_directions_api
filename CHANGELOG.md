# Changelog

## 0.10.0

* Updated dependencies (thanks to [@svoza10](https://github.com/svoza10))
* Fixed [issue #9](https://github.com/marchdev-tk/google_directions_api/issues/9) (thanks to [@SamadiPour](https://github.com/SamadiPour))
* Fixed [issue #12](https://github.com/marchdev-tk/google_directions_api/issues/12) (thanks to [@SamadiPour](https://github.com/SamadiPour))
* Fixed [issue #16](https://github.com/marchdev-tk/google_directions_api/issues/16) (thanks to [@SamadiPour](https://github.com/SamadiPour))

## 0.9.1

* Fixed misnaming of `duration_in_trafic`

## 0.9.0

* Added null checks for `fromMap` constructors

## 0.8.0

* Fixed waypoint order parsing
* Added polyline parsing to `Step`

## 0.7.0

* Fixed parsing of `instructions` (changed to `html_instructions`) for `Step`
* Added language parameter to `DirectionsRequest`

## 0.6.0

* Updated to NNBD

## 0.5.0

* Redesigned LatLng, LatLngBounds due to ambiguous class names when using google_maps_flutter or google_maps packages

## 0.4.0

* Removed flutter dependency

## 0.3.0

* Finished with request models
* Added LatLng, LatLngBounds to remove dependency on google_maps_flutter plugin
* Added overviewPath getter for decoded overviewPolyline in DirectionsRoute

## 0.2.0

* Redesigned class names of response DTO's
* Doc updates

## 0.1.0

* Implemented DirectionAPI responses
* Added required request fields (origin/desctination/travelMode)
