# 🎾 Tie Break

**La plataforma definitiva para reservas y ligas de pádel.**

Tie Break es una aplicación móvil desarrollada en Flutter que permite a los jugadores de pádel reservar canchas, participar en partidos 2v2, unirse a partidos "falta uno", y competir en ligas con sistema de ranking.

---

## ✨ Características

### 🏟️ Gestión de Reservas
- **Reservas normales**: Reserva una cancha para jugar con tus amigos
- **Partidos 2v2**: Crea partidos competitivos con seguimiento de resultados
- **Falta Uno**: Únete a partidos que necesitan un jugador más
- **Timeline visual**: Visualiza la disponibilidad de canchas en tiempo real

### 🏆 Sistema de Ligas
- **Temporadas**: Competencias organizadas por temporadas
- **Ranking ELO**: Sistema de puntuación dinámico basado en resultados
- **Leaderboard**: Tabla de clasificación en tiempo real

### 👤 Perfiles de Usuario
- Autenticación con Google
- Perfiles personalizados con nivel de juego y lateralidad
- Historial de partidos y estadísticas

### 🏢 Panel de Clubes
- Gestión de canchas y horarios
- Aprobación/rechazo de reservas
- Configuración de precios por horario

---

## 🛠️ Tecnologías

| Tecnología | Uso |
|------------|-----|
| **Flutter** | Framework de desarrollo móvil |
| **Firebase Auth** | Autenticación de usuarios |
| **Cloud Firestore** | Base de datos en tiempo real |
| **Firebase Storage** | Almacenamiento de imágenes |
| **Provider** | Gestión de estado |

---

## 🚀 Instalación

### Prerrequisitos
- Flutter SDK ^3.7.2
- Dart SDK
- Cuenta de Firebase

### Pasos

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/aguschazaaa-sudo/tie-break.git
   cd tie-break
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Configura Firebase**
   - Crea un proyecto en [Firebase Console](https://console.firebase.google.com/)
   - Descarga `google-services.json` (Android) y colócalo en `android/app/`
   - Descarga `GoogleService-Info.plist` (iOS) y colócalo en `ios/Runner/`
   - Ejecuta `flutterfire configure` para generar `lib/firebase_options.dart`

4. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

---

## 📁 Estructura del Proyecto

```
lib/
├── config/           # Configuración (temas, rutas, constantes)
├── data/             # Capa de datos (modelos, repositorios)
├── presentation/     # Capa de presentación (screens, widgets)
│   ├── screens/      # Pantallas de la app
│   ├── widgets/      # Widgets reutilizables
│   └── providers/    # Providers para gestión de estado
└── main.dart         # Punto de entrada
```

---

## 🧪 Tests

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar con cobertura
flutter test --coverage
```

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autor

Desarrollado con ❤️ para la comunidad de pádel.

---

<p align="center">
  <strong>¿Encontraste un bug? ¿Tienes una sugerencia?</strong><br>
  <a href="https://github.com/aguschazaaa-sudo/tie-break/issues">Abre un issue</a>
</p>
