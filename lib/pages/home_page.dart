import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  late Position myPosition;
  List<MapObject> mapObjects = [];
  late YandexMapController yandexMapController;

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
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    myPosition = await Geolocator.getCurrentPosition();
    isLoading = true;
    setState(() {});
    return myPosition;
  }

  void findMe(){
    yandexMapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: Point(
                latitude: myPosition.latitude, 
                longitude: myPosition.longitude,
            ),
            zoom: 20
        )
      )
    );
  }

  void onMapCreated(YandexMapController controller){
    yandexMapController = controller;
    yandexMapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
              latitude: myPosition.latitude,
              longitude: myPosition.longitude
          ),
          zoom: 15
        )
      )
    );

    mapObjects.add(
      PlacemarkMapObject(
          mapId: const MapObjectId("address"),
          point: Point(
              latitude: myPosition.latitude,
              longitude: myPosition.longitude
          ),
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage("assets/images/gps.png"),
                scale: 0.3
            ),
          )
      )
    );

    setState(() {});
  }

  void putLabel(Point point){
    mapObjects.add(
        PlacemarkMapObject(
            mapId: MapObjectId("address${point.longitude.toString().substring(point.longitude.toString().length-4)}"),
            point: Point(
                latitude: point.latitude,
                longitude: point.longitude
            ),
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage("assets/images/gps.png"),
                  scale: 0.3
              ),
            )
        )
    );

    mapObjects.removeRange(1, mapObjects.length-1);

    setState(() {});
  }

  Future<void> makeRoad(Position start, Point end)async{
    var road = await YandexDriving.requestRoutes(
        points: [
          RequestPoint(
              point: Point(
                  latitude: start.latitude,
                  longitude: start.longitude
              ),
              requestPointType: RequestPointType.wayPoint
          ),

          RequestPoint(
              point: Point(
                  latitude: end.latitude,
                  longitude: end.longitude
              ),
              requestPointType: RequestPointType.wayPoint
          )
        ],
        drivingOptions: const DrivingOptions()
    );

    var result = await road.$2;
    result.routes?.asMap().forEach(
        (key, value){
          mapObjects.add(
            PolylineMapObject(
                mapId: MapObjectId("route_$key"),
                polyline: Polyline(points: value.geometry.points),
                strokeColor: Colors.red,
                strokeWidth: 4
            )
          );
        }
    );

    setState(() {});

  }

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Stack(
        children: [
          YandexMap(
            nightModeEnabled: true,
            mode2DEnabled: true,
            onMapCreated: onMapCreated,
            onMapTap: (point){
              putLabel(point);
              makeRoad(myPosition, point);
            },
            mapObjects: mapObjects,
          )
        ],
      ) : const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          findMe();
        },
        child: const Icon(
          Icons.gps_fixed
        ),
      ),
    );
  }
}
