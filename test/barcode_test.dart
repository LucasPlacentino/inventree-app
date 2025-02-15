/*
 * Unit testing for barcode scanning functionality.
 *
 * As the unit testing framework cannot really "scan" barcode data,
 * we will mock the scanned data by passing raw "barcode" data to the scanning framework.
 */

import "package:flutter_test/flutter_test.dart";

import "package:inventree/api.dart";
import "package:inventree/barcode.dart";
import "package:inventree/helpers.dart";
import "package:inventree/user_profile.dart";

import "package:inventree/inventree/stock.dart";

void main() {

  // Connect to the server
  setUpAll(() async {
    final prf = await UserProfileDBManager().getProfileByName("Test Profile");

    if (prf != null) {
      UserProfileDBManager().deleteProfile(prf);
    }

    bool result = await UserProfileDBManager().addProfile(
      UserProfile(
        name: "Test Profile",
        server: "http://localhost:12345",
        username: "testuser",
        password: "testpassword",
        selected: true,
      ),
    );

    assert(result);

    assert(await UserProfileDBManager().selectProfileByName("Test Profile"));
    assert(await InvenTreeAPI().connectToServer());
  });

  setUp(() async {
    // Clear the debug log
    clearDebugMessage();
  });

  group("Test BarcodeScanHandler:", () {
    // Tests for scanning a "generic" barcode

    var handler = BarcodeScanHandler();

    test("Empty Barcode", () async {
      // Handle an 'empty' barcode
      await handler.processBarcode(null, "");

      debugContains("Scanned barcode data: ''");
      debugContains("showSnackIcon: 'Barcode scan error'");

      assert(debugMessageCount() == 2);
    });

    test("Junk Data", () async {
      // test scanning 'junk' data

      await handler.processBarcode(null, "abcdefg");

      debugContains("Scanned barcode data: 'abcdefg'");
      debugContains("showSnackIcon: 'No match for barcode'");
    });

    test("Invalid StockLocation", () async {
      // Scan an invalid stock location
      await handler.processBarcode(null, '{"stocklocation": 999999}');

      debugContains("Scanned barcode data: '{\"stocklocation\": 999999}'");
      debugContains("showSnackIcon: 'No match for barcode'");
      assert(debugMessageCount() == 2);
    });

  });

  group("Test StockItemScanIntoLocationHandler:", () {
    // Tests for scanning a stock item into a location

    test("Scan Into Location", () async {

      final item = await InvenTreeStockItem().get(1) as InvenTreeStockItem?;

      assert(item != null);
      assert(item!.pk == 1);

      var handler = StockItemScanIntoLocationHandler(item!);

      await handler.processBarcode(null, '{"stocklocation": 7}');
      // Check the location has been updated
      await item.reload();
      assert(item.locationId == 7);

      debugContains("Scanned stock location 7");

      // Scan into a new location
      await handler.processBarcode(null, '{"stocklocation": 1}');
      await item.reload();
      assert(item.locationId == 1);

    });
  });

  group("Test StockLocationScanInItemsHandler:", () {
    // Tests for scanning items into a stock location

    test("Scan In Items", () async {
      final location = await InvenTreeStockLocation().get(1) as InvenTreeStockLocation?;

      assert(location != null);
      assert(location!.pk == 1);

      var handler = StockLocationScanInItemsHandler(location!);

      // Scan multiple items into this location
      for (int id in [1, 2, 11]) {
        await handler.processBarcode(null, '{"stockitem": ${id}}');

        var item = await InvenTreeStockItem().get(id) as InvenTreeStockItem?;

        assert(item != null);
        assert(item!.pk == id);
        assert(item!.locationId == 1);
      }

    });
  });

  group("Test ScanParentLocationHandler:", () {
    // Tests for scanning a location into a parent location

    test("Scan Parent", () async {
      final location = await InvenTreeStockLocation().get(7) as InvenTreeStockLocation?;

      assert(location != null);
      assert(location!.pk == 7);
      assert(location!.parentId == 4);

      var handler = ScanParentLocationHandler(location!);

      // Scan into new parent location
      await handler.processBarcode(null, '{"stocklocation": 1}');
      await location.reload();
      assert(location.parentId == 1);

      // Scan back into old parent location
      await handler.processBarcode(null, '{"stocklocation": 4}');
      await location.reload();
      assert(location.parentId == 4);

      debugContains("showSnackIcon: 'Scanned into location'");
    });
  });
}