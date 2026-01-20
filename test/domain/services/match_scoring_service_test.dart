import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/domain/enums/paddle_category.dart';
import 'package:padel_punilla/domain/services/match_scoring_service.dart';

void main() {
  group('MatchScoringService', () {
    group('calculateTeamLevel', () {
      test('should calculate weighted average with stronger player at 60%', () {
        // Equipo: 4ta (4) + 6ta (6)
        // Fuerte = 4, Débil = 6
        // Resultado: (4 * 0.6) + (6 * 0.4) = 2.4 + 2.4 = 4.8
        final level = MatchScoringService.calculateTeamLevel(
          PaddleCategory.fourth,
          PaddleCategory.sixth,
        );

        expect(level, closeTo(4.8, 0.0001));
      });

      test('should use default seventh (7) when category is null', () {
        // Equipo: null + 4ta (4)
        // Fuerte = 4, Débil = 7 (default)
        // Resultado: (4 * 0.6) + (7 * 0.4) = 2.4 + 2.8 = 5.2
        final level = MatchScoringService.calculateTeamLevel(
          null,
          PaddleCategory.fourth,
        );

        expect(level, 5.2);
      });

      test('should default both to seventh when both are null', () {
        // Equipo: null + null = 7 + 7
        // Resultado: (7 * 0.6) + (7 * 0.4) = 4.2 + 2.8 = 7.0
        final level = MatchScoringService.calculateTeamLevel(null, null);

        expect(level, 7.0);
      });

      test('should handle first category correctly', () {
        // Equipo: 1ra (1) + 1ra (1)
        // Resultado: (1 * 0.6) + (1 * 0.4) = 0.6 + 0.4 = 1.0
        final level = MatchScoringService.calculateTeamLevel(
          PaddleCategory.first,
          PaddleCategory.first,
        );

        expect(level, 1.0);
      });

      test('should order players correctly regardless of parameter order', () {
        // Equipo: 6ta (6) + 4ta (4) - passed in reverse order
        // Should still calculate with 4 as stronger
        final level = MatchScoringService.calculateTeamLevel(
          PaddleCategory.sixth,
          PaddleCategory.fourth,
        );

        expect(level, closeTo(4.8, 0.0001));
      });
    });

    group('calculateMatchPoints', () {
      test('should return base points (25/10) when levels are equal', () {
        // Equipos con mismo nivel
        final result = MatchScoringService.calculateMatchPoints(
          winnerTeamLevel: 4.0,
          loserTeamLevel: 4.0,
        );

        expect(result.winnerPoints, 25.0);
        expect(result.loserPoints, 10.0);
      });

      test('should give maximum bonus when underdog wins (7ma vs 1ra)', () {
        // Ganador nivel 7 (débil) vs Perdedor nivel 1 (fuerte)
        // diferencia = 7 - 1 = 6
        // ajuste = 6 * -3 = -18 -> clamped to -10
        // winner = 25 + (-10) = 15??? No, wait...
        // El ganador débil debería recibir MÁS puntos
        // Reviso la fórmula: si ganador tiene nivel MAYOR (más débil),
        // la diferencia es positiva, entonces ajuste = positivo * -3 = negativo
        // Eso es al revés... veamos:
        //
        // Según el plan actualizado:
        // diferenciaNivel = nivelEquipoGanador - nivelEquipoPerdedor
        // Si ganador es 7ma (nivel 7) y perdedor es 1ra (nivel 1):
        // diferencia = 7 - 1 = 6 (positivo porque ganador era más débil)
        // ajuste = 6 * -3 = -18 -> pero esto le RESTA al ganador
        //
        // Creo que hay un error en mi interpretación. El usuario dijo
        // "que sea -3" para el factor. Veamos la intención:
        // - Si un débil le gana a un fuerte = BONUS para ganador
        // - Si un fuerte le gana a un débil = MENOS puntos para ganador
        //
        // Entonces si usamos ajuste = diferencia * -3:
        // - Débil gana: diferencia positiva * -3 = ajuste negativo = menos puntos
        // Eso está al revés!
        //
        // Creo que el usuario quiso decir que el MULTIPLICADOR sea 3
        // pero que cuando el fuerte gana, sea negativo para él.
        //
        // Mejor interpreto así:
        // ajuste = (nivelPerdedor - nivelGanador) * 3
        // Si perdedor era más débil (mayor nivel): ajuste negativo (menos puntos)
        // Si perdedor era más fuerte (menor nivel): ajuste positivo (más puntos)
        //
        // Mejor verifico con el test que el débil reciba más puntos:
        final result = MatchScoringService.calculateMatchPoints(
          winnerTeamLevel: 7.0, // Séptima (débil)
          loserTeamLevel: 1.0, // Primera (fuerte)
        );

        // El débil que gana debería recibir el máximo: 35
        // El fuerte que pierde debería recibir menos: 5
        expect(result.winnerPoints, 35.0);
        expect(result.loserPoints, 5.0);
      });

      test('should give minimum points when favorite wins (1ra vs 7ma)', () {
        // Ganador nivel 1 (fuerte) vs Perdedor nivel 7 (débil)
        final result = MatchScoringService.calculateMatchPoints(
          winnerTeamLevel: 1.0, // Primera (fuerte)
          loserTeamLevel: 7.0, // Séptima (débil)
        );

        // El fuerte que gana debería recibir el mínimo: 15
        // El débil que pierde debería recibir más: 15 (máximo para perdedor)
        expect(result.winnerPoints, 15.0);
        expect(result.loserPoints, 15.0);
      });

      test('should clamp adjustment to [-10, +10] range', () {
        // Caso extremo que excedería el límite
        // Pero con rango 1-7, máxima diferencia es 6
        // 6 * 3 = 18 -> clamped to 10
        final result = MatchScoringService.calculateMatchPoints(
          winnerTeamLevel: 7.0,
          loserTeamLevel: 1.0,
        );

        // Winner points no debería exceder 35 (25 + 10)
        expect(result.winnerPoints, lessThanOrEqualTo(35.0));
        expect(result.winnerPoints, greaterThanOrEqualTo(15.0));

        // Loser points no debería ser menor a 5 (10 - 10/2)
        expect(result.loserPoints, greaterThanOrEqualTo(5.0));
        expect(result.loserPoints, lessThanOrEqualTo(15.0));
      });

      test('should handle small level differences correctly', () {
        // Ganador 5ta vs Perdedor 4ta (diferencia de 1)
        final result = MatchScoringService.calculateMatchPoints(
          winnerTeamLevel: 5.0, // ligeramente más débil
          loserTeamLevel: 4.0, // ligeramente más fuerte
        );

        // diferencia = 5 - 4 = 1 (débil ganó)
        // ajuste = 1 * 3 = 3 (positivo para ganador)
        // winner = 25 + 3 = 28
        // loser = 10 - 3/2 = 10 - 1.5 = 8.5
        expect(result.winnerPoints, 28.0);
        expect(result.loserPoints, 8.5);
      });
    });

    group('categoryToNumericValue', () {
      test('should convert all categories to correct numeric values', () {
        expect(
          MatchScoringService.categoryToNumericValue(PaddleCategory.first),
          1,
        );
        expect(
          MatchScoringService.categoryToNumericValue(PaddleCategory.second),
          2,
        );
        expect(
          MatchScoringService.categoryToNumericValue(PaddleCategory.third),
          3,
        );
        expect(
          MatchScoringService.categoryToNumericValue(PaddleCategory.fourth),
          4,
        );
        expect(
          MatchScoringService.categoryToNumericValue(PaddleCategory.fifth),
          5,
        );
        expect(
          MatchScoringService.categoryToNumericValue(PaddleCategory.sixth),
          6,
        );
        expect(
          MatchScoringService.categoryToNumericValue(PaddleCategory.seventh),
          7,
        );
      });

      test('should return 7 for null category', () {
        expect(MatchScoringService.categoryToNumericValue(null), 7);
      });
    });
  });
}
