import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_code/screens/map/model.dart';

class MyMap extends StatefulWidget {
  const MyMap({Key? key}) : super(key: key);

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final completer = Completer<GoogleMapController>();
  static const CameraPosition cairo = CameraPosition(
    target: LatLng(30.0596113, 31.3408666),
    zoom: 8,
  );
  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        GoogleMap(
          markers: markers,
          onTap: (argument) {
            markers.add(Marker(
                markerId: MarkerId(argument.longitude.toString()),
                position: LatLng(argument.latitude.toDouble(),
                    argument.longitude.toDouble())));
            setState(() {});
          },
          mapType: MapType.normal,
          initialCameraPosition: cairo,
          onMapCreated: (GoogleMapController controller) {
            completer.complete(controller);
          },
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 10, vertical: 10),
            child: TextFormField(
              onChanged: (value) async {
                final resp = await Dio().get(
                    "https://api.openrouteservice.org/geocode/search?api_key=5b3ce3597851110001cf62489d579e9c9f3141f89eb7dfc4b2705bf8&text=$value&boundary.country=EG&size=360");
                final model = SearchData.fromJson(resp.data);
                showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(16, 88, 16, 0),
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 18,
                    maxWidth: MediaQuery.of(context).size.width - 18,
                    maxHeight: 400,
                    minHeight: 200,
                  ),
                  items: List.generate(
                    model.results.length,
                    (index) => PopupMenuItem(
                      child: Text(model.results[index].name),
                      onTap: () {
                        markers.add(Marker(
                            markerId: MarkerId(model.results[index].name),
                            position: LatLng(
                                model.results[index].lat.toDouble(),
                                model.results[index].lng.toDouble())));
                        goTo(model.results[index].lat.toDouble(),
                            model.results[index].lng.toDouble());
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }

  goTo(double lat, double lng) async {
    final GoogleMapController controller = await completer.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 16)));
  }
}
