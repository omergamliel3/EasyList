import 'package:flutter/material.dart';
//import 'package:map_view/map_view.dart';
import '../helpers/ensure_visible.dart';

class LocationInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  // Class Attribute
  final FocusNode _addressInputFocuNode =
      FocusNode(); // Create a FocusNode Instance for the FormTextField

  @override
  void initState() {
    // exe once when the page is loaded
    // call _updateLocation whenever the FocusNode changes
    _addressInputFocuNode.addListener(_updateLocation);
    getStaticMap();
    super.initState();
  }

  @override
  void dispose() {
    // exe once when the exiting the page
    // remove listener
    _addressInputFocuNode.removeListener(_updateLocation);
    super.dispose();
  }

  // get static map from the MAP_VIEW API
  void getStaticMap() {
    return;
    // // API key
    // final String googleMapsAPIkey = 'AIzaSyBbzch7OpPZ8DVA7NZsAU8iVLn2cpWtsb4';
    // // Creates a StaticMapProvider Instance
    // final StaticMapProvider staticMapViewProvider =
    //     StaticMapProvider(googleMapsAPIkey);
    // // getting the static Uri from the API, with the given marker
    // final Uri staticMapUri = staticMapViewProvider.getStaticUriWithMarkers(
    //   // set the location postion on the map
    //   [Marker('position', 'Position', 41.40338, 2.17403)],
    //   center: Location(41.40338, 2.17403),
    //   width: 500,
    //   height: 300,
    //   maptype: StaticMapViewType.roadmap,
    // );
    // // update _staticMapUri class propery
    // setState(() {
    //   _staticMapUri = staticMapUri;
    // });
  }

  // update location
  void _updateLocation() {
    print('location update');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          child: TextFormField(
            focusNode: _addressInputFocuNode,
          ),
          focusNode: _addressInputFocuNode,
        ),
        SizedBox(
          height: 10.0,
        ),
        //Image.network(_staticMapUri.toString()),
      ],
    );
  }
}
