enum PaddleCategory {
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  seventh;

  String get label {
    switch (this) {
      case PaddleCategory.first:
        return 'Primera';
      case PaddleCategory.second:
        return 'Segunda';
      case PaddleCategory.third:
        return 'Tercera';
      case PaddleCategory.fourth:
        return 'Cuarta';
      case PaddleCategory.fifth:
        return 'Quinta';
      case PaddleCategory.sixth:
        return 'Sexta';
      case PaddleCategory.seventh:
        return 'Séptima';
    }
  }
}
