# Checklist de Despliegue a Google Play Store — RadioTeleTaxi

Estado al **2026-05-14** tras la migración al nuevo backend (`rtt-app-api` + `rtt-mediastream`).

La app es Flutter 3.41, audio en directo con just_audio + audio_service, navegación con `StatefulShellRoute.indexedStack`, mini-player persistente, contenido vía REST de radioteletaxi.com.

---

## Bloqueadores que aún tienes que resolver

### 1. Keystore de producción
La signing infrastructure ya está montada: `android/app/build.gradle.kts` lee `android/key.properties` si existe, y si no cae a la clave debug (sólo para desarrollo).

```bash
# 1) Crea el keystore una sola vez. Guárdalo a buen recaudo + backup cifrado.
keytool -genkey -v -keystore ~/keystores/rtt-release.jks \
        -keyalg RSA -keysize 2048 -validity 10000 -alias rtt

# 2) Copia el template y rellena con tus credenciales
cp app/android/key.properties.example app/android/key.properties
# Edita storePassword, keyPassword y storeFile (ruta absoluta al .jks)

# 3) Build firmado
cd app && flutter build appbundle --release
# → app/build/app/outputs/bundle/release/app-release.aab
```

⚠️ Si pierdes el `.jks` ya no podrás actualizar la app en Play Store. Plan B: activar Play App Signing en la primera subida (Google guarda la clave).

### 2. ~~Endpoints públicos para "A la carta"~~ ✅ RESUELTO

Ya no es bloqueador. La app **scrapea las páginas públicas** de `radioteletaxi.com/a-la-carta/` (`/podcast/`, `/u7d/` y `/{slug}/`) que ya están en producción, y obtiene:

- Los **18 shows** reales (7 podcasts + 11 U7D)
- Sus **episodios** con `data-media-id` y `data-episode-guid`
- La **URL del audio**: `https://mdstrm.com/audio/{media-id}.m3u8` (HLS) — comprobado, devuelve `200 OK`

Verificado con [`app/tool/test_alacarta_scraping.dart`](app/tool/test_alacarta_scraping.dart) (test end-to-end contra la web real). El botón "ESCUCHAR PROGRAMA" y los play de cada episodio cargan el audio directo en `AudioController.ensureInit(audioUrl)`.

Cuando algún día el plugin `rtt-mediastream` exponga endpoints REST nativos, basta con reemplazar `_parseShowList(...)` y `_extractEpisodes(...)` en `AlaCartaRepository`. La UI no cambia.

### 3. Notificaciones push (FCM)
El cliente las mencionó como pendientes. Requieren:
- Crear proyecto en **Firebase Console** (gratis) y registrar la app `com.radioteletaxi.app`.
- Descargar `google-services.json` y dejarlo en `app/android/app/google-services.json`.
- Añadir plugin `firebase_messaging` al `pubspec.yaml` y plugin Gradle correspondiente.
- Decidir desde dónde se disparan las pushes (¿el WordPress al crear una noticia? ¿desde un panel admin?).

Aún **no** se ha implementado en este branch porque depende del proyecto Firebase del cliente y de definir la fuente de las notificaciones. Cuando me pases el `google-services.json` y me digas qué dispara la notificación, lo integro en 1 iteración.

---

## Avisos importantes (no bloquean, pero hay que hacerlos)

