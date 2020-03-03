# google_directions_api

![Build](https://github.com/marchdev-tk/google_directions_api/workflows/build/badge.svg)
[![Pub](https://img.shields.io/pub/v/google_directions_api.svg)](https://pub.dartlang.org/packages/google_directions_api)
![GitHub](https://img.shields.io/github/license/marchdev-tk/google_directions_api)
![GitHub stars](https://img.shields.io/github/stars/marchdev-tk/google_directions_api?style=social)

The Directions API is a service that calculates directions between locations. You can search for directions for several modes of transportation, including transit, driving, walking, or cycling.

## Getting Started

The Directions API is a service that calculates directions between locations using an HTTP request.

With the Directions API, you can:

 * Search for directions for several modes of transportation, including transit, driving, walking or cycling.
 * Return multi-part directions using a series of waypoints.
 * Specify origins, destinations, and waypoints as text strings (e.g. "Chicago, IL" or "Darwin, NT, Australia"), or as latitude/longitude coordinates, or as place IDs.

The API returns the most efficient routes when calculating directions. Travel time is the primary factor optimized, but the API may also take into account other factors such as distance, number of turns and many more when deciding which route is the most efficient.

**Note**: This service is **not designed to respond in real time to user input**. 

For full info about Directions API visit official [documentation](https://developers.google.com/maps/documentation/directions/intro#top_of_page)

### Usage

```dart
import 'package:google_directions_api/google_directions_api.dart';

void main() {
  DirectionsService.init('API_KEY');

  final directionsService = DirectionsService();

  final request = DirectionsRequest(
    origin: 'New York',
    destination: 'San Francisco',
    travelMode: TravelMode.driving,
  );

  directionsService.route(request,
      (DirectionsResult response, DirectionsStatus status) {
    if (status == DirectionsStatus.ok) {
      // do something with successful response
    } else {
      // do something with error response
    }
  });
}
```

## Feature requests and Bug reports

Feel free to post a feature requests or report a bug [here](https://github.com/marchdev-tk/google_directions_api/issues).

## TODO

* Write tests via mocks
