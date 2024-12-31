import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWithDynamicCircle extends StatefulWidget {
  const MapWithDynamicCircle({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapWithDynamicCircleState createState() => _MapWithDynamicCircleState();
}

class _MapWithDynamicCircleState extends State<MapWithDynamicCircle> {
  final LatLng center = const LatLng(35.718532, 139.586639);

  double currentZoom = 13.0;

  final double circleRadiusMeters = 1000.0;

  ///
  List<LatLng> calculateCirclePoints(LatLng center, double radiusMeters) {
    const int points = 64;

    const double earthRadius = 6378137.0;

    final double lat = center.latitude * pi / 180.0;

    final double lng = center.longitude * pi / 180.0;

    final double d = radiusMeters / earthRadius;

    final List<LatLng> circlePoints = <LatLng>[];

    for (int i = 0; i <= points; i++) {
      final double angle = 2 * pi * i / points;

      final double latOffset = asin(sin(lat) * cos(d) + cos(lat) * sin(d) * cos(angle));

      final double lngOffset = lng + atan2(sin(angle) * sin(d) * cos(lat), cos(d) - sin(lat) * sin(latOffset));

      circlePoints.add(LatLng(latOffset * 180.0 / pi, lngOffset * 180.0 / pi));
    }
    return circlePoints;
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Map - Dynamic Circle'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: currentZoom,
          onPositionChanged: (MapCamera position, bool hasGesture) {
            setState(() {
              currentZoom = position.zoom;
            });
          },
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),

          ///

          // ignore: always_specify_types
          PolygonLayer(
            polygons: <Polygon<Object>>[
              // ignore: always_specify_types
              Polygon(
                points: calculateCirclePoints(center, circleRadiusMeters),
                color: Colors.redAccent.withOpacity(0.1),
                borderStrokeWidth: 2.0,
                borderColor: Colors.redAccent.withOpacity(0.5),
              ),
            ],
          ),

          ///

          MarkerLayer(markers: <Marker>[
            Marker(
              point: const LatLng(35.718532, 139.586639),
              width: 40,
              height: 40,
              // ignore: use_if_null_to_convert_nulls_to_bools
              child: CircleAvatar(
                backgroundColor: Colors.redAccent.withOpacity(0.5),
                child: const Text('A', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MapWithDynamicCircle(),
  ));
}