| # | Item | Estado |
|---|---|---|
| A1 | **Íconos de launcher**: placeholder generado ("RTT" blanco sobre rojo). Para el lanzamiento sustituir `app/assets/branding/app_icon.png` y `app_icon_foreground.png` y re-ejecutar `dart run flutter_launcher_icons`. | placeholder |
| A2 | **Splash screen**: idem, reemplazar `app/assets/branding/splash_logo.png` y re-ejecutar `dart run flutter_native_splash:create`. | placeholder |
| A3 | **versionCode / versionName**: ahora `1.0.0+1` en `pubspec.yaml:19`. Cada publicación en Play Store debe incrementar al menos el `+N`. | OK para 1.0.0 |
| A4 | **applicationId** `com.radioteletaxi.app` queda fijo de por vida. No tocar tras la primera publicación. | OK |
| A5 | **Política de Privacidad URL en Play Console**: enlazar a `https://radioteletaxi.com/politica-de-privacidad/`. Si esa URL llegara a caer la app sigue funcionando porque tiene fallback offline empaquetado. | OK |
| A6 | **Data Safety Form** en Play Console: declarar que la app accede a Internet, almacena localmente preferencias + favoritos, **no recolecta** datos personales, reproduce audio en foreground service. | a rellenar |
| A7 | **Target API level**: heredado de Flutter (cumple los mínimos actuales de Play Store). | OK |
| A8 | **minSdk = 24** (default de Flutter 3.41, restablecido en cada `flutter build`). Cubre ~95 % del parque. Si quieres bajar a 21 hay que parchear esto en cada upgrade. | OK |
| A9 | **MediaSession en lockscreen + notificación**: probar manualmente en Android 12+ que los controles aparecen. | a probar |
| A10 | **Términos de Uso publicados en web**: la app los carga desde `https://radioteletaxi.com/terminos-de-uso-app/` (ahora 404) pero **cae al fallback empaquetado** dentro de la app. Cuando publiques la página real, basta con que la URL exista y el contenido es el que escribí en `app/assets/legal/terms_of_use.html` — puedes copiarlo tal cual a tu WordPress. | OK con fallback |

---

## Lo que se hizo en esta sesión

### Configuración Android para Play Store
- `AndroidManifest.xml`: label "RadioTeleTaxi", `allowBackup=false`, `dataExtractionRules`, permisos `WAKE_LOCK` + `ACCESS_NETWORK_STATE`, `MediaButtonReceiver` + `MediaBrowserService` para audio_service.
- `build.gradle.kts`: signing config con `key.properties`, `isMinifyEnabled=true`, `isShrinkResources=true`, `multiDexEnabled`, `coreLibraryDesugaring`.
- `proguard-rules.pro`: reglas para Flutter, ExoPlayer, audio_service, just_audio.
- `key.properties.example`: paso a paso para `keytool`.
- Íconos y splash generados con [tool/generate_branding.py](app/tool/generate_branding.py).

### Migración de backend
- Eliminados los endpoints muertos `/rtt-app/v1/home`, `/settings`, `/cover.jpg`, `/directo`, `/programacion`, `/frecuencias`, `/eventos/{id}` y `/actualidadv2` del plugin viejo (devolvían la URL del stream como placeholder `mdstrm_XXXXX.com`).
- Migrado todo a `https://radioteletaxi.com/app-rest/v1/*` del nuevo plugin `rtt-app-api`.
- **Stream URL**: la app ya no la lee de `/settings`. Apunta a `/app-rest/v1/streaming-android`, que el servidor resuelve con un 302 a la URL real de Mediastream. http.Client sigue redirects automáticamente.
- `EventosRepository` ahora cachea la lista en memoria y resuelve detalle por id local (el plugin nuevo no expone `/eventos/{id}`).
- `AppConfig.init(settings)` eliminado: los datos corporativos (teléfono, redes, WhatsApp) están como constantes en `app_config.dart`.

### Cumplimiento legal y privacidad
- Política de Privacidad: URL pública corregida a `radioteletaxi.com/politica-de-privacidad/` (la real, no la rota `/politica-de-privacidad-app/`).
- Términos de Uso: redactados como HTML empaquetado en `app/assets/legal/terms_of_use.html`. Incluye los 12 puntos legales habituales para una app de radio en España (responsable, edad 14+, licencia, propiedad intelectual, RGPD/LOPD-GDD, terceros, jurisdicción Barcelona, contacto).
- **Fallback offline**: ambas pantallas legales descargan el HTML público, y si la URL devuelve 4xx/5xx o no hay conexión, caen al asset empaquetado. La app **nunca** se queda sin política/términos.
- "Eliminar mis datos" (GDPR) intacto y funcional, ahora desde Mi Perfil → Datos.

