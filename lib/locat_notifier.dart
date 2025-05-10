import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocatNotifier extends ChangeNotifier{

  TextEditingController addressLine = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController postalCode = TextEditingController();

  LatLng? _initialCamera;
  LatLng? _pickLatLng;
  double? _initialZoom;
  bool _isbusy = false;

  MapController? mapController = MapController();

  LatLng? get initialCamera => _initialCamera;
  LatLng? get pickLatLng => _pickLatLng;
  double? get initialZoom => _initialZoom;
  bool get isbusy => _isbusy;

  Future<Position> getLocationPermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()){
      throw Exception('Location service is deniced');
    }
    var check = await Geolocator.checkPermission();
    if (check == LocationPermission.denied){
      check = await Geolocator.requestPermission();
      if (check == LocationPermission.denied){
        throw Exception('Location service is deniced');
      }
    }
    if (check == LocationPermission.deniedForever){
      await Geolocator.openAppSettings();
      throw Exception('Location service is deniced');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0
      )
    );
    }
    catch (e) {
      throw Exception('Location service is dencied by user!');
    }
  }

  Future<void> initialLocationCamera() async {
    try {
      final currentLocation = await getLocationPermission();
      _initialCamera = LatLng(currentLocation.latitude, currentLocation.longitude);
      _initialZoom = 16.0;
      
    }
    catch (_){
      _initialCamera = LatLng(21, 96);
      _initialZoom = 16;
    }
    notifyListeners();
  }

  Future<void> pickLocation(LatLng latlng) async {
    _isbusy = true;
    _pickLatLng = latlng;
    notifyListeners();

    try {
      final places = await placemarkFromCoordinates(latlng.latitude, latlng.longitude);

      if (places.isNotEmpty){
        final placeMark = places.first;

        final number = placeMark.subThoroughfare ?? '';
        final street = placeMark.thoroughfare ?? '';

        addressLine.text =  [
          if (street.isNotEmpty) street,
          if (number.isNotEmpty) number,
        ].join('');
        city.text = placeMark.locality ?? '';
        state.text = placeMark.administrativeArea ?? '';
        country.text = placeMark.country ?? '';
        postalCode.text = placeMark.postalCode ?? '';
      }
    }
    catch (e){
      debugPrint('Failed to get the current Locatio');
    }
    finally {
      _isbusy = false;
      notifyListeners();
    }
  }  
  
  
}