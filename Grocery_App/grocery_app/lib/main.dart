import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/providers/customer/cartProvider.dart';
import 'package:grocery_app/providers/customer/couponProvider.dart';
import 'package:grocery_app/providers/orderProvider.dart';
import 'package:grocery_app/providers/storeProvider.dart';
import 'package:grocery_app/providers/vendor/productProvider.dart';
import 'package:grocery_app/screens/chat/chatWithAdminApp.dart';
import 'package:grocery_app/screens/customer/cartScreen.dart';
import 'package:grocery_app/screens/customer/mainScreen.dart';
import 'package:grocery_app/screens/customer/myOrdersScreen.dart';
import 'package:grocery_app/screens/customer/payment/createNewCardScreen.dart';
import 'package:grocery_app/screens/customer/payment/creditCardList.dart';
import 'package:grocery_app/screens/customer/payment/stripe/existingCards.dart';
import 'package:grocery_app/screens/customer/payment/paymentHome.dart';
import 'package:grocery_app/screens/customer/productDetailsScreen.dart';
import 'package:grocery_app/screens/customer/productListScreen.dart';
import 'package:grocery_app/screens/customer/profileScreen.dart';
import 'package:grocery_app/screens/customer/profileUpdateScreen.dart';
import 'package:grocery_app/screens/customer/vendorHomeScreen.dart';
import 'package:grocery_app/screens/vendor/addEditCouponScreen.dart';
import 'package:grocery_app/screens/vendor/addNewProductVendorScreen.dart';
import 'package:provider/provider.dart';
import 'providers/authProvider.dart';
import 'providers/vendor/authVendorProvider.dart';
import 'providers/locationProvider.dart';
import 'screens/customer/homeScreen.dart';
import 'screens/customer/landingScreen.dart';
import 'screens/loginScreen.dart';
import 'screens/mapScreen.dart';
import 'screens/splashScreen.dart';
import 'screens/vendor/homeVendorScreen.dart';
import 'screens/vendor/loginVendorScreen.dart';
import 'screens/vendor/registerVendorSceen.dart';
import 'screens/vendor/resetPasswordScreen.dart';
import 'screens/welcomeScreen.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        //Providers of Customers and Vendors App
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),

        //Providers of Customers
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StoreProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CouponProvider(),
        ),

        //Providers of Vendors
        ChangeNotifierProvider(
          create: (_) => AuthVendorProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF84c225),
        fontFamily: 'Lato',
      ),
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.id,
      routes: <String, WidgetBuilder>{
        SplashScreen.id: (context) => SplashScreen(),
        ChatWithAdminAppScreen.id: (context) => ChatWithAdminAppScreen(),

        //Customer App
        HomeScreen.id: (context) => HomeScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        MapScreen.id: (context) => MapScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        LandingScreen.id: (context) => LandingScreen(),
        MainScreen.id: (context) => MainScreen(),
        VendorHomeScreen.id: (context) => VendorHomeScreen(),
        ProductListScreen.id: (context) => ProductListScreen(),
        ProductDetailsScreen.id: (context) => ProductDetailsScreen(),
        CartScreen.id: (context) => CartScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        UpdateProfile.id: (context) => UpdateProfile(),
        ExistingCardsPage.id: (context) => ExistingCardsPage(),
        PaymentHome.id: (context) => PaymentHome(),
        MyOrders.id: (context) => MyOrders(),
        CreditCardList.id: (context) => CreditCardList(),
        CreateNewCreditCard.id: (context) => CreateNewCreditCard(),

        //Vendor App
        RegisterVendorSceen.id: (context) => RegisterVendorSceen(),
        HomeVendorScreen.id: (context) => HomeVendorScreen(),
        LoginVendorScreen.id: (context) => LoginVendorScreen(),
        ResetPassword.id: (context) => ResetPassword(),
        AddNewProduct.id: (context) => AddNewProduct(),
        AddEditCoupon.id: (context) => AddEditCoupon(),
      },
    );
  }
}
