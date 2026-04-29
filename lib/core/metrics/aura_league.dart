import 'package:flutter/material.dart';

enum AuraLeague {
  rookie,
  bronze,
  bronzeII,
  bronzeIII,
  silver,
  silverII,
  silverIII,
  gold,
  goldII,
  goldIII,
  platinum,
  platinumII,
  platinumIII,
  diamond,
  diamondII,
  elite,
  master,
  grandMaster,
  legend,
  mythic,
}

class AuraLeagueSystem {
  const AuraLeagueSystem._();

  static final List<AuraLeague> orderedLeagues =
      _tiers.reversed.map((tier) => tier.league).toList(growable: false);

  static AuraLeague fromAnnualPoints(int points) {
    for (final tier in _tiers.reversed) {
      if (points >= tier.minPoints) {
        return tier.league;
      }
    }
    return _tiers.first.league;
  }

  static int minPointsFor(AuraLeague league) {
    return _tierByLeague[league]!.minPoints;
  }

  static String localizedName(AuraLeague league, String languageCode) {
    final isEnglish = languageCode == 'en';
    final tier = _tierByLeague[league]!;
    return isEnglish ? tier.nameEn : tier.nameEs;
  }

  static IconData icon(AuraLeague league) {
    return _tierByLeague[league]!.icon;
  }

  static Color color(AuraLeague league, ThemeData theme) {
    return _tierByLeague[league]!.color ?? theme.colorScheme.primary;
  }

  static final Map<AuraLeague, _LeagueTier> _tierByLeague = {
    for (final tier in _tiers) tier.league: tier,
  };

  static const List<_LeagueTier> _tiers = [
    _LeagueTier(
      league: AuraLeague.rookie,
      minPoints: 0,
      nameEn: 'Rookie',
      nameEs: 'Rookie',
      icon: Icons.bolt_rounded,
    ),
    _LeagueTier(
      league: AuraLeague.bronze,
      minPoints: 1200,
      nameEn: 'Bronze I',
      nameEs: 'Bronce I',
      icon: Icons.shield_outlined,
      color: Color(0xFFB87333),
    ),
    _LeagueTier(
      league: AuraLeague.bronzeII,
      minPoints: 2400,
      nameEn: 'Bronze II',
      nameEs: 'Bronce II',
      icon: Icons.shield_outlined,
      color: Color(0xFFB6783D),
    ),
    _LeagueTier(
      league: AuraLeague.bronzeIII,
      minPoints: 3600,
      nameEn: 'Bronze III',
      nameEs: 'Bronce III',
      icon: Icons.shield,
      color: Color(0xFFBD7C45),
    ),
    _LeagueTier(
      league: AuraLeague.silver,
      minPoints: 5000,
      nameEn: 'Silver I',
      nameEs: 'Plata I',
      icon: Icons.workspace_premium_outlined,
      color: Color(0xFF9EA7B8),
    ),
    _LeagueTier(
      league: AuraLeague.silverII,
      minPoints: 6500,
      nameEn: 'Silver II',
      nameEs: 'Plata II',
      icon: Icons.workspace_premium_outlined,
      color: Color(0xFFAAB3C2),
    ),
    _LeagueTier(
      league: AuraLeague.silverIII,
      minPoints: 8000,
      nameEn: 'Silver III',
      nameEs: 'Plata III',
      icon: Icons.workspace_premium,
      color: Color(0xFFB6BFCD),
    ),
    _LeagueTier(
      league: AuraLeague.gold,
      minPoints: 9000,
      nameEn: 'Gold I',
      nameEs: 'Oro I',
      icon: Icons.emoji_events_outlined,
      color: Color(0xFFD4AF37),
    ),
    _LeagueTier(
      league: AuraLeague.goldII,
      minPoints: 10500,
      nameEn: 'Gold II',
      nameEs: 'Oro II',
      icon: Icons.emoji_events_outlined,
      color: Color(0xFFDAB957),
    ),
    _LeagueTier(
      league: AuraLeague.goldIII,
      minPoints: 12000,
      nameEn: 'Gold III',
      nameEs: 'Oro III',
      icon: Icons.emoji_events,
      color: Color(0xFFE0C26D),
    ),
    _LeagueTier(
      league: AuraLeague.platinum,
      minPoints: 14000,
      nameEn: 'Platinum I',
      nameEs: 'Platino I',
      icon: Icons.military_tech_outlined,
      color: Color(0xFF7FC7C8),
    ),
    _LeagueTier(
      league: AuraLeague.platinumII,
      minPoints: 16000,
      nameEn: 'Platinum II',
      nameEs: 'Platino II',
      icon: Icons.military_tech_outlined,
      color: Color(0xFF6FBCC2),
    ),
    _LeagueTier(
      league: AuraLeague.platinumIII,
      minPoints: 18000,
      nameEn: 'Platinum III',
      nameEs: 'Platino III',
      icon: Icons.military_tech,
      color: Color(0xFF5FB0BB),
    ),
    _LeagueTier(
      league: AuraLeague.diamond,
      minPoints: 20500,
      nameEn: 'Diamond I',
      nameEs: 'Diamante I',
      icon: Icons.diamond_outlined,
      color: Color(0xFF4DA3FF),
    ),
    _LeagueTier(
      league: AuraLeague.diamondII,
      minPoints: 23000,
      nameEn: 'Diamond II',
      nameEs: 'Diamante II',
      icon: Icons.diamond,
      color: Color(0xFF3E8DFF),
    ),
    _LeagueTier(
      league: AuraLeague.elite,
      minPoints: 26000,
      nameEn: 'Elite',
      nameEs: 'Elite',
      icon: Icons.flash_on_rounded,
      color: Color(0xFF8A7CFF),
    ),
    _LeagueTier(
      league: AuraLeague.master,
      minPoints: 29000,
      nameEn: 'Master',
      nameEs: 'Máster',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFFF7A59),
    ),
    _LeagueTier(
      league: AuraLeague.grandMaster,
      minPoints: 32000,
      nameEn: 'Grand Master',
      nameEs: 'Gran Máster',
      icon: Icons.local_fire_department,
      color: Color(0xFFFF5B57),
    ),
    _LeagueTier(
      league: AuraLeague.legend,
      minPoints: 36000,
      nameEn: 'Legend',
      nameEs: 'Leyenda',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFFF6D3A),
    ),
    _LeagueTier(
      league: AuraLeague.mythic,
      minPoints: 40000,
      nameEn: 'Mythic',
      nameEs: 'Mítica',
      icon: Icons.whatshot_rounded,
      color: Color(0xFFFF3D00),
    ),
  ];
}

class _LeagueTier {
  const _LeagueTier({
    required this.league,
    required this.minPoints,
    required this.nameEn,
    required this.nameEs,
    required this.icon,
    this.color,
  });

  final AuraLeague league;
  final int minPoints;
  final String nameEn;
  final String nameEs;
  final IconData icon;
  final Color? color;
}
