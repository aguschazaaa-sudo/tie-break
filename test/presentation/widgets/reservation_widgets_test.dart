@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:padel_punilla/config/theme/app_theme.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/presentation/screens/my_reservations/widgets/reservation_list_empty.dart';
import 'package:padel_punilla/presentation/screens/my_reservations/widgets/reservation_status_badge.dart';

void main() {
  testGoldens('Reservation widgets golden test', (tester) async {
    final builder =
        GoldenBuilder.column()
          ..addScenario(
            'ReservationListEmpty light',
            Theme(
              data: AppTheme.lightTheme,
              child: const SizedBox(
                width: 350,
                height: 300,
                child: ReservationListEmpty(),
              ),
            ),
          )
          ..addScenario(
            'ReservationListEmpty with action',
            Theme(
              data: AppTheme.lightTheme,
              child: SizedBox(
                width: 350,
                height: 350,
                child: ReservationListEmpty(onActionPressed: () {}),
              ),
            ),
          )
          ..addScenario(
            'ReservationStatusBadge - Pending',
            Theme(
              data: AppTheme.lightTheme,
              child: const ReservationStatusBadge(
                status: ReservationStatus.pending,
              ),
            ),
          )
          ..addScenario(
            'ReservationStatusBadge - Approved',
            Theme(
              data: AppTheme.lightTheme,
              child: const ReservationStatusBadge(
                status: ReservationStatus.approved,
              ),
            ),
          )
          ..addScenario(
            'ReservationStatusBadge - Rejected',
            Theme(
              data: AppTheme.lightTheme,
              child: const ReservationStatusBadge(
                status: ReservationStatus.rejected,
              ),
            ),
          )
          ..addScenario(
            'ReservationStatusBadge - Cancelled',
            Theme(
              data: AppTheme.lightTheme,
              child: const ReservationStatusBadge(
                status: ReservationStatus.cancelled,
              ),
            ),
          )
          ..addScenario(
            'ReservationStatusBadge small',
            Theme(
              data: AppTheme.lightTheme,
              child: const ReservationStatusBadge(
                status: ReservationStatus.pending,
                size: 'small',
              ),
            ),
          );

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(400, 1200),
    );

    await screenMatchesGolden(
      tester,
      'reservation_widgets',
      customPump: (tester) async {
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  });
}
