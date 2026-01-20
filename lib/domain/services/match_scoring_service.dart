import 'package:padel_punilla/domain/enums/paddle_category.dart';

/// Servicio para calcular puntos en partidos 2vs2 según nivel de jugadores.
///
/// Utiliza un promedio ponderado donde el jugador más fuerte (menor categoría)
/// pesa 60% y el más débil 40%. Los puntos se ajustan según la diferencia
/// de nivel entre equipos, premiando upsets (victorias inesperadas) y
/// reduciendo puntos cuando el favorito gana.
///
/// ## Sistema de puntos:
/// - **Base ganador**: 25 puntos
/// - **Base perdedor**: 10 puntos
/// - **Rango ganador**: 15-35 puntos
/// - **Rango perdedor**: 5-15 puntos
///
/// ## Ejemplo:
/// ```dart
/// // Equipo 4ta+6ta vs Equipo 2da+3ra
/// final team1 = MatchScoringService.calculateTeamLevel(fourth, sixth); // 4.8
/// final team2 = MatchScoringService.calculateTeamLevel(second, third); // 2.4
/// final points = MatchScoringService.calculateMatchPoints(
///   winnerTeamLevel: team1, // el débil ganó
///   loserTeamLevel: team2,
/// ); // winner: ~32 puntos, loser: ~6.5 puntos
/// ```
class MatchScoringService {
  // Previene instanciación - solo métodos estáticos
  MatchScoringService._();

  /// Valor numérico por defecto cuando la categoría es null (séptima = 7)
  static const int defaultCategoryValue = 7;

  /// Puntos base para el equipo ganador
  static const double baseWinnerPoints = 25.0;

  /// Puntos base para el equipo perdedor
  static const double baseLoserPoints = 10.0;

  /// Peso del jugador más fuerte en el cálculo del nivel de equipo (60%)
  static const double strongerPlayerWeight = 0.6;

  /// Peso del jugador más débil en el cálculo del nivel de equipo (40%)
  static const double weakerPlayerWeight = 0.4;

  /// Factor multiplicador para el ajuste de puntos según diferencia de nivel
  static const double adjustmentFactor = 3.0;

  /// Máximo ajuste permitido (positivo o negativo)
  static const double maxAdjustment = 10.0;

  /// Convierte una categoría de pádel a su valor numérico.
  ///
  /// - first = 1 (mejor)
  /// - seventh = 7 (peor)
  /// - null = 7 (default a séptima)
  static int categoryToNumericValue(PaddleCategory? category) {
    if (category == null) return defaultCategoryValue;

    // El índice del enum empieza en 0, sumamos 1 para obtener 1-7
    return category.index + 1;
  }

  /// Calcula el nivel ponderado de un equipo de 2 jugadores.
  ///
  /// El jugador más fuerte (menor número de categoría) pesa 60%,
  /// y el más débil (mayor número) pesa 40%.
  ///
  /// Ejemplos:
  /// - 4ta + 6ta → (4 * 0.6) + (6 * 0.4) = 4.8
  /// - null + 4ta → (4 * 0.6) + (7 * 0.4) = 5.2
  static double calculateTeamLevel(
    PaddleCategory? player1Category,
    PaddleCategory? player2Category,
  ) {
    final p1Value = categoryToNumericValue(player1Category);
    final p2Value = categoryToNumericValue(player2Category);

    // Determinar quién es el jugador más fuerte (menor valor = mejor)
    final strongerPlayerLevel = p1Value < p2Value ? p1Value : p2Value;
    final weakerPlayerLevel = p1Value < p2Value ? p2Value : p1Value;

    // Calcular promedio ponderado
    return (strongerPlayerLevel * strongerPlayerWeight) +
        (weakerPlayerLevel * weakerPlayerWeight);
  }

  /// Calcula los puntos para ganador y perdedor según la diferencia de niveles.
  ///
  /// - Si un equipo débil (nivel alto) vence a uno fuerte (nivel bajo),
  ///   el ganador recibe bonus y el perdedor recibe menos.
  /// - Si un equipo fuerte vence a uno débil,
  ///   el ganador recibe menos puntos y el perdedor recibe más.
  ///
  /// Retorna un record con [winnerPoints] y [loserPoints].
  static ({double winnerPoints, double loserPoints}) calculateMatchPoints({
    required double winnerTeamLevel,
    required double loserTeamLevel,
  }) {
    // Diferencia de nivel: positiva si ganador era más débil (upset)
    final levelDifference = winnerTeamLevel - loserTeamLevel;

    // Calcular ajuste: si ganador es más débil recibe BONUS
    // El factor es 3, pero se aplica en la dirección correcta:
    // - levelDifference > 0 (ganador más débil) → más puntos para ganador
    // - levelDifference < 0 (ganador más fuerte) → menos puntos para ganador
    final rawAdjustment = levelDifference * adjustmentFactor;

    // Limitar el ajuste al rango [-10, +10]
    final adjustment = rawAdjustment.clamp(-maxAdjustment, maxAdjustment);

    // Calcular puntos finales
    final winnerPoints = baseWinnerPoints + adjustment;
    final loserPoints = baseLoserPoints - (adjustment / 2);

    return (winnerPoints: winnerPoints, loserPoints: loserPoints);
  }
}
