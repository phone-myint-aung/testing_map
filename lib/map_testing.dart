import 'package:cloud_firestore/cloud_firestore.dart';
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

  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    GoogleMapController? mapController;
    TextEditingController searchAddress = TextEditingController();

    _createMarkerImageFromAsset(context);

    return Scaffold(
      body: Stack(
        children: [
          reteriveMarker(mapController),
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

  Widget reteriveMarker(GoogleMapController? mapController) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('location')
          .withConverter(
            fromFirestore: (snapshot, _) =>
                snapshot.data() ?? Map<String, dynamic>(),
            toFirestore: (model, _) => Map<String, dynamic>.from(model as Map),
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null) return const CircularProgressIndicator();
        for (var i = 0; i < snapshot.data!.docs.length; i++) {
          MapPage.markers.add(Marker(
            markerId: MarkerId('Adding$i'),
            position: LatLng(snapshot.data!.docs[i]['point'].latitude,
                snapshot.data!.docs[i]['point'].longitude),
            icon: _markerIcon ?? BitmapDescriptor.defaultMarkerWithHue(45),
          ));
        }
        return GoogleMap(
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
            // setState(() {
            //   MapPage.markers.add(Marker(
            //     markerId: MarkerId('marker_${MapPage.markers.length}'),
            //     position: pos,
            //
            //   ));
            // });
            changeMapStyle(mapController);
            _firestore
                .collection('location')
                .add({'point': GeoPoint(pos.latitude, pos.longitude)});
            print(MapPage.markers.length);
          },
        );
      },
    );
  }
}
