import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);
  static List<Marker> markers = [
    Marker(
      markerId: const MarkerId('testing1'),
      position: const LatLng(16.83, 96.17),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    ),
  ];

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  BitmapDescriptor? _markerIcon;
  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(
        context,
        size: const Size.square(48),
      );
      BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        'assets/marker_logo.png',
      ).then((bitmap) {
        setState(() => _markerIcon = bitmap);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    GoogleMapController? mapController;
    TextEditingController searchAddress = TextEditingController();

    _createMarkerImageFromAsset(context);
    
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            // mapType: MapType.terrain,
            initialCameraPosition: const CameraPosition(
              target: LatLng(16.8409, 96.1735),
              bearing: 0,
              zoom: 15,
              tilt: 0,
            ),
            trafficEnabled: false,
            minMaxZoomPreference: const MinMaxZoomPreference(10, 20),
            rotateGesturesEnabled: false,
            zoomControlsEnabled: false,
            markers: MapPage.markers.map((e) => e).toSet(),

            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              changeMapStyle(mapController);
            },
            onLongPress: (LatLng pos) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lat: ' +
                      pos.latitude.toString() +
                      ' Lng: ' +
                      pos.longitude.toString()),
                ),
              );
            },
            onTap: (LatLng pos) async {
              setState(() {
                MapPage.markers.add(Marker(
                  markerId: MarkerId('marker_${MapPage.markers.length}'),
                  position: pos,
                  icon:
                      _markerIcon ?? BitmapDescriptor.defaultMarkerWithHue(45),
                ));
              });
              changeMapStyle(mapController);
              print(MapPage.markers.length);
            },
          ),
          Positioned(
            top: 50,
            right: 30,
            left: 30,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Enter Address",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(left: 15, top: 15),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      print('This is search String ' + searchAddress.text);
                      print(mapController == null);

                      mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                          const CameraPosition(
                            target: LatLng(21.9588, 96.0891),
                            zoom: 15,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                controller: searchAddress,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeMapStyle(GoogleMapController? mapController) {
    mapController?.setMapStyle('''
              [
                {
                  "elementType": "labels.icon",
                  "stylers": [
                    {
                      "visibility": "off"
                    }
                  ]
                }
              ]
              ''');
  }
}
