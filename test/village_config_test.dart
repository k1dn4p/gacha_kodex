import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:gacha_codex/advent/village_config.dart';

void main() {
  test('every Daily_Open asset is registered once, for all 25 dates', () {
    final dates = {for (var id = 1; id <= 25; id++) id};
    expect(villageDays(2026).map((day) => day.dayId).toSet(), dates);
    expect(villageHotspots.map((spot) => spot.dayId).toSet(), dates);
    expect(villageHotspots.length, 25);
    final overlays =
        villageLayers.where((layer) => layer.dayId != null).toList();
    final files = Directory(villageDailyAssetRoot)
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.png'))
        .map((file) => file.path.replaceAll('\\', '/'))
        .toSet();
    expect(overlays.map((layer) => layer.assetPath).toSet(), files);
    expect(overlays.length, files.length);
    expect(overlays.map((layer) => layer.dayId).toSet(), dates);
    for (final layer in overlays) {
      final name = layer.assetPath.split('/').last;
      final dayFromFile = RegExp(r'^day(\d{2})_', caseSensitive: false)
          .firstMatch(name)!
          .group(1)!;
      expect(layer.dayId, int.parse(dayFromFile));
      final header =
          ByteData.sublistView(File(layer.assetPath).readAsBytesSync());
      final width = header.getUint32(16);
      final height = header.getUint32(20);
      expect(layer.bounds.width / layer.bounds.height,
          closeTo(width / height, 0.000001),
          reason: layer.assetPath);
      expect(layer.isVisible({}), isFalse);
      expect(layer.isVisible({layer.dayId!}), isTrue);
      expect(villageBounds.contains(layer.bounds.topLeft), isTrue);
      expect(
          layer.bounds.right, lessThanOrEqualTo(villageBounds.right + 0.001));
      expect(
          layer.bounds.bottom, lessThanOrEqualTo(villageBounds.bottom + 0.001));
    }
  });

  test('date targets are inside the scene and never intercept each other', () {
    for (var i = 0; i < villageHotspots.length; i++) {
      final spot = villageHotspots[i];
      expect(villageBounds.contains(spot.bounds.topLeft), isTrue);
      expect(villageBounds.contains(spot.bounds.bottomRight), isTrue);
      for (final other in villageHotspots.skip(i + 1)) {
        expect(spot.bounds.overlaps(other.bounds), isFalse,
            reason: 'Days ${spot.dayId} and ${other.dayId} overlap');
      }
    }
  });
}
