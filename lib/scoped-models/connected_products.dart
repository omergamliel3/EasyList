import 'dart:convert';
import 'dart:async';
import 'dart:io';

import '../models/auth.dart';
import 'package:my_app/models/product.dart';
import 'package:my_app/models/user.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:mime/mime.dart';

class ConnectedProductsModel extends Model {
  // Class Attributes
  List<Product> _products = []; // 'Master List of Product'
  String _selProductId; // selected product index for the given method
  User _authenticatedUser;
  bool _isLoading = false;
}

// ProductsModel Class
class ProductsModel extends ConnectedProductsModel {
  // Class Attributes
  bool _showFavorites = false;

  List<Product> get allProducts {
    // return a copy of _products
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    // return new filtered list of favorites product
    if (_showFavorites) {
      return List.from(
          _products.where((Product product) => product.isFavorite).toList());
    }
    // return a copy of _products
    return List.from(_products);
  }

  // select product index first in the list where product.id == selected product id (_selProductId)
  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  // selectedProductId getter
  String get selectedProductId {
    return _selProductId;
  }

  // displayFavoriteOnly getter
  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  // selectedProdcut getter
  Product get selectedProduct {
    if (selectedProductId == null) {
      return null;
    }
    // select first product in the list where product.id == selected product id (_selProductId)
    return _products.firstWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  // upload image method
  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-flutter-products-ceb8f.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(
        mimeTypeData[0],
        mimeTypeData[1],
      ),
    );
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenticatedUser.token}';

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong');
        print(json.decode(response.body));
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  // add product method
  Future<bool> addProduct(String title, String description, double price,
      File image, String location) async {
    // loading until we get response from firebase
    _isLoading = true;
    // notify ScopedModelDescendant object that somthing has changed
    notifyListeners();
    final uploadData = await uploadImage(image);
    if (uploadData == null) {
      print('Upload Failed!');
      return false;
    }
    // Create Map object to post json
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl']
    };
    try {
      final http.Response response = await http.post(
          'https://flutter-products-ceb8f.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          // encode Map to json
          body: jsonEncode(productData));
      // checks for nagative status code to handle backend error
      if (response.statusCode != 200 && response.statusCode != 201) {
        // done loading after we get response from the http request
        _isLoading = false;
        // notify ScopedModelDescendant object that somthing has changed
        notifyListeners();
        // return future value for further succes checks
        return false;
      }
      // response data from the http post
      // decode json to Map
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          price: price,
          image: uploadData['imageUrl'],
          imagePath: uploadData['imagePath'],
          location: location,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      // add newProduct to local list _products
      _products.add(newProduct);
      // done loading after we get response from the http request
      _isLoading = false;
      // notify ScopedModelDescendant object that somthing has changed
      notifyListeners();
      // return future value for further succes checks
      return true;
    } catch (error) {
      // done loading after we get response from the http request
      _isLoading = false;
      // notify ScopedModelDescendant object that somthing has changed
      notifyListeners();
      // return future value for further succes checks
      return false;
    }
  }

  // update product method
  Future<bool> updateProduct(String title, String description, double price,
      File image, String location) async {
    // loading until we get response from firebase
    _isLoading = true;
    // notify ScopedModelDescendant object that somthing has changed
    notifyListeners();
    // image Url & Path set from local
    String imageUrl = selectedProduct.image;
    String imagePath = selectedProduct.imagePath;
    if (image != null) {
      final uploadData = await uploadImage(image);
      if (uploadData == null) {
        print('Upload Failed!');
        return false;
      }
      // image Url & Path set from backend
      imageUrl = uploadData['imageUrl'];
      imagePath = uploadData['imagePath'];
    }
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'location': location,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
    };
    try {
      // send request to replace the product data (product id) with the new data (updateData)
      await http.put(
          'https://flutter-products-ceb8f.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
          body: jsonEncode(updateData));
      // listen to the event when its done (we get response from firebase)
      // done loading after we get response from the http request
      _isLoading = false;
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          price: price,
          image: imageUrl,
          imagePath: imagePath,
          location: location,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      // applying new product into selected Product index
      _products[selectedProductIndex] = updatedProduct;
      // notify ScopedModelDescendant object that somthing has changed
      notifyListeners();
      // return future value for further succes checks
      return true;
    } catch (error) {
      // if an error has been accrued
      print(error);
      // done loading after we get response from the http request
      _isLoading = false;
      // notify ScopedModelDescendant object that somthing has changed
      notifyListeners();
      // return future value for further succes checks
      return false;
    }
  }

  // delete product method
  Future<bool> deleteProduct() {
    // loading until we get response from firebase
    _isLoading = true;
    // store product's id before we delete it to the http request
    final String deleteProductId = selectedProduct.id;
    // remove product from _products list
    _products.removeAt(selectedProductIndex);
    // selected product index = null after deleting it
    _selProductId = null;
    // notify ScopedModelDescendant object that somthing has changed
    notifyListeners();
    return http
        .delete(
            'https://flutter-products-ceb8f.firebaseio.com/products/$deleteProductId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      // done loading after we get response from the http request
      _isLoading = false;
      // notify ScopedModelDescendant object that somthing has changed
      notifyListeners();
      // return future value for further succes checks
      return true;
      // if an error has been accrued
    }).catchError((error) {
      // done loading after we get response from the http request
      _isLoading = false;
      // notify ScopedModelDescendant object that somthing has changed
      notifyListeners();
      // return future value for further succes checks
      return false;
    });
  }

  // fetch products from firebase
  Future<Null> fetchProducts(
      {bool customLoading = true, onlyForUser = false, clearExisting = false}) {
    // custom loading
    if (customLoading)
      // loading until we get response from firebase
      _isLoading = true;
    if (clearExisting) {
      _products = [];
    }
    // notify ScopedModelDescendant object that somthing has changed
    notifyListeners();
    // http get request to get data from the response object
    return http
        .get(
            'https://flutter-products-ceb8f.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      // checks for nagative status code to handle backend error
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final List<Product> fetchedProductList = [];
      // convert the response json to Map productListData to get all product data from the server
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) { // if the data is empty
        _isLoading = false;
        notifyListeners();
        return;
      }
      // for each item in productListData execute the given function
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            location: productData['location'],
            image: productData['imageUrl'],
            imagePath: productData['imagePath'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            isFavorite: productData['wishlistUsers'] == null
                ? false
                : (productData['wishlistUsers'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        // add the product to the fetched product list
        fetchedProductList.add(product);
      });
      // If onlyForUser is true, search the list where the
      // user email equals to the authenticatedUser email
      _products = onlyForUser
          ? fetchedProductList.where((Product product) {
              return product.userEmail == _authenticatedUser.email;
            })
          : fetchedProductList;
      // custom loading
      if (customLoading) {
        _isLoading = false;
      }
      notifyListeners();
      _selProductId = null;
      // if an error has been accrued
    }).catchError((error) {
      // done loading after we get response from the http request
      _isLoading = false;
      // notify ScopedModelDescendant object that somthing has changed
      notifyListeners();
      // return future value for further succes checks
      return;
    });
  }

  // select product method, uses before add, update, remove product methods
  // external managment of the product index
  void selectProduct(String productId) {
    _selProductId = productId;
    if (productId != null) {
      // notify ScopedModelDescendant object that somthing has changed
      notifyListeners();
    }
  }