### Refactor visual según mocks
- **`AppShell`** con `StatefulShellRoute.indexedStack`: 4 branches independientes (En directo / A la carta / Entradas / Mi perfil), cada uno conserva su pila de navegación al cambiar de tab.
- **Mini-player persistente** rojo sobre el bottom nav, con play/pause, título del programa y waveform decorativo.
- **Bottom nav** negro con 4 iconos (rojo activo, blanco inactivo) según las capturas.
- **Home rediseñada**: hero con cover cuadrado + título programa + presentador + horario, carrusel horizontal de Actualidad con miniaturas circulares, carrusel horizontal de Entradas a la venta.
- **A la carta** completa: chips Todo / Podcasts / U7D, carrusel horizontal de podcasts con iconos de mic, lista de "Últimos 7 días" con play + menú. Muestra estado vacío explícito mientras el backend no exponga los endpoints.
- **Detalle de Show** según el mockup de "Las Entrevistas de RTT": cover grande + título + descripción + botón "ESCUCHAR PROGRAMA" + favorito + lista de episodios con fecha y duración.
- **Mi Perfil**: nueva pantalla con Contenidos (Favoritos, Programación, Frecuencias), Síguenos (FB / X / IG / YT), General (Notificaciones, Privacidad, Términos), Información (Sobre la app, Licencias OSS), Datos (Eliminar mis datos).
- Eliminado el `RttDrawer` antiguo y la `SettingsPage` antigua.

### Build release verificado
- `flutter analyze`: 48 warnings `info` (estilo), **0 errors / 0 warnings reales**.
- `flutter build appbundle --release`: éxito → `app/build/app/outputs/bundle/release/app-release.aab` **47.9 MB** firmado con clave debug (sustituir por keystore real, ver bloqueador #1).

---

## Pasos de publicación en Play Console

1. Cuenta de Developer (25 USD una sola vez).
2. **Listing**: nombre "RadioTeleTaxi", icono 512×512, feature graphic 1024×500, mínimo 2 capturas.
3. **App content**:
   - Privacy policy URL: `https://radioteletaxi.com/politica-de-privacidad/`.
   - Target audience: 13+ / 14+ (la app pide confirmación de 14+ via `ConsentService`).
   - Ads: No.
   - Data Safety: ver A6.
4. **Release → Internal testing**: subir el AAB firmado con tu keystore, añadir 1-2 testers, validar instalación.
5. Promover a **Closed testing** y luego a **Production** cuando esté validado en al menos dos dispositivos reales (un Pixel y un Samsung típicos cubren la mayoría de casos).

---

## Resumen ejecutivo

- ✅ **Código Flutter**: nuevo diseño según mocks aplicado en todas las pantallas, navegación por bottom nav con 4 tabs, mini-player persistente, build release compila y produce AAB válido.
- ✅ **Backend**: migrado al nuevo plugin `rtt-app-api`, stream URL resuelta vía `/streaming-android` (302 a Mediastream).
- ✅ **Legal**: política de privacidad apunta a la URL correcta del WordPress + términos de uso redactados y empaquetados con fallback offline.
- 🔴 **Pendiente cliente**: (a) generar y configurar keystore de producción, (b) publicar endpoints públicos en `rtt-mediastream` para que "A la carta" tenga datos, (c) crear proyecto Firebase y aportar `google-services.json` para activar las pushes.
- 🟡 **Pendiente cuando llegue arte oficial**: sustituir 3 PNG en `app/assets/branding/` y re-ejecutar los dos scripts de iconos/splash.

Con los 3 bloqueadores resueltos por tu lado, la app está lista para Internal Testing en Play Store.
