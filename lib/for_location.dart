import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_map/locat_notifier.dart';
import 'package:provider/provider.dart';

class ForLocation extends StatelessWidget {
  ForLocation({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocatNotifier()..initialLocationCamera(),
      child: Consumer<LocatNotifier>(
        builder: (context, provoider, child) {
          if (provoider.initialCamera == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Scaffold(
              body: Stack(
            children: [
              SizedBox(
                child: Column(
                  children: [
                    Expanded(
                      child: FlutterMap(
                          mapController: provoider.mapController,
                          options: MapOptions(
                            initialCenter: provoider.initialCamera!,
                            initialZoom: provoider.initialZoom!,
                            minZoom: 1.0,
                            maxZoom: 20,
                            interactionOptions: InteractionOptions(
                                rotationThreshold: 20.0,
                                pinchZoomThreshold: 0.5,
                                pinchMoveThreshold: 40.0,
                                flags: InteractiveFlag.pinchZoom |
                                    InteractiveFlag.drag |
                                    // InteractiveFlag.rotate |
                                    InteractiveFlag.doubleTapDragZoom |
                                    InteractiveFlag.scrollWheelZoom),
                            onTap: (_, point) {
                              provoider.pickLocation(point);
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: ['a', 'b', 'c'],
                            ),
                            if (provoider.pickLatLng != null)
                              MarkerLayer(markers: [
                                Marker(
                                    point: provoider.pickLatLng!,
                                    child: Icon(
                                      Icons.heart_broken,
                                      color: Colors.pinkAccent.shade100,
                                      size: 38,
                                    ))
                              ]),
                          ]),
                    ),
                    if (provoider.isbusy) LinearProgressIndicator(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14,vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                  controller: provoider.addressLine,
                                  decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      hintText: 'Address Line',
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black)),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                          ? 'Required'
                                          : null),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: provoider.city,
                                      decoration: InputDecoration(
                                          hintText: 'City',
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black)),
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? 'Required'
                                              : null,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: provoider.state,
                                      decoration: InputDecoration(
                                          hintText: 'State',
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black)),
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? 'Required'
                                              : null,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: provoider.country,
                                      decoration: InputDecoration(
                                          hintText: 'Country',
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black)),
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? 'Required'
                                              : null,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: provoider.postalCode,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          hintText: 'Postal Code',
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black)),
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return 'Required';
                                        if (int.tryParse(value) == null)
                                          return 'Postal Code required number';
                                        if (value.length < 5)
                                          return 'Postal code must be at least 5 digits';
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 2),
                                      fixedSize: Size(360, 45),
                                      side: BorderSide(
                                          color:
                                              Color.fromARGB(255, 184, 184, 184)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white),
                                  onPressed: () async {
                                    // if (_formKey.currentState!.validate()) {
                                    //   provider.addNewAddress();
                                    //   _formKey.currentState!.reset();
                                    //   provider.addressLine.clear();
                                    //   provider.city.clear();
                                    //   provider.state.clear();
                                    //   provider.country.clear();
                                    //   provider.postalCode.clear();
                                    //   AppNavigator.pop(context);
                                    // }
                                  },
                                  child: Text(
                                    'Add Address',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ))
                            ],
                          )),
                    ),
                  ],
                ),
              ),
              Positioned(
                width: 42,
                height: 42,
                bottom: 270,
                right: 18,
                child: FloatingActionButton(
                  heroTag: 'recenter',
                  onPressed: () {
                    final ctl = provoider.mapController!;
                    final center = provoider.initialCamera!;
                    final zoom = provoider.initialZoom!;

                    ctl.move(center, zoom);
                  },
                  child: const Icon(Icons.my_location,size: 30,color: Colors.blue,),
                ),
              )
            ],
          ));
        },
      ),
    );
  }
}