// NEWLY ADDED => Add the "toggledProduct" as an argument to the method
  void toggleProductFavoriteStatus(Product toggledProduct) async {
    final bool isCurrentlyFavorite = toggledProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    // NEWLY ADDED => Get the index of the product passed into the method
    final int toggledProductIndex = _products.indexWhere((Product product) {
      return product.id == toggledProduct.id;
    });
    final Product updatedProduct = Product(
        id: toggledProduct.id,
        title: toggledProduct.title,
        description: toggledProduct.description,
        price: toggledProduct.price,
        image: toggledProduct.image,
        imagePath: toggledProduct.imagePath,
        location: toggledProduct.location,
        userEmail: toggledProduct.userEmail,
        userId: toggledProduct.userId,
        isFavorite: newFavoriteStatus);
    _products[toggledProductIndex] =
        updatedProduct; // Use the "toggledProductIndex" derived earlier in the method
    notifyListeners();
    http.Response response;
    if (newFavoriteStatus) {
      response = await http.put(
          'https://flutter-products-ceb8f.firebaseio.com/products/${toggledProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
          'https://flutter-products-ceb8f.firebaseio.com/products/${toggledProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product updatedProduct = Product(
          id: toggledProduct.id,
          title: toggledProduct.title,
          description: toggledProduct.description,
          price: toggledProduct.price,
          image: toggledProduct.image,
          imagePath: toggledProduct.imagePath,
          location: toggledProduct.location,
          userEmail: toggledProduct.userEmail,
          userId: toggledProduct.userId,
          isFavorite: !newFavoriteStatus);
      _products[toggledProductIndex] = updatedProduct;
      notifyListeners();
    }
    // _selProductId = null; => This has to be removed/ commented out!
  }

  // toggle showFavorites
  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    // notify ScopedModelDescendant object that somthing has changed
    notifyListeners();
  }
}

