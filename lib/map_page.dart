import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mao/constants.dart';
import 'package:google_mao/resources/location_function.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'api_keys/api_key.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  String? _currentAddress;
  Position? _currentPosition;
  //* – GoogleMapController: It’s the controller for a single GoogleMap instance running on the host platform.
  //* This controller is like any other controller be it TextEditingController,
  //* this manages various functionalities like camera position, zoom, animation, etc.
  final Completer<GoogleMapController> _controller = Completer();
  final double _zoom = 10;
  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);
  List<LatLng> polylineCoordinates = [];
  CameraPosition _initialPosition =
      const CameraPosition(target: LatLng(26.8206, 30.8025));
  final Set<Marker> _markers = Set();
  // void getPolyPoints() async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     googleApiKey,
  //     PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //     PointLatLng(
  //       destination.latitude,
  //       destination.longitude,
  //     ),
  //   );
  //   if (result.points.isEmpty) {
  //     result.points.forEach(
  //       (PointLatLng point) => polylineCoordinates.add(
  //         LatLng(point.latitude, point.longitude),
  //       ),
  //     );
  //     setState(() {});
  //   }
  // }
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  MapType _defaultMapType = MapType.normal;

  void _changeMapType() {
    setState(() {
      _defaultMapType = _defaultMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  void initState() {
    // getPolyPoints();

    super.initState();
  }

  Resources resources = Resources();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Google map",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: _defaultMapType,
            //* Marker marks a geographical location on the map
            markers: _markers,

            ///* – initialCameraPosition: This gives the starting position of the map when it is opened for the first time.
            ///*    Here, we gave the Latitude and Longitude of Egypt,
            ///* using the CameraPosition Widget which takes the LatLng in its target property.
            ///*    The Camera here describes the view of the user i.e what position in the map should the user be able to view.///
            initialCameraPosition: _initialPosition,
            //* – onMapCreated: This method is called when the map is created and takes the GoogleMapController as its parameter.
            onMapCreated: _onMapCreated,
            // initialCameraPosition: CameraPosition(
            //   target: sourceLocation,
            //   zoom: 14.5,
            // ),
            // polylines: {
            //   Polyline(
            //     polylineId: PolylineId("route"),
            //     points: polylineCoordinates,
            //     color: primaryColor,
            //     width: 6,
            //   ),
            // },
            // markers: {
            //   Marker(
            //     markerId: MarkerId(
            //       "source",
            //     ),
            //     position: sourceLocation,
            //   ),
            //   Marker(
            //     markerId: MarkerId(
            //       "destination",
            //     ),
            //     position: destination,
            //   ),
            // },
            myLocationEnabled: true,
          ),
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 80, right: 10),
                alignment: Alignment.topRight,
                child: Column(children: <Widget>[
                  FloatingActionButton(
                      elevation: 5,
                      backgroundColor: Colors.teal[200],
                      onPressed: () {
                        _changeMapType();
                        log('Changing the Map Type');
                      },
                      child: const Icon(Icons.layers)),
                ]),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(right: 10, bottom: 100),
                alignment: Alignment.topRight,
                child: Column(children: <Widget>[
                  FloatingActionButton(
                      elevation: 5,
                      backgroundColor: Colors.teal[200],
                      onPressed: () {
                        // resources.handleLocationPermission(context);
                        _getCurrentPosition();
                        // _moveToCurrentLocation();
                        log('location function');
                      },
                      child: const Icon(Icons.location_searching_outlined)),
                ]),
              ),
            ],
          ),
        ],
      ),
      drawer: _drawer(),
    );
  }

  Widget _drawer() {
    return Drawer(
      elevation: 16.0,
      child: Column(
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text("xyz"),
            accountEmail: Text("xyz@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("xyz"),
            ),
            otherAccountsPictures: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text("abc"),
              )
            ],
          ),
          const ListTile(
            title: Text("Places"),
            leading: Icon(Icons.flight),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              _goToNewYork();
              Navigator.of(context).pop();
            },
            title: new Text("New York"),
            trailing: new Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }

  Future<void> _goToNewYork() async {
    double lat = 40.7128;
    double long = -74.0060;
    GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, long), _zoom));
    _markers.add(
      Marker(
        //* markerId is the unique id of each marker and position property takes the LatLng of the location.
        markerId: const MarkerId('newyork'),
        position: LatLng(lat, long),
      ),
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    _moveToCurrentLocation();
    return true;
  }

  Future<void> _moveToCurrentLocation() async {
    double lat = _currentPosition!.latitude ?? 10.850516;
    double long = _currentPosition!.longitude ?? 76.271080;
    GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, long), _zoom));
    _markers.add(
      Marker(
        //* markerId is the unique id of each marker and position property takes the LatLng of the location.
        markerId: const MarkerId('CurrentLocation'),
        position: LatLng(lat, long),
      ),
    );
  }
}
