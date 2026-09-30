# QueueQuest

[ENG] Application that combines queue and reservation management with a gamified visual layer to enhance the user’s waiting experience.

[ESP] Aplicación que combina gestión de turnos, reservas y una capa visual gamificada para mejorar la experiencia de espera del usuario.

**Demo web:** <https://queuequest-a1303.web.app>

## Qué hace

El cliente escanea el QR de un comercio, obtiene un turno y ve en tiempo real su posición y el tiempo estimado de espera. Mientras espera puede jugar a un minijuego, completar misiones y consultar las ofertas del día del comercio. El comercio gestiona su cola desde un panel propio.

- **Turnos en tiempo real:** cada turno guarda número, posición y ETA (`personas por delante × tiempo medio por cliente`) en Firestore y se actualiza por streams.
- **Acceso sin fricción para el cliente:** autenticación anónima con Firebase, sin registro.
- **Panel de comercio:** login con email y contraseña y gestión de la cola.
- **Capa gamificada:** minijuego *runner* en pixel art (canvas), misiones y ofertas del día.

## Tecnologías

| Parte | Stack |
|---|---|
| App móvil / escritorio | Flutter (Dart SDK ^3.9), `firebase_auth`, `cloud_firestore`, `mobile_scanner` (QR), `shared_preferences`, `url_launcher` |
| Web | HTML, CSS y JavaScript sin framework, Firebase JS SDK 12.6 (Auth, Firestore, Analytics), canvas 2D para el minijuego |
| Backend | Firebase: Authentication (anónimo y email/contraseña), Cloud Firestore |
| Despliegue web | Firebase Hosting |

## Estructura del proyecto

```
QueueQuest/
├── queuequest_app/            # App Flutter (android, ios, web, windows, macos, linux)
│   └── lib/
│       ├── main.dart          # Inicializa Firebase y arranca la app
│       ├── app.dart           # Rutas: /, /scan, /commerce, /ticket, /offers, /missions
│       ├── firebase_options.dart
│       ├── screens/           # home, qr_scan, commerce_landing, ticket, missions, offers
│       └── services/
│           └── queue_service.dart   # Solicitud de turno y streams de cola/turno
├── front/                     # Web estática desplegada en Firebase Hosting
│   ├── index.html             # Vista del cliente
│   ├── login.html             # Login del comercio
│   ├── comercio.html          # Panel del comercio
│   ├── juego.html             # Minijuego
│   ├── src/                   # Sprites, fondos y fuente (pixel art)
│   └── firebase.json
└── LICENSE
```

### Modelo de datos (Firestore)

```
colas/{comercioId}                 numeroActual, tiempoMedioMinutos
  └── turnos/{ticketId}            numero, estado, creadoEn, eta, posicion, uid
```

## Instalación y ejecución

### App Flutter

Requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) con Dart ≥ 3.9.

```bash
cd queuequest_app
flutter pub get
flutter run
```

La configuración de Firebase está en `lib/firebase_options.dart`. Si usas tu propio proyecto de Firebase, regénerala con [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/):

```bash
flutterfire configure
```

### Web

No necesita compilación. Sírvela con cualquier servidor estático o con Firebase:

```bash
cd front
npx firebase-tools serve --only hosting
```

Para desplegar (requiere acceso al proyecto de Firebase configurado en `.firebaserc`):

```bash
npx firebase-tools deploy --only hosting
```

## Licencia

[GNU GPL v3](LICENSE)

---

[ENG] Special thanks for the assets to:

    - Warren Clark -> 
      - web: https://itch.io/profile/lionheart963 
      - RRSS: https://x.com/WoostarsPixels
  
    - Pixfinity ->
      - web: https://pixfinity.carrd.co/
      - RRSS: https://x.com/The_pixfinity
  
    - Datagoblin (Vinícius Menézio) ->
      - web: https://menez.io/
      - RRSS: https://x.com/vmenezio
  
[ESP] Especial agradecimiento por los assets a:

    - Warren Clark -> 
      - web: https://itch.io/profile/lionheart963 
      - RRSS: https://x.com/WoostarsPixels
  
    - Pixfinity ->
      - web: https://pixfinity.carrd.co/
      - RRSS: https://x.com/The_pixfinity
  
    - Datagoblin (Vinícius Menézio) ->
      - web: https://menez.io/
      - RRSS: https://x.com/vmenezio
