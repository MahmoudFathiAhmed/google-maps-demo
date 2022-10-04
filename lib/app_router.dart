import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_demo/business_logic/cubit/maps/cubit/maps_cubit.dart';
import 'package:google_maps_demo/business_logic/cubit/phone_auth/cubit/phone_auth_cubit.dart';
import 'package:google_maps_demo/constants/strings.dart';
import 'package:google_maps_demo/data/repository/maps_repo.dart';
import 'package:google_maps_demo/data/web_services/places_webservices.dart';
import 'package:google_maps_demo/presentation/screens/login_screen.dart';
import 'package:google_maps_demo/presentation/screens/otp_screen.dart';

import 'presentation/screens/map_screen.dart';

class AppRouter {
  PhoneAuthCubit? phoneAuthCubit;

  AppRouter() {
    phoneAuthCubit = PhoneAuthCubit();
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mapScreen:
        return MaterialPageRoute(
          builder: (_) =>BlocProvider(
            create: (BuildContext context) =>
                MapsCubit(MapsRepository(PlacesWebservices())),
            child: MapScreen(),
          ),
        );

      case loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneAuthCubit>.value(
            value: phoneAuthCubit!,
            child: LoginScreen(),
          ),
        );

      case otpScreen:
        final phoneNumber = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneAuthCubit>.value(
            value: phoneAuthCubit!,
            child: OtpScreen(phoneNumber: phoneNumber),
          ),
        );
    }
  }
}