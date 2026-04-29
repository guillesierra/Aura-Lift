import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/metrics/aura_league.dart';

void main() {
  test('maps annual points into twenty competitive leagues', () {
    expect(AuraLeagueSystem.fromAnnualPoints(0), AuraLeague.rookie);
    expect(AuraLeagueSystem.fromAnnualPoints(2100), AuraLeague.bronze);
    expect(AuraLeagueSystem.fromAnnualPoints(3600), AuraLeague.bronzeIII);
    expect(AuraLeagueSystem.fromAnnualPoints(5200), AuraLeague.silver);
    expect(AuraLeagueSystem.fromAnnualPoints(7600), AuraLeague.silverII);
    expect(AuraLeagueSystem.fromAnnualPoints(9300), AuraLeague.gold);
    expect(AuraLeagueSystem.fromAnnualPoints(15000), AuraLeague.platinum);
    expect(AuraLeagueSystem.fromAnnualPoints(21000), AuraLeague.diamond);
    expect(AuraLeagueSystem.fromAnnualPoints(27000), AuraLeague.elite);
    expect(AuraLeagueSystem.fromAnnualPoints(36500), AuraLeague.legend);
    expect(AuraLeagueSystem.fromAnnualPoints(40500), AuraLeague.mythic);
  });
}
