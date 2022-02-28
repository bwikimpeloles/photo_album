import 'package:photo_album/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintPage extends StatelessWidget {
  final LocalAuthentication localAuth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () async {
          bool weCanCheckBiometrics = await localAuth.canCheckBiometrics;

          if (weCanCheckBiometrics) {
            bool authenticated = await localAuth.authenticateWithBiometrics(
              localizedReason: "Authenticate to open photo album.",
            );

            if (authenticated) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            }
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(
              Icons.fingerprint,
              size: 124.0,
            ),
            Text(
              "Touch to Login",
              style: GoogleFonts.passionOne(
                fontSize: 64.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
