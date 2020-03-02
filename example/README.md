# google_directions_api_example

Demonstrates how to use the google_directions_api package.

## Usage

```dart
import 'package:google_directions_api/google_directions_api.dart';

void main() {
  DirectionsService.init('API_KEY');

  final directinosService = DirectionsService();

  final request = DirectionsRequest(
    origin: 'Chicago, IL',
    destination: 'San Francisco, CA',
    travelMode: TravelMode.driving,
  );

  directinosService.route(request,
      (DirectionsResult response, DirectionsStatus status) {
    if (status == DirectionsStatus.ok) {
      // do something with successful response
    } else {
      // do something with error response
    }
  });
}
```

## Getting Started

For help getting started with Directions API, view 
[online documentation](https://developers.google.com/maps/documentation/directions/start), which offers tutorials, 
samples, guidance, and a full API reference.
