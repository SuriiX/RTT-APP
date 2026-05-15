# Checklist de Despliegue a App Store — RadioTeleTaxi

Estado al **2026-05-14** tras el PR iOS de Info.plist + PrivacyInfo.xcprivacy.

---

## ✅ Hecho en este PR

| Cambio | Archivo | Por qué |
|---|---|---|
| `CFBundleDisplayName` = "RadioTeleTaxi" (era "App") | `ios/Runner/Info.plist` | Nombre visible debajo del icono en iOS. |
| `CFBundleName` = "RadioTeleTaxi" (era "app") | `ios/Runner/Info.plist` | Nombre interno del bundle. |
| `CFBundleDevelopmentRegion` = `es` (era `$(DEVELOPMENT_LANGUAGE)`) | `ios/Runner/Info.plist` | Región principal. Castellano. |
| `CFBundleLocalizations` = `[es, ca]` | `ios/Runner/Info.plist` | Soporte de idiomas declarado. La app aún no traduce dinámicamente, pero esto evita warnings de App Store. |
| `UISupportedInterfaceOrientations` limitado a **Portrait** | `ios/Runner/Info.plist` | Los mocks son portrait. Evitamos quirks de UI rotada. iPad permite también upside-down. |
| `UIRequiresFullScreen` = `false` | `ios/Runner/Info.plist` | Permite Slide Over en iPad. |
| `NSAppTransportSecurity` con `NSAllowsArbitraryLoads=false` | `ios/Runner/Info.plist` | Forzamos HTTPS estricto. radioteletaxi.com y mdstrm.com lo soportan. Evita la pregunta de Apple Review *"why do you need arbitrary loads"*. |
| `ITSAppUsesNonExemptEncryption` = `false` | `ios/Runner/Info.plist` | Declaración obligatoria desde 2017. La app no implementa criptografía propia, solo usa HTTPS estándar (exento). Evita un formulario en cada envío a App Store Connect. |
| **`PrivacyInfo.xcprivacy`** creado y registrado en `Runner.xcodeproj` | `ios/Runner/PrivacyInfo.xcprivacy` | **Obligatorio desde primavera 2024**. Sin él App Store rechaza el envío. Declara: no hacemos tracking, no recolectamos datos, y las razones aprobadas para usar UserDefaults / FileTimestamp / DiskSpace / SystemBootTime (que usan shared_preferences, cached_network_image, just_audio, audio_service). |
| Iconos y splash iOS | Generados por `flutter_launcher_icons` / `flutter_native_splash` (placeholder hasta que llegue arte oficial). | — |

Cambios validados con PowerShell parser XML — **plists son XML válido** (50 nodos Info.plist, 13 nodos PrivacyInfo).

---

## 🔴 Bloqueadores para subir a TestFlight / App Store

### 1. Apple Developer Account del cliente
Coste: **99 USD / año** (organización) o 99 USD/año (individuo). Tarda ~24h de verificación.

- Si Radio TeleTaxi SA quiere publicar como organización (recomendado), Apple les pide número DUNS — gratuito pero hay que solicitarlo en `https://www.dnb.com`. Tarda 2-5 días laborables.
- Si se publica como individuo (un dev), es inmediato pero la app aparece a nombre de la persona, no de la empresa.

**Acción**: el cliente entra a `https://developer.apple.com/programs/` y se inscribe. Cuando esté listo te pasa el **Team ID** (10 caracteres, formato `XXXXXXXXXX`).

### 2. Mac con Xcode 16+ (o servicio de CI macOS)
Flutter en Windows **no puede compilar `.ipa`**. Necesitas:

- **Opción A**: un Mac (físico, prestado, o virtual en MacInCloud / MacStadium / AWS EC2 Mac).
- **Opción B**: un servicio de CI que compile en macOS por ti:
  - **Codemagic** (`codemagic.io`) — el más Flutter-friendly. 500 minutos gratis al mes en M1. Configuración via YAML, conecta directo a App Store Connect, sube a TestFlight automáticamente.
  - **GitHub Actions** con runner `macos-latest`. Más manual.
  - **Bitrise**, **AppCircle**, etc.

Una vez tengas el Mac (o configurado el CI):

```bash
cd app
flutter build ios --release        # genera .app
# o
flutter build ipa --release        # genera .ipa listo para App Store Connect
```

### 3. Configurar signing en Xcode (5 minutos en Mac)
Con la cuenta Apple del cliente logueada en Xcode:

