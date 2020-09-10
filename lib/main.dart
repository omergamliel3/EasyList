import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/shared/adaptive_theme.dart';
import 'package:my_app/widgets/helpers/custom_route.dart';
import 'package:scoped_model/scoped_model.dart';
//import 'package:map_view/map_view.dart';

import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/products.dart';
import './pages/product.dart';
import './pages/create_account.dart';

import './scoped-models/main.dart';
import 'models/product.dart';

// main function
void main() {
  //debugPaintSizeEnabled = true;

  // Disable lanscape mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  // Set Map View API Key.
  //MapView.setApiKey("AIzaSyBbzch7OpPZ8DVA7NZsAU8iVLn2cpWtsb4");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  // create state method
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  // Class Attributes

  // MethodChannel
  final _platformChannel = MethodChannel('samples.flutter.dev/battery');

  // MainModel
  final MainModel _model =
      MainModel(); // Create ScopedModel Instance for intire app
  bool _isAuthenticated = false;

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await _platformChannel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level is $result';
    } catch (error) {
      batteryLevel = 'Failed to get battery level. The Exeption: $error';
    }
    print(batteryLevel);
  }

  @override // initialized ones when the app starts
  void initState() {
    _model.autoAuthenticate();
    // create an even listener
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    // Get Battery Level
    _getBatteryLevel();
    super.initState();
  }

  // ProductPage Route method
  MaterialPageRoute _productPageRoute(Product product) {
    return CustomRoute<bool>(
        builder: (BuildContext context) =>
            !_isAuthenticated ? AuthPage() : ProductPage(product));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        title: 'EasyList',
        // App Theme
        theme: getAdaptiveThemeData(context),
        routes: {
          // if autoAuthenticate goes to [ProductsPage], if not goes to [AuthPage].
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ProductsPage(_model),
          '/create_account': (BuildContext context) => CreateAccount(),
          '/admin': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ProductsAdminPage(_model),
        },
        // Generate our own custom Routes
        onGenerateRoute: (RouteSettings settings) {
          // _isAuthenticated check
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => AuthPage());
          }
          final List<String> pathElements = settings.name.split('/');

          // validation check 1
          if (pathElements[0] != '') {
            return null;
          }
          // validation check 2
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                _model.allProducts.firstWhere((Product product) {
              return productId == product.id;
            });
            return _productPageRoute(product);
          }
          return null;
        },
        // Unknown Route is entered
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? AuthPage() : ProductsPage(_model));
        },
      ),
    );
  }
}