// State Managment Object

class UserModel extends ConnectedProductsModel {
  // timer property
  Timer _authTimer;
  // PublishSubjects - true when authenticated / auto , false when logout
  PublishSubject<bool> _userSubject = PublishSubject();
  // _userSubject getter
  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  User get user {
    // _authenticatedUser getter
    return _authenticatedUser;
  }

  // set up login authenticated
  Future<Map<String, dynamic>> authenticate(
      {String email, String password, AuthMode mode = AuthMode.Login}) async {
    // creating auth data map to convert it to json in http post request
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };
    // loading until we get response from firebase
    _isLoading = true;
    // notify ScopedModelDescendant object that somthing has changed
    notifyListeners();
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        // wait for http post response
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyA2FSasdrJpDcJLHnqZ5CbgIhFUaIPZ5OM',
        body: jsonEncode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      // AuthMode = Signup
      response = await http.post(
        // wait for http post response
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyA2FSasdrJpDcJLHnqZ5CbgIhFUaIPZ5OM',
        body: jsonEncode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }
    // convert json into response data map
    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true; //
    String message = 'Something went wrong!'; // message to display the response
    if (responseData.containsKey('idToken')) {
      message = 'Something went wrong!'; // success message
      hasError = false;
      final String idToken = responseData['idToken'];
      // local auth to store user data
      _authenticatedUser =
          User(id: responseData['localId'], email: email, token: idToken);

      // set auto logout
      int expiresIn = int.parse(responseData['expiresIn']);
      setAuthTimeout(expiresIn);
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime = now.add(Duration(seconds: expiresIn));

      // store data on the device
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', idToken);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
      // error handling
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'email not found'; // EMAIL_NOT_FOUND error message
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'invalid password'; // INVALID_PASSWORD error message
    } else if (responseData['error']['message'] == 'USER_DISABLED') {
      message =
          'your account has been disable by an administrator'; // USER_DISABLED error message
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'this email already exists'; // email error message
    }
    // loading until we get response from firebase
    _isLoading = false;
    // notify ScopedModelDescendant object that somthing has changed
    notifyListeners();
    // return future value (map)
    return {'success': !hasError, 'message': message};
  }

  // auto login user
  void autoAuthenticate() async {
    // reference to sharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // getting prefs
    String token = prefs.getString('token');
    String expiryTimeString = prefs.getString('expiryTime');

    if (token != null) {
      // if token != null continue authenticate
      final DateTime now = DateTime.now();
      // convert [expiryTimeString] (String format) to [parsedExpiryTime] (DateTime format)
      final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
      // if [parsedExpiryTime] before now then user expires, quit Auth.
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      // the user does not expires, continue Auth
      String userEmail = prefs.getString('userEmail');
      String userId = prefs.getString('userId');
      final int tokenLifeSpan = parsedExpiryTime.difference(now).inSeconds;
      // create instance of User to _authenticatedUser
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      // set auth timeout of the remaining time of the user
      setAuthTimeout(tokenLifeSpan);
      notifyListeners();
    }
  }

  // set auto logout timeout when login
  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
    notifyListeners();
  }

  // logout user
  void logout() async {
    // set _authenticatedUser to navigate in main to auth
    _authenticatedUser = null;
    // cancel exting timer logout
    _authTimer.cancel();
    // userSubject event listener is set to false
    _userSubject.add(false);
    // null product id when logout to reset the page correctly
    _selProductId = null;
    // remove all stored prefs to null
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }
}

// Utility Model Class

class UtilityModel extends ConnectedProductsModel {
  // isLoading getter
  bool get isLoading {
    return _isLoading;
  }
}
