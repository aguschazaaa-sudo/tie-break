enum Locality {
  // Municipios
  bialetMasse,
  capillaDelMonte,
  cosquin,
  huertaGrande,
  laCumbre,
  laFalda,
  losCocos,
  sanAntonioDeArredondo,
  sanEsteban,
  santaMaria,
  tanti,
  valleHermoso,
  villaCarlosPaz,
  villaGiardino,
  villaIchoCruz,
  villaSantaCruzDelLago,

  // Comunas
  cabalango,
  casaGrande,
  charbonier,
  cuestaBlanca,
  estanciaVieja,
  mayuSumaj,
  sanRoque,
  talaHuasi,
  villaParqueSiquiman;

  String get displayName {
    switch (this) {
      // Municipios
      case Locality.bialetMasse:
        return 'Bialet Massé';
      case Locality.capillaDelMonte:
        return 'Capilla del Monte';
      case Locality.cosquin:
        return 'Cosquín';
      case Locality.huertaGrande:
        return 'Huerta Grande';
      case Locality.laCumbre:
        return 'La Cumbre';
      case Locality.laFalda:
        return 'La Falda';
      case Locality.losCocos:
        return 'Los Cocos';
      case Locality.sanAntonioDeArredondo:
        return 'San Antonio de Arredondo';
      case Locality.sanEsteban:
        return 'San Esteban';
      case Locality.santaMaria:
        return 'Santa María';
      case Locality.tanti:
        return 'Tanti';
      case Locality.valleHermoso:
        return 'Valle Hermoso';
      case Locality.villaCarlosPaz:
        return 'Villa Carlos Paz';
      case Locality.villaGiardino:
        return 'Villa Giardino';
      case Locality.villaIchoCruz:
        return 'Villa Icho Cruz';
      case Locality.villaSantaCruzDelLago:
        return 'Villa Santa Cruz del Lago';

      // Comunas
      case Locality.cabalango:
        return 'Cabalango';
      case Locality.casaGrande:
        return 'Casa Grande';
      case Locality.charbonier:
        return 'Charbonier';
      case Locality.cuestaBlanca:
        return 'Cuesta Blanca';
      case Locality.estanciaVieja:
        return 'Estancia Vieja';
      case Locality.mayuSumaj:
        return 'Mayu Sumaj';
      case Locality.sanRoque:
        return 'San Roque';
      case Locality.talaHuasi:
        return 'Tala Huasi';
      case Locality.villaParqueSiquiman:
        return 'Villa Parque Síquiman';
    }
  }

  List<Locality> get nearbyLocalities {
    switch (this) {
      // Zona Sur
      case Locality.villaCarlosPaz:
        return [
          Locality.sanAntonioDeArredondo,
          Locality.villaIchoCruz,
          Locality.mayuSumaj,
          Locality.cabalango,
          Locality.estanciaVieja,
          Locality.villaSantaCruzDelLago,
          Locality.villaParqueSiquiman,
        ];
      case Locality.sanAntonioDeArredondo:
        return [
          Locality.villaCarlosPaz,
          Locality.mayuSumaj,
          Locality.villaIchoCruz,
          Locality.cuestaBlanca,
        ];
      case Locality.villaIchoCruz:
        return [
          Locality.sanAntonioDeArredondo,
          Locality.mayuSumaj,
          Locality.cuestaBlanca,
          Locality.talaHuasi,
        ];
      case Locality.mayuSumaj:
        return [
          Locality.sanAntonioDeArredondo,
          Locality.villaIchoCruz,
          Locality.talaHuasi,
          Locality.villaCarlosPaz,
        ];
      case Locality.cuestaBlanca:
        return [Locality.villaIchoCruz, Locality.talaHuasi];
      case Locality.talaHuasi:
        return [
          Locality.villaIchoCruz,
          Locality.mayuSumaj,
          Locality.cuestaBlanca,
        ];
      case Locality.cabalango:
        return [Locality.villaCarlosPaz, Locality.tanti];
      case Locality.estanciaVieja:
        return [Locality.villaCarlosPaz, Locality.villaSantaCruzDelLago];
      case Locality.villaSantaCruzDelLago:
        return [
          Locality.villaCarlosPaz,
          Locality.estanciaVieja,
          Locality.villaParqueSiquiman,
        ];
      case Locality.villaParqueSiquiman:
        return [
          Locality.villaSantaCruzDelLago,
          Locality.bialetMasse,
          Locality.sanRoque,
          Locality.villaCarlosPaz,
        ];
      case Locality.sanRoque:
        return [Locality.villaParqueSiquiman, Locality.bialetMasse];

      // Zona Centro
      case Locality.bialetMasse:
        return [
          Locality.villaParqueSiquiman,
          Locality.sanRoque,
          Locality.santaMaria,
          Locality.cosquin,
        ];
      case Locality.santaMaria:
        return [Locality.bialetMasse, Locality.cosquin];
      case Locality.cosquin:
        return [
          Locality.santaMaria,
          Locality.bialetMasse,
          Locality.casaGrande,
          Locality.valleHermoso, // Cercano
        ];
      case Locality.casaGrande:
        return [Locality.cosquin, Locality.valleHermoso];
      case Locality.valleHermoso:
        return [Locality.casaGrande, Locality.laFalda, Locality.cosquin];
      case Locality.laFalda:
        return [Locality.valleHermoso, Locality.huertaGrande];
      case Locality.huertaGrande:
        return [Locality.laFalda, Locality.villaGiardino];
      case Locality.villaGiardino:
        return [Locality.huertaGrande, Locality.laCumbre];

      // Zona Norte
      case Locality.laCumbre:
        return [Locality.villaGiardino, Locality.losCocos, Locality.sanEsteban];
      case Locality.losCocos:
        return [Locality.laCumbre, Locality.sanEsteban];
      case Locality.sanEsteban:
        return [Locality.laCumbre, Locality.losCocos, Locality.capillaDelMonte];
      case Locality.capillaDelMonte:
        return [Locality.sanEsteban, Locality.charbonier];
      case Locality.charbonier:
        return [Locality.capillaDelMonte];

      // Otros / Transversal
      case Locality.tanti:
        return [Locality.cabalango, Locality.villaSantaCruzDelLago];
    }
  }
}
