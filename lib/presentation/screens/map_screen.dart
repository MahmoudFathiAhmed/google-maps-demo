import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_demo/business_logic/cubit/maps/cubit/maps_cubit.dart';
import 'package:google_maps_demo/constants/my_colors.dart';
import 'package:google_maps_demo/data/models/place.dart';
import 'package:google_maps_demo/data/models/place_directions.dart';
import 'package:google_maps_demo/data/models/place_suggestion.dart';
import 'package:google_maps_demo/helpers/location_helper.dart';
import 'package:google_maps_demo/presentation/widgets/distance_and_time.dart';
import 'package:google_maps_demo/presentation/widgets/my_drawer.dart';
import 'package:google_maps_demo/presentation/widgets/place_item.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<PlaceSuggestion> places = [];
  FloatingSearchBarController controller = FloatingSearchBarController();
  static Position? position;
  Completer<GoogleMapController> _mapController = Completer();

  static final CameraPosition _myCurrentLocationCameraPosition = CameraPosition(
    bearing: 0.0,
    target: LatLng(position!.latitude, position!.longitude),
    tilt: 0.0,
    zoom: 17,
  );

  // these variables for getPlaceLocation
  Set<Marker> markers = Set();
  late PlaceSuggestion placeSuggestion;
  late Place selectedPlace;
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;
  late CameraPosition goToSearchedForPlace;

  void buildCameraNewPosition() {
    goToSearchedForPlace = CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      target: LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lng,
      ),
      zoom: 13,
    );
  }

  // these variables for getDirections
  PlaceDirections? placeDirections;
  var progressIndicator = false;
  late List<LatLng> polylinePoints;
  var isSearchedPlaceMarkerClicked = false;
  var isTimeAndDistanceVisible = false;
  late String time;
  late String distance;
  @override
  initState() {
    super.initState();
    getMyCurrentLocation();
  }

  Future<void> getMyCurrentLocation() async {
    position = await LocationHelper.getCurrentLocation().whenComplete(() {
      setState(() {});
    });
  }

  Widget buildMap() {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      markers: markers,
      initialCameraPosition: _myCurrentLocationCameraPosition,
      onMapCreated: (GoogleMapController controller) {
        controller.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
        _mapController.complete(controller);
      },
      polylines: placeDirections != null
          ? {
              Polyline(
                polylineId: const PolylineId('my_polyline'),
                color: MyColors.lightGrey,
                width: 2,
                points: polylinePoints,
              ),
            }
          : {},
    );
  }

  Future<void> _goToMyCurrentLocation() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(_myCurrentLocationCameraPosition));
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      borderRadius: BorderRadius.circular(15),
      backgroundColor: MyColors.darkGrey,
      controller: controller,
      elevation: 6,
      hintStyle: const TextStyle(fontSize: 18, color: MyColors.lightGrey),
      queryStyle: const TextStyle(fontSize: 18, color: MyColors.lightGrey),
      hint: 'search in Egypt....',
      border: BorderSide(style: BorderStyle.solid, color: MyColors.paleGreen),
      margins: const EdgeInsets.fromLTRB(20, 70, 20, 0),
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      height: 52,
      iconColor: MyColors.paleGreen,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 600),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      progress: progressIndicator,
      onQueryChanged: (query) {
        getPlacesSuggestions(query);
      },
      onFocusChanged: (_) {
        // hide distance and time row
        setState(() {
          isTimeAndDistanceVisible = false;
        });
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
              icon: Icon(Icons.place, color: MyColors.paleGreen),
              onPressed: () {}),
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSuggestionsBloc(),
              buildSelectedPlaceLocationBloc(),
              buildDiretionsBloc(),
            ],
          ),
        );
      },
    );
  }

  Widget buildDiretionsBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is DirectionsLoaded) {
          placeDirections = (state).placeDirections;

          getPolylinePoints();
        }
      },
      child: Container(),
    );
  }

  void getPolylinePoints() {
    polylinePoints = placeDirections!.polylinePoints
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
  }

  Widget buildSelectedPlaceLocationBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is PlaceLocationLoaded) {
          selectedPlace = (state).place;

          goToMySearchedForLocation();
          getDirections();
        }
      },
      child: Container(),
    );
  }

  void getDirections() {
    BlocProvider.of<MapsCubit>(context).emitPlaceDirections(
      LatLng(position!.latitude, position!.longitude),
      LatLng(selectedPlace.result.geometry.location.lat,
          selectedPlace.result.geometry.location.lng),
    );
  }

  Future<void> goToMySearchedForLocation() async {
    buildCameraNewPosition();
    final GoogleMapController controller = await _mapController.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(goToSearchedForPlace));
    buildSearchedPlaceMarker();
  }

  void buildSearchedPlaceMarker() {
    searchedPlaceMarker = Marker(
      position: goToSearchedForPlace.target,
      markerId: MarkerId('1'),
      onTap: () {
        buildCurrentLocationMarker();
        // show time and distance
        setState(() {
          isSearchedPlaceMarkerClicked = true;
          isTimeAndDistanceVisible = true;
        });
      },
      infoWindow: InfoWindow(title: "${placeSuggestion.description}"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    addMarkerToMarkersAndUpdateUI(searchedPlaceMarker);
  }

  void buildCurrentLocationMarker() {
    currentLocationMarker = Marker(
      position: LatLng(position!.latitude, position!.longitude),
      markerId: MarkerId('2'),
      onTap: () {},
      infoWindow: InfoWindow(title: "Your current Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersAndUpdateUI(currentLocationMarker);
  }

  void addMarkerToMarkersAndUpdateUI(Marker marker) {
    setState(() {
      markers.add(marker);
    });
  }

  void getPlacesSuggestions(String query) {
    final sessionToken = Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceSuggestions(query, sessionToken);
  }

  Widget buildSuggestionsBloc() {
    return BlocBuilder<MapsCubit, MapsState>(
      builder: (context, state) {
        if (state is PlacesLoaded) {
          places = (state).places;
          if (places.length != 0) {
            return buildPlacesList();
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  Widget buildPlacesList() {
    return ListView.builder(
        itemBuilder: (ctx, index) {
          return InkWell(
            onTap: () async {
              placeSuggestion = places[index];
              controller.close();
              getSelectedPlaceLocation();
              polylinePoints.clear();
              removeAllMarkersAndUpdateUI();
            },
            child: PlaceItem(
              suggestion: places[index],
            ),
          );
        },
        itemCount: places.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics());
  }

  void removeAllMarkersAndUpdateUI() {
    setState(() {
      markers.clear();
    });
  }

  void getSelectedPlaceLocation() {
    final sessionToken = Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceLocation(placeSuggestion.placeId, sessionToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          position != null
              ? buildMap()
              : Center(
                  child: Container(
                    child: CircularProgressIndicator(
                      color: MyColors.paleGreen,
                    ),
                  ),
                ),
          buildFloatingSearchBar(),
          isSearchedPlaceMarkerClicked
              ? DistanceAndTime(
                  isTimeAndDistanceVisible: isTimeAndDistanceVisible,
                  placeDirections: placeDirections,
                )
              : Container(),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 30),
        child: FloatingActionButton(
          backgroundColor: MyColors.paleGreen,
          onPressed: _goToMyCurrentLocation,
          child: Icon(Icons.place, color: MyColors.darkBcGrnd.withOpacity(.9)),
        ),
      ),
    );
  }
}
