import '../models/product.dart';

class ProductDescriptionFormatter {
  static String shortDescription(Product product) {
    final String description = fullDescription(product);
    final List<String> sentences = _splitSentences(description);
    if (sentences.isEmpty) {
      return description;
    }

    final String shortText = sentences.take(2).join(' ');
    if (shortText.length <= 130) {
      return shortText;
    }

    return '${shortText.substring(0, 127).trimRight()}...';
  }

  static String fullDescription(Product product) {
    final String cleanedName = _clean(product.name);
    final String cleanedDescription = _clean(product.description);
    final String categoryText = _categoryText(product.category, cleanedName);
    final String featureText = _featureText(cleanedName);
    final String careText = _careText(product.category);
    final String choiceText = _choiceText(cleanedName, product.category);

    if (cleanedDescription.isEmpty) {
      return '$categoryText\n\n$featureText\n\n$careText\n\n$choiceText';
    }

    final String normalizedDescription = _ensureSentence(cleanedDescription);
    final String combined =
        '$normalizedDescription\n\n$categoryText\n\n$featureText\n\n$careText\n\n$choiceText';

    return combined.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String detailedDescription(Product product) {
    final String cleanedDescription = _clean(product.description);
    final String intro = cleanedDescription.isEmpty
        ? _categoryText(product.category, product.name)
        : _ensureSentence(cleanedDescription);

    return [
      intro,
      _categoryText(product.category, product.name),
      _featureText(product.name),
      _careText(product.category),
      _choiceText(product.name, product.category),
    ].join('\n\n');
  }

  static String _categoryText(String category, String name) {
    final String normalizedCategory = _clean(category).toLowerCase();

    if (normalizedCategory.contains('корм')) {
      return 'Подходит для ежедневного рациона, помогает поддерживать сытость, активность и хорошее самочувствие питомца.';
    }
    if (normalizedCategory.contains('игруш')) {
      return 'Помогает занять питомца, поддерживает активные игры и делает каждый день интереснее и веселее.';
    }
    if (normalizedCategory.contains('аксесс')) {
      return 'Продуман для комфортного ежедневного использования дома, на прогулке и в поездках.';
    }
    if (normalizedCategory.contains('гиги')) {
      return 'Помогает поддерживать чистоту, свежесть и аккуратный уход без лишних сложностей.';
    }
    if (normalizedCategory.contains('одеж')) {
      return 'Создан для комфорта питомца, помогает защитить его от прохлады, ветра и уличного дискомфорта.';
    }

    return '$name хорошо подходит для регулярного использования и делает уход за питомцем более удобным и приятным.';
  }

  static String _featureText(String name) {
    final String normalizedName = name.toLowerCase();

    if (normalizedName.contains('premium') ||
        normalizedName.contains('pro') ||
        normalizedName.contains('deluxe')) {
      return 'Аккуратно подобранные характеристики делают этот вариант особенно удачным для тех, кто ищет более высокий уровень качества.';
    }
    if (normalizedName.contains('mini') || normalizedName.contains('small')) {
      return 'Компактный формат особенно удобен для небольших пород, щенков, котят или точечного ежедневного использования.';
    }
    if (normalizedName.contains('maxi') ||
        normalizedName.contains('large') ||
        normalizedName.contains('xl')) {
      return 'Удобный формат хорошо подходит для активных питомцев, крупных пород или более интенсивного применения.';
    }

    return 'Это практичный выбор для хозяев, которые хотят совместить удобство, приятный внешний вид и пользу в одном товаре.';
  }

  static String _careText(String category) {
    final String normalizedCategory = _clean(category).toLowerCase();

    if (normalizedCategory.contains('корм')) {
      return 'Такой товар особенно удобен для регулярного кормления: он помогает сохранять стабильный режим питания и делает ежедневный уход за питомцем более спокойным и предсказуемым.';
    }
    if (normalizedCategory.contains('игруш')) {
      return 'Игрушка помогает снизить скуку, поддерживает интерес питомца к активности и может стать хорошим дополнением к ежедневным играм дома.';
    }
    if (normalizedCategory.contains('аксесс')) {
      return 'Аксессуар хорошо вписывается в повседневный уход, добавляет удобство владельцу и помогает сделать прогулки или домашний режим более комфортными.';
    }
    if (normalizedCategory.contains('гиги')) {
      return 'Средство удобно для регулярного ухода и помогает поддерживать чистоту питомца и окружающего пространства без лишнего стресса.';
    }
    if (normalizedCategory.contains('одеж')) {
      return 'Одежда особенно полезна в прохладную погоду, на прогулках и в сезон ветра, когда питомцу нужен дополнительный комфорт и защита.';
    }

    return 'Этот товар хорошо подходит для повседневного использования и помогает сделать заботу о питомце более удобной, аккуратной и продуманной.';
  }

  static String _choiceText(String name, String category) {
    final String normalizedName = _clean(name).toLowerCase();
    final String normalizedCategory = _clean(category).toLowerCase();

    if (normalizedName.contains('premium') ||
        normalizedName.contains('pro') ||
        normalizedName.contains('deluxe')) {
      return 'Если хочется выбрать более выразительный и качественный вариант, этот товар смотрится особенно удачно и производит ощущение продуманного выбора.';
    }
    if (normalizedCategory.contains('корм')) {
      return 'Подойдет тем, кто ищет сбалансированное решение на каждый день и хочет подобрать питание, которое легко впишется в привычный режим питомца.';
    }
    if (normalizedCategory.contains('игруш')) {
      return 'Хороший выбор для питомцев, которым важно движение, вовлеченность и новые впечатления в течение дня.';
    }
    if (normalizedCategory.contains('аксесс')) {
      return 'Подойдет владельцам, которые ценят не только пользу, но и аккуратный внешний вид вещей для питомца.';
    }
    if (normalizedCategory.contains('гиги')) {
      return 'Это удачное решение для хозяев, которым важны чистота, удобство применения и аккуратный результат каждый день.';
    }
    if (normalizedCategory.contains('одеж')) {
      return 'Подойдет тем, кто хочет, чтобы питомец чувствовал себя комфортно и выглядел аккуратно во время прогулок и поездок.';
    }

    return 'Товар подойдет тем, кто хочет выбрать полезную и приятную вещь для питомца без лишних компромиссов между удобством и качеством.';
  }

  static String _clean(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _ensureSentence(String text) {
    if (text.isEmpty) {
      return text;
    }

    final String normalized = text[0].toUpperCase() + text.substring(1);
    if (RegExp(r'[.!?]$').hasMatch(normalized)) {
      return normalized;
    }

    return '$normalized.';
  }

  static List<String> _splitSentences(String text) {
    return text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }
}
