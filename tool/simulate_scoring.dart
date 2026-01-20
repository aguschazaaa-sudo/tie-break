// ignore_for_file: avoid_print
import 'package:padel_punilla/domain/enums/paddle_category.dart';
import 'package:padel_punilla/domain/services/match_scoring_service.dart';

/// Script para simular puntajes de partidos 2vs2 con diferentes niveles
void main() {
  print('');
  print('╔══════════════════════════════════════════════════════════════════╗');
  print('║           SIMULACION DE PUNTAJES - DESAFIOS 2VS2                ║');
  print('╚══════════════════════════════════════════════════════════════════╝');
  print('');

  final scenarios = <Map<String, dynamic>>[
    {
      'name': '4ta+6ta vs 4ta+6ta (equipos iguales)',
      'winner': [PaddleCategory.fourth, PaddleCategory.sixth],
      'loser': [PaddleCategory.fourth, PaddleCategory.sixth],
    },
    {
      'name': '7ma+7ma vs 1ra+1ra (UPSET EPICO 🔥)',
      'winner': [PaddleCategory.seventh, PaddleCategory.seventh],
      'loser': [PaddleCategory.first, PaddleCategory.first],
    },
    {
      'name': '1ra+1ra vs 7ma+7ma (favorito gana)',
      'winner': [PaddleCategory.first, PaddleCategory.first],
      'loser': [PaddleCategory.seventh, PaddleCategory.seventh],
    },
    {
      'name': '4ta+5ta vs 3ra+4ta (ligero upset)',
      'winner': [PaddleCategory.fourth, PaddleCategory.fifth],
      'loser': [PaddleCategory.third, PaddleCategory.fourth],
    },
    {
      'name': '2da+3ra vs 5ta+6ta (favorito gana)',
      'winner': [PaddleCategory.second, PaddleCategory.third],
      'loser': [PaddleCategory.fifth, PaddleCategory.sixth],
    },
    {
      'name': 'sin categoria vs 4ta+4ta',
      'winner': [null, null],
      'loser': [PaddleCategory.fourth, PaddleCategory.fourth],
    },
    {
      'name': '5ta+5ta vs 5ta+5ta (exactamente iguales)',
      'winner': [PaddleCategory.fifth, PaddleCategory.fifth],
      'loser': [PaddleCategory.fifth, PaddleCategory.fifth],
    },
    {
      'name': '3ra+6ta vs 4ta+4ta (mixto)',
      'winner': [PaddleCategory.third, PaddleCategory.sixth],
      'loser': [PaddleCategory.fourth, PaddleCategory.fourth],
    },
    {
      'name': '6ta+7ta vs 2da+4ta (mega upset)',
      'winner': [PaddleCategory.sixth, PaddleCategory.seventh],
      'loser': [PaddleCategory.second, PaddleCategory.fourth],
    },
    {
      'name': '1ra+7ma vs 3ra+5ta',
      'winner': [PaddleCategory.first, PaddleCategory.seventh],
      'loser': [PaddleCategory.third, PaddleCategory.fifth],
    },
  ];

  for (final scenario in scenarios) {
    final name = scenario['name'] as String;
    final winner = scenario['winner'] as List<PaddleCategory?>;
    final loser = scenario['loser'] as List<PaddleCategory?>;

    final wLevel = MatchScoringService.calculateTeamLevel(winner[0], winner[1]);
    final lLevel = MatchScoringService.calculateTeamLevel(loser[0], loser[1]);
    final points = MatchScoringService.calculateMatchPoints(
      winnerTeamLevel: wLevel,
      loserTeamLevel: lLevel,
    );

    final winLabel = winner.map((c) => c?.label ?? '7ma').join('+');
    final loseLabel = loser.map((c) => c?.label ?? '7ma').join('+');

    print('┌─────────────────────────────────────────────────────────────────');
    print('│ 🎾 $name');
    print('│');
    print('│ Ganador ($winLabel): nivel ${wLevel.toStringAsFixed(1)}');
    print('│ Perdedor ($loseLabel): nivel ${lLevel.toStringAsFixed(1)}');
    print('│');
    print('│ ➜ GANADOR: ${points.winnerPoints.toStringAsFixed(1)} puntos');
    print('│ ➜ PERDEDOR: ${points.loserPoints.toStringAsFixed(1)} puntos');
    print('└─────────────────────────────────────────────────────────────────');
    print('');
  }

  print('╔══════════════════════════════════════════════════════════════════╗');
  print('║  Rangos:  Ganador [15-35 pts] | Perdedor [5-15 pts]              ║');
  print('║  Base:    Ganador 25 pts | Perdedor 10 pts (niveles iguales)    ║');
  print('╚══════════════════════════════════════════════════════════════════╝');
}
