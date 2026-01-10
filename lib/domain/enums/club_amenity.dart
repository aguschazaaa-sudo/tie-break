enum ClubAmenity {
  wifi,
  parking,
  showers,
  bar,
  shop,
  lighting,
  roofed,
  changeroom,
  grill;

  String get displayName {
    switch (this) {
      case ClubAmenity.wifi:
        return 'WiFi';
      case ClubAmenity.parking:
        return 'Estacionamiento';
      case ClubAmenity.showers:
        return 'Duchas';
      case ClubAmenity.bar:
        return 'Bar / Buffet';
      case ClubAmenity.shop:
        return 'Tienda de Accesorios';
      case ClubAmenity.lighting:
        return 'Iluminación LED';
      case ClubAmenity.roofed:
        return 'Techado';
      case ClubAmenity.changeroom:
        return 'Vestuarios';
      case ClubAmenity.grill:
        return 'Parrilla';
    }
  }

  String get iconAsset {
    // Return icon name or path if using SVG/Custom icons
    // for now we can rely on Material Icons mapping in UI
    return '';
  }
}
