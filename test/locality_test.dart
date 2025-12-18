import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/domain/enums/locality.dart';

void main() {
  group('Locality Nearby Logic', () {
    test('Valle Hermoso should be near La Falda and Casa Grande', () {
      final nearby = Locality.valleHermoso.nearbyLocalities;
      expect(nearby, contains(Locality.laFalda));
      expect(nearby, contains(Locality.casaGrande));
    });

    test('La Falda should be near Valle Hermoso and Huerta Grande', () {
      final nearby = Locality.laFalda.nearbyLocalities;
      expect(nearby, contains(Locality.valleHermoso));
      expect(nearby, contains(Locality.huertaGrande));
    });

    test('Villa Carlos Paz should be near San Antonio and Icho Cruz', () {
      final nearby = Locality.villaCarlosPaz.nearbyLocalities;
      expect(nearby, contains(Locality.sanAntonioDeArredondo));
      expect(nearby, contains(Locality.villaIchoCruz));
    });

    test('Bialet Masse should be near Cosquin and Santa Maria', () {
      final nearby = Locality.bialetMasse.nearbyLocalities;
      expect(nearby, contains(Locality.cosquin));
      expect(nearby, contains(Locality.santaMaria));
    });

    test('Relationships should be generally reflexive (sanity check)', () {
      // Note: Not strict reflexivity in all cases depending on 'viewpoint',
      // but strictly strict for direct neighbors usually.
      // Checking specific critical pairs.

      expect(
        Locality.valleHermoso.nearbyLocalities.contains(Locality.laFalda),
        isTrue,
      );
      expect(
        Locality.laFalda.nearbyLocalities.contains(Locality.valleHermoso),
        isTrue,
      );

      expect(
        Locality.cosquin.nearbyLocalities.contains(Locality.santaMaria),
        isTrue,
      );
      expect(
        Locality.santaMaria.nearbyLocalities.contains(Locality.cosquin),
        isTrue,
      );
    });

    test('No locality should be nearby itself', () {
      for (final locality in Locality.values) {
        expect(locality.nearbyLocalities, isNot(contains(locality)));
      }
    });
  });
}
