# Instrucciones para compilar iOS — Mac

Pasos exactos para compilar la app en el Mac sin errores. Si Xcode falla, casi seguro que algo de aquí no se ha hecho.

---

## 1. Antes de tocar Xcode (terminal)

```bash
cd ~/Desktop/RTT-APP-main/app   # o donde tengas el repo
flutter clean
flutter pub get
cd ios
pod install
```

`pod install` debe terminar con `Pod installation complete!`. Si falla, casi siempre es porque `flutter pub get` no se ejecutó antes (ver `app/ios/Podfile` líneas 13-24 para el mensaje exacto).

---

## 2. Abrir el proyecto en Xcode

**SIEMPRE** abrir `Runner.xcworkspace` (icono blanco), **NUNCA** `Runner.xcodeproj` (icono azul).

```bash
open Runner.xcworkspace
```

Si abres el `.xcodeproj` directamente, los pods no se enlazan y el build falla con errores tipo `Unable to open base configuration reference file 'Pods/Target Support Files/...'`.

---

## 3. Configurar firma de código (Signing & Capabilities)

**Esto es lo que te falló en el último build** (`install_code_assets failed: Failed to code sign binary`).

1. En la barra lateral izquierda de Xcode, selecciona el proyecto **Runner** (icono azul arriba del todo).
2. En la columna del medio, selecciona el target **Runner**.
3. Pestaña **Signing & Capabilities**.
4. Marca ✅ **Automatically manage signing**.
5. En **Team**, despliega el menú y selecciona la cuenta de Apple Developer del cliente (Radio TeleTaxi SA, o la cuenta personal si aún no se ha contratado la membresía de empresa).
   - Si no aparece la cuenta del cliente: Xcode → Settings → Accounts → `+` → Apple ID → inicia sesión.
   - Si dice **"Failed to register bundle identifier com.radioteletaxi.app"**: alguien más en el equipo ya lo registró. Mira en [https://developer.apple.com/account/resources/identifiers](https://developer.apple.com/account/resources/identifiers).
6. **Bundle Identifier** debe quedar en `com.radioteletaxi.app`. No cambiarlo.

Cuando Team queda seleccionado, Xcode genera/descarga automáticamente:
- Apple Development certificate
- Provisioning profile para `com.radioteletaxi.app`

Esto se escribe en `Runner.xcodeproj/project.pbxproj` como `DEVELOPMENT_TEAM = XXXXXXXXXX;`. **Después de seleccionar Team, hacer commit del pbxproj** para que quede guardado para siempre.

---

## 4. Compilar

### Para probar en simulador
- Destination: cualquier iPhone simulator (p.ej. "iPhone 15 Pro").
- ⌘B (Build) o ⌘R (Run).
- La firma no aplica en simulador — debería funcionar siempre.

### Para probar en un iPhone físico
- Conecta el iPhone por cable y desbloquéalo.
- Destination: tu iPhone.
- ⌘R. La primera vez, en el iPhone: Settings → General → VPN & Device Management → confiar en el certificado.

### Para subir a TestFlight / App Store
- Destination: **Any iOS Device (arm64)**.
- Product → **Archive** (NO Build).
- Cuando termine se abre el Organizer → Distribute App → App Store Connect → Upload.

O por línea de comandos:
```bash
cd app
flutter build ipa --release
```
El `.ipa` queda en `build/ios/ipa/`. Súbelo con Transporter (app gratis de Apple).

---

## 5. Errores típicos y cómo arreglarlos

| Error | Causa | Solución |
|---|---|---|
| `Unable to open base configuration reference file 'Pods/Target Support Files/...'` | Falta `pod install` o se abrió `.xcodeproj` en vez de `.xcworkspace`. | Paso 1 + abrir `.xcworkspace`. |
| `install_code_assets failed: Failed to code sign binary` | No hay Team seleccionado en Signing & Capabilities. | Paso 3. |
| `No profiles for 'com.radioteletaxi.app' were found` | Team seleccionado pero no tiene permisos para ese bundle ID. | Verificar en [developer.apple.com](https://developer.apple.com/account/resources/identifiers) que el bundle ID exista en el team. |
| `'IPHONEOS_DEPLOYMENT_TARGET' is set to 9.0` (warning) | `pod install` se ejecutó con una versión antigua del `Podfile`. | `cd ios && rm -rf Pods Podfile.lock && pod install`. |
| `error: the file "Generated.xcconfig" couldn't be opened` | No se ejecutó `flutter pub get`. | Paso 1. |
| `Command PhaseScriptExecution failed with a nonzero exit code` (sin más contexto) | Click en el error para ver el log completo. Suele ser uno de los de arriba. | — |

---

## 6. Cosas que NO hacer

- ❌ Cambiar el Bundle Identifier (`com.radioteletaxi.app`). Ya está registrado.
- ❌ Subir `Pods/`, `Podfile.lock`, `Flutter/Generated.xcconfig` al repo (todos gitignored).
- ❌ Subir el certificado `.p12` ni el provisioning profile `.mobileprovision` al repo.
- ❌ Compartir el Team ID en un canal público (no es ultra secreto pero tampoco se publica).
