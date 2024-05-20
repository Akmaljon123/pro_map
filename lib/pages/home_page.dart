import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pro_map/models/map_model.dart';
import 'package:pro_map/services/http_service.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart' hide Point;
import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MapModel? mapModel;
  TextEditingController controller = TextEditingController();
  bool isLoading = false;
  bool isTextLoading = false;
  bool isLive = false;
  bool car = true;
  late Position myPosition;
  List<MapObject> mapObjects = [];
  late YandexMapController yandexMapController;
  String speed = "0";

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    myPosition = await Geolocator.getCurrentPosition();
    isLoading = true;
    setState(() {});
    return myPosition;
  }

  void findMe() {
    yandexMapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: myPosition.latitude,
            longitude: myPosition.longitude,
          ),
          zoom: 20,
        ),
      ),
    );
  }

  void onMapCreated(YandexMapController controller) {
    yandexMapController = controller;
    yandexMapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: myPosition.latitude,
            longitude: myPosition.longitude,
          ),
          zoom: 15,
        ),
      ),
    );

    mapObjects.add(
      PlacemarkMapObject(
        mapId: const MapObjectId("address"),
        point: Point(
          latitude: myPosition.latitude,
          longitude: myPosition.longitude,
        ),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage("assets/images/gps.png"),
            scale: 0.3,
          ),
        ),
      ),
    );

    setState(() {});
  }

  void putLabel(
      {required double lan, required double lon, required String id}) {
    mapObjects.add(
      PlacemarkMapObject(
        mapId: MapObjectId(
            "address${lon.toString().substring(lon.toString().length - 4)}"),
        point: Point(
          latitude: lan,
          longitude: lon,
        ),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage("assets/images/gps.png"),
            scale: 0.3,
          ),
        ),
      ),
    );

    mapObjects.removeRange(1, mapObjects.length - 1);

    setState(() {});
  }

  Future<void> makeRoad(Position start, Point end) async {
    var road = await YandexDriving.requestRoutes(
      points: [
        RequestPoint(
          point: Point(
            latitude: start.latitude,
            longitude: start.longitude,
          ),
          requestPointType: RequestPointType.wayPoint,
        ),
        RequestPoint(
          point: Point(
            latitude: end.latitude,
            longitude: end.longitude,
          ),
          requestPointType: RequestPointType.wayPoint,
        ),
      ],
      drivingOptions: const DrivingOptions(),
    );

    var result = await road.result;
    if (result.routes!.isNotEmpty) {
      for (var element in result.routes ?? []) {
        mapObjects.add(
          PolylineMapObject(
            mapId: MapObjectId("route_${end.latitude.toString()}"),
            polyline: Polyline(
              points: element.geometry,
            ),
            strokeColor: Colors.green,
            strokeWidth: 4,
          ),
        );
      }
    }
    setState(() {});
  }

  Future<void> makeRoadBicycle(Position start, Point end) async {
    var road = await YandexBicycle.requestRoutes(
      points: [
        RequestPoint(
          point: Point(
            latitude: start.latitude,
            longitude: start.longitude,
          ),
          requestPointType: RequestPointType.wayPoint,
        ),
        RequestPoint(
          point: Point(
            latitude: end.latitude,
            longitude: end.longitude,
          ),
          requestPointType: RequestPointType.wayPoint,
        ),
      ],
      bicycleVehicleType: BicycleVehicleType.bicycle,
    );

    var result = await road.result;
    if (result.routes!.isNotEmpty) {
      for (var element in result.routes ?? []) {
        mapObjects.add(
          PolylineMapObject(
            mapId: MapObjectId("route_${end.latitude.toString()}"),
            polyline: Polyline(
              points: element.geometry,
            ),
            strokeColor: Colors.green,
            strokeWidth: 4,
          ),
        );
      }
    }
    setState(() {});
  }

  Future<void> goLive() async {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(),
    ).listen((data) {
      speed = data.speed.toStringAsFixed(3);

      yandexMapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: data.latitude,
              longitude: data.longitude,
            ),
            zoom: 20,
          ),
        ),
      );

      putLabel(
        lan: data.latitude,
        lon: data.longitude,
        id: data.latitude.toString(),
      );

      mapObjects.removeRange(1, mapObjects.length);
      setState(() {});
    });
  }

  Future<void> getData(String text) async {
    log("1234");
    isTextLoading = false;

    setState(() {});

    String? data = await HttpService.get(text);

    log("null");
    if (data != null) {
      mapModel = mapModelFromJson(data);
      log("if");
      isTextLoading = true;
      setState(() {});
    }
  }

  Future<GeocodeResponse> translate(String address) async {
    final YandexGeocoder yandexGeocoder =
        YandexGeocoder(apiKey: "68fdd329-67e5-4345-918a-63093d29de7a");

    final GeocodeResponse point = await yandexGeocoder
        .getGeocode(DirectGeocodeRequest(addressGeocode: address));

    return point;
  }

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text("Location App"),
        titleTextStyle: const TextStyle(
          fontSize: 22,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Column(
              children: [
                Visibility(
                  visible: !isLive,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                      controller: controller,
                      onChanged: (text) async {
                        await getData(text);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black87,
                        hintText: "Search",
                        hintStyle: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),

                        suffixIcon: IconButton(
                            onPressed: (){
                              isTextLoading = false;
                              setState(() {

                              });
                            },
                            icon: const Icon(
                              Icons.map,
                              color: Colors.white,
                            )
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                isTextLoading
                    ? Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    car = true;
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: const Icon(
                                      Icons.car_crash,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    car = false;
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: const Icon(
                                      Icons.motorcycle,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                      onTap: () async {
                                        GeocodeResponse data =
                                            await translate(controller.text);

                                        putLabel(
                                            lan: data.firstPoint!.lat,
                                            lon: data.firstPoint!.lon,
                                            id: "${data.firstPoint!.lon}$index");

                                        car
                                            ? await makeRoad(
                                                myPosition,
                                                Point(
                                                    latitude:
                                                        data.firstPoint!.lat,
                                                    longitude:
                                                        data.firstPoint!.lon))
                                            : makeRoadBicycle(
                                                myPosition,
                                                Point(
                                                    latitude:
                                                        data.firstPoint!.lat,
                                                    longitude:
                                                        data.firstPoint!.lon),
                                              );

                                        isTextLoading = false;
                                        setState(() {});
                                      },
                                      child: Column(
                                        children: [
                                          Text(
                                            "      ${mapModel!.results[index].title.text}",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          Text(
                                            "      ${mapModel!.results[index].subtitle.text}",
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ));
                                },
                                itemCount: mapModel!.results.length,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                      child: Column(
                        children: [
                          Visibility(
                            visible: !isTextLoading,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: ()async{
                                    car = true;
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: const Icon(
                                      Icons.car_crash,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                GestureDetector(
                                  onTap: (){
                                    car = false;
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: const Icon(
                                      Icons.motorcycle,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                      
                          Expanded(
                              child: YandexMap(
                                nightModeEnabled: true,
                                mode2DEnabled: true,
                                onMapCreated: onMapCreated,
                                onMapTap: (point) {
                                  putLabel(
                                      lon: point.longitude,
                                      lan: point.latitude,
                                      id: point.latitude.toString());
                                  makeRoad(myPosition, point);
                                },
                                mapObjects: mapObjects,
                              ),
                            ),
                        ],
                      ),
                    ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Text("Speed: $speed m/s"),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await goLive();
            },
            child: const Icon(Icons.run_circle),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              findMe();
            },
            child: const Icon(Icons.gps_fixed),
          ),
        ],
      ),
    );
  }
}
