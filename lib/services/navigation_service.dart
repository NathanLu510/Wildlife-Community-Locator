// Generate a Google Maps Direction URL based on the sighting location
// User location is not provided here, Google Maps will handle that with device location

import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  static Future<bool> navigateTo({
    required double latitude,
    required double longitude,
  }) async {
    final destination = '$latitude,$longitude';

    final uri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'destination': destination,
        'travelmode': 'driving',
      },
    );

    return launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
