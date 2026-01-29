import 'package:flutter/material.dart';
import '../../features/daily_news/domain/entities/article.dart';

class ArticleCategoryHelper {
  static const String kAll = 'Todo';
  static const String kTechnology = 'Tecnología';
  static const String kPolitics = 'Política';
  static const String kBusiness = 'Negocios';
  static const String kSports = 'Deportes';
  static const String kEntertainment = 'Entretenimiento';
  static const String kScience = 'Ciencia';
  static const String kWorld = 'Mundo';
  static const String kGeneral = 'General';

  static final List<Map<String, dynamic>> categories = [
    {'name': kAll, 'emoji': '🔥', 'id': 'all'},
    {'name': kTechnology, 'emoji': '💻', 'id': 'tech'},
    {'name': kPolitics, 'emoji': '🏛️', 'id': 'politics'},
    {'name': kBusiness, 'emoji': '💼', 'id': 'business'},
    {'name': kSports, 'emoji': '⚽', 'id': 'sports'},
    {'name': kEntertainment, 'emoji': '🍿', 'id': 'entertainment'},
    {'name': kScience, 'emoji': '🧬', 'id': 'science'},
    {'name': kWorld, 'emoji': '🌎', 'id': 'world'},
  ];

  /// Get category name from article data using bilingual keywords
  static String getCategory(ArticleEntity? article) {
    if (article == null) return kGeneral;

    final text = '${article.author ?? ''} ${article.title ?? ''}'.toLowerCase();

    // TECHNOLOGY
    if (text.contains('tech') ||
        text.contains('ai ') ||
        text.contains('apple') ||
        text.contains('google') ||
        text.contains('microsoft') ||
        text.contains('crypto') ||
        text.contains('software') ||
        text.contains('app ') ||
        text.contains('web') ||
        text.contains('tecnolog') ||
        text.contains('iphone') ||
        text.contains('android')) {
      return kTechnology;
    }

    // POLITICS
    if (text.contains('polit') ||
        text.contains('senat') ||
        text.contains('congress') ||
        text.contains('trump') ||
        text.contains('biden') ||
        text.contains('elect') ||
        text.contains('gobier') ||
        text.contains('presidente') ||
        text.contains('ley')) {
      return kPolitics;
    }

    // BUSINESS
    if (text.contains('business') ||
        text.contains('market') ||
        text.contains('stock') ||
        text.contains('econ') ||
        text.contains('finan') ||
        text.contains('money') ||
        text.contains('trade') ||
        text.contains('negocio') ||
        text.contains('mercado')) {
      return kBusiness;
    }

    // SPORTS
    if (text.contains('sport') ||
        text.contains('football') ||
        text.contains('soccer') ||
        text.contains('nba') ||
        text.contains('nfl') ||
        text.contains('fifa') ||
        text.contains('deporte') ||
        text.contains('futbol') ||
        text.contains('partido')) {
      return kSports;
    }

    // ENTERTAINMENT
    if (text.contains('movie') ||
        text.contains('film') ||
        text.contains('music') ||
        text.contains('hollywood') ||
        text.contains('star') ||
        text.contains('celebrity') ||
        text.contains('cine') ||
        text.contains('musica') ||
        text.contains('pelicula')) {
      return kEntertainment;
    }

    // SCIENCE
    if (text.contains('science') ||
        text.contains('space') ||
        text.contains('nasa') ||
        text.contains('climate') ||
        text.contains('research') ||
        text.contains('study') ||
        text.contains('ciencia') ||
        text.contains('espacio') ||
        text.contains('estudio')) {
      return kScience;
    }

    // WORLD
    if (text.contains('international') ||
        text.contains('world') ||
        text.contains('global') ||
        text.contains('china') ||
        text.contains('russia') ||
        text.contains('ukraine') ||
        text.contains('war ') ||
        text.contains('internacional') ||
        text.contains('mundo')) {
      return kWorld;
    }

    return kGeneral;
  }

  /// Get color for category badge
  static Color getCategoryColor(String category) {
    switch (category) {
      case kTechnology:
        return const Color(0xFF2196F3); // Blue
      case kPolitics:
        return const Color(0xFFE91E63); // Pink
      case kBusiness:
        return const Color(0xFFFF9800); // Orange
      case kSports:
        return const Color(0xFF4CAF50); // Green
      case kEntertainment:
        return const Color(0xFF9C27B0); // Purple
      case kScience:
        return const Color(0xFF00BCD4); // Cyan
      case kWorld:
        return const Color(0xFF3F51B5); // Indigo
      default:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }
}
