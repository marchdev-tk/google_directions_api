// Copyright (c) 2020, the MarchDev Toolkit project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