1. Abrir `app/ios/Runner.xcworkspace` (no el `.xcodeproj`, el workspace).
2. Click en `Runner` (target azul) → **Signing & Capabilities**.
3. Marcar **Automatically manage signing**.
4. Elegir el **Team** del cliente.
5. El **Bundle Identifier** ya está como `com.radioteletaxi.app`. Si está libre, Xcode crea el App ID automáticamente. Si está cogido (porque alguien lo registró en otro Apple ID), hay que cambiarlo.
6. Añadir capability **Background Modes** → marcar `Audio, AirPlay, and Picture in Picture` (el `UIBackgroundModes` del Info.plist ya lo tiene, pero el capability genera el entitlement para distribución).

> **Push notifications** (si se implementan después): añadir también capability **Push Notifications** y configurar **APNs Authentication Key** en developer.apple.com.

### 4. Crear app en App Store Connect
En `https://appstoreconnect.apple.com`:

1. **My Apps → + → New App**.
2. Plataforma: iOS.
3. Nombre: "RadioTeleTaxi".
4. Idioma principal: Spanish.
5. Bundle ID: `com.radioteletaxi.app` (debe estar registrado en developer.apple.com → Certificates, IDs & Profiles → Identifiers).
6. SKU: cualquier identificador interno, por ej. `RTT-APP-2026`.

### 5. Rellenar metadatos de la ficha
| Campo | Contenido |
|---|---|
| **Nombre de la app** | RadioTeleTaxi |
| **Subtítulo** | Tu radio en directo y a la carta |
| **Descripción** | Reciclar la descripción que escribiremos para Play Store. |
| **Categoría primaria** | Música |
| **Categoría secundaria** | Noticias |
| **Privacy Policy URL** | `https://radioteletaxi.com/politica-de-privacidad/` |
| **Soporte URL** | `https://radioteletaxi.com/contacto/` o similar |
| **Marketing URL** | (opcional) `https://radioteletaxi.com` |
| **Capturas de pantalla** | Mínimo 3 por tamaño obligatorio: iPhone 6.7" (mock 1290×2796) y iPhone 5.5" (mock 1242×2208). iPad opcional. |
| **App icon** | 1024×1024, **sin transparencia, sin esquinas redondeadas** (iOS las redondea). |
| **Edad** | Encuesta de contenidos. Para radio sin contenido explícito sale 4+ o 9+. |

### 6. TestFlight (recomendado antes de Producción)

1. Subir el `.ipa` desde Xcode o Codemagic.
2. Esperar 10-30 min mientras Apple procesa el build.
3. Activar **Internal Testing**: hasta 100 testers (deben tener Apple ID), no necesita revisión de Apple.
4. Probar con tu equipo + el cliente durante varios días.
5. Cuando estéis OK, promover a **External Testing** (hasta 10.000 testers, requiere revisión inicial de Apple para el primer build externo, después automático) o directamente a **App Store Production** (revisión más estricta, 24-72h habitualmente).

---

## 🟡 Mejoras opcionales (no bloquean primer release)

| Item | Por qué interesa |
|---|---|
| Push notifications con FCM o APNs directo | El cliente lo pidió. Requiere `GoogleService-Info.plist` y capability Push en Xcode. PR aparte. |
| i18n catalán | El público de RTT incluye catalanoparlantes. Hoy todo el texto en código está en castellano. PR aparte. |
| Tests de UI integración | Para regresiones. Útil cuando hagas releases frecuentes. |
| Optimización de tamaño del `.ipa` | Habilitar bitcode, App Thinning. iOS lo hace automáticamente al subir, no requiere acción. |
| Tipografía corporativa | Si Radio Tele Taxi tiene fuente propia, integrarla con `pubspec.yaml` + `fonts:`. |

---

## 📁 Archivos clave

```
app/ios/Runner/Info.plist               ← branding y capabilities declaradas
app/ios/Runner/PrivacyInfo.xcprivacy    ← manifiesto privacidad Apple 2024
app/ios/Runner.xcodeproj/project.pbxproj← PrivacyInfo registrado en target
```

Cuando trabajes en el Mac, abrir el `.xcworkspace`, no el `.xcodeproj`.

---

## Resumen de bloqueadores combinados (Play + App Store)

| Bloqueador | Tienda | Quién lo resuelve |
|---|---|---|
| Reset upload key Play Console | Play Store | Owner cliente (5 min + 1-2 días Google) |
| Apple Developer Account 99 USD/año | App Store | Cliente (24h verificación + 2-5 días DUNS si organización) |
| Mac con Xcode (o servicio macOS CI) | App Store | Tú (o pago de Codemagic) |
| App en App Store Connect | App Store | Tú con cuenta del cliente |
| Capturas + descripción + Data Safety | Ambas | Tú (te lo preparo cuando avisemos) |

Sin esos 5 ítems, ninguna versión puede llegar a usuarios reales. **Con ellos resueltos, ya está todo el código preparado.**
