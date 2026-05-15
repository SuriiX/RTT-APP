# Convenciones de trabajo · RTT-APP

Notas internas que cualquier agente Claude debe leer al empezar a trabajar en este repo.

## Preferencias del usuario

- **Validar proactivamente las dependencias externas.** Antes de declarar algo como "funciona", probar:
  - Estado HTTP de las URLs (200/302/404)
  - User-Agents de los clientes reales (ExoPlayer, AVPlayer, Dart-http)
  - Comportamiento con/sin cookies, Referer, headers personalizados
  - TLS / certificados / IPv4-IPv6
  - Manifiestos HLS hasta los segments (no quedarse en el manifest master)
  - Rate limiting y latencia desde España
  - Si el servicio usa tokens firmados: calcular TTL real
- **No suponer que algo del backend va a fallar sin haber comprobado.** Hacer curl con los headers reales y reportar números.
- **Antes de tocar producción** (Play Store, App Store, BD del cliente) parar y confirmar — aunque el modo Auto esté activo.

## Convenciones del proyecto

- Backend principal: plugin WordPress `rtt-app-api` en `https://radioteletaxi.com/app-rest/v1/*`.
- Backend secundario: plugin WordPress `rtt-mediastream` (espejo BBDD de Mediastream). Aún no expone endpoints públicos → la app scrapea las páginas `/a-la-carta/...`.
- Audio en directo: `GET /app-rest/v1/streaming-android` → 302 a CDN de Mediastream (icecast AAC+).
- Audio a la carta: `https://mdstrm.com/audio/{mediaId}.m3u8` (HLS VOD, codec HE-AAC, tokens firmados con TTL 24h).
- App firmada con keystore del cliente para Play Store (Play App Signing activado).
- iOS: cumple Privacy Manifest 2024 (`PrivacyInfo.xcprivacy`).
- Sólo portrait. minSdk Android = 24. iOS deployment target = el default de Flutter.

## Archivos clave a leer al empezar

- [PLAY_STORE_CHECKLIST.md](PLAY_STORE_CHECKLIST.md) — bloqueadores y estado para Play.
- [APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md) — bloqueadores y estado para App Store.
- [IOS_BUILD_INSTRUCCIONES.md](IOS_BUILD_INSTRUCCIONES.md) — pasos exactos en el Mac (pod install, signing, archive).
- [INSTRUCCIONES_RESET_UPLOAD_KEY.md](INSTRUCCIONES_RESET_UPLOAD_KEY.md) — paso a paso para Owner del cliente.
- [MENSAJE_AL_CLIENTE.md](MENSAJE_AL_CLIENTE.md) — texto listo para enviar.

## Cosas que NUNCA hacer

- Subir `key.properties` al repo (gitignored, contiene contraseñas).
- Subir el `.jks` al repo.
- Subir el `rtt-upload-certificate.pem` (técnicamente público, pero por orden fuera).
- Bajar el versionCode (cada release sube).
- Aceptar Developer Distribution Agreement de Google ni Apple sin confirmación explícita del cliente.
- Hacer push directo a `main`, siempre PR.
- Modificar ramas remotas que no creó esta sesión sin avisar.
