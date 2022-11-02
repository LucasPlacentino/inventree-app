## Dev and build:
just do `flutter pub get` then `cp lib/dummy_dsn.dart lib/dsn.dart`  

then run or `flutter run` (or build)  

### Release:
make create a `key.properties` in /android/ and add the appropriate content (after having created a keystore from AndroidStudio):  
```
storePassword= ................................................
keyPassword= ................................................
keyAlias= ..........
storeFile=C:\\path\\to\\keystore.jks
```
then do `flutter run --release` (or build)  

# InvenTree Mobile App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Android](https://github.com/inventree/inventree-app/actions/workflows/android.yaml/badge.svg)
![iOS](https://github.com/inventree/inventree-app/actions/workflows/ios.yaml/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/inventree/inventree-app/badge.svg?branch=master)](https://coveralls.io/github/inventree/inventree-app?branch=master)

The InvenTree mobile / tablet application is a companion app for the [InvenTree stock management system](https://github.com/inventree/InvenTree).

Written in the [Flutter](https://flutter.dev/) environment, the app provides native support for Android and iOS devices.

## User Documentation

User documentation for the InvenTree mobile app can be found [within the InvenTree documentation](https://inventree.readthedocs.io/en/latest/app/app/).
