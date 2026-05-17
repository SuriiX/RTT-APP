# App nueva: "RTT Lo Nuestro" (com.radioteletaxi.lonuestro)

## Contexto

La app actual "Radio TeleTaxi - Oficial" (`com.radioteletaxi.app`, 19.400 usuarios) está bloqueada para subir nuevas versiones porque:

- El 16 mayo 2026 Google aplicó un reset de upload key con el certificado de Juan Carlos Gil.
- El password del `.jks` correspondiente se perdió.
- Google tiene cooldown de ~365 días entre resets, así que no podemos hacer un segundo reset hasta mayo 2027.

**Decisión** (16 mayo 2026): publicar una **app paralela** con `applicationId` distinto, firmada con un keystore que controlamos por completo. La app original queda intacta para los 19.400 usuarios.

---

## Identidad de la app nueva

| Campo | Valor |
|---|---|
| **applicationId Android** | `com.radioteletaxi.lonuestro` |
| **Bundle ID iOS / macOS** | `com.radioteletaxi.lonuestro` |
| **Nombre visible** | `RTT Lo Nuestro` |
| **versionName + versionCode iniciales** | `1.0.0+1` |
| **Keystore de firma** | `C:\Users\Admin\AndroidKeystores\rtt-release.jks` |
| **Alias** | `rtt` |
| **Password store + key** | `NS3AtgkmpEBJY068FcaX9sdi` |
| **SHA-1 firma** | `AF:10:23:4C:41:88:74:CD:15:23:FC:E5:C4:D2:84:3F:00:93:39:7D` |
| **SHA-256 firma** | `A6:8E:3B:4C:86:AD:7F:58:B2:73:9C:02:79:6B:13:87:76:F1:54:AC:FA:5D:E2:A0:55:F1:ED:CB:0E:CF:16:C1` |

---

## Pasos para publicar en Play Store

1. **Play Console → Crear app** (no es una actualización de la existente).
2. **Nombre**: "RTT Lo Nuestro" (o el que prefieras — el listing es independiente del original).
3. **Package name**: `com.radioteletaxi.lonuestro`.
4. **Política de privacidad URL**: `https://radioteletaxi.com/politica-de-privacidad/` (misma URL, sigue valiendo).
5. **Data Safety form**: idéntico al de la app original (Internet + audio en foreground + preferencias locales, sin recolección de datos personales).
6. **Categoría**: Música.
7. **Activar Play App Signing** en la primera subida (Google guarda copia de la clave; si perdemos `rtt-release.jks` con esto activado, podemos pedir reset). Esta vez no se nos olvida.
8. **Track Open Testing**: subir el AAB `C:\Users\Admin\Downloads\rtt-lonuestro-1.0.0-release.aab`.
9. **Comprobar** que el certificado registrado tras la subida coincide con SHA-256 `A6:8E:3B:4C:86:AD:7F:58:B2:73:9C:02:79:6B:13:87:76:F1:54:AC:FA:5D:E2:A0:55:F1:ED:CB:0E:CF:16:C1` — si Google acepta el AAB, ya coincide.

---

## Archivos generados (16 mayo 2026)

| Archivo | Tamaño | Para qué |
|---|---|---|
| `C:\Users\Admin\Downloads\rtt-lonuestro-1.0.0-release.aab` | 48.92 MB | Subir a Play Console (Open Testing / Production). |
| `C:\Users\Admin\Downloads\rtt-lonuestro-1.0.0-release.apk` | 61.66 MB | Distribuir directo por WhatsApp/Drive a testers. Se instala activando "fuentes desconocidas". |

---

## Diferencias con la app original

Mismo código, mismo backend, misma UI. Lo único distinto:

- `applicationId` / Bundle ID
- Etiqueta visible: "RTT Lo Nuestro" en lugar de "RadioTeleTaxi" (para que los usuarios distingan ambos iconos si tienen las dos instaladas)
- versionCode reseteado a 1 (Play Console la considera app nueva)

Funcionalmente son intercambiables. Si en el futuro recuperamos el `.jks` original (o esperamos al 2027 para hacer otro reset), podemos abandonar esta variante y volver a publicar en la original.

---

## Por qué `com.radioteletaxi.lonuestro` y no otra cosa

- Encaja con el tagline "Lo Nuestro" del logo (visible en la imagen del cliente).
- No es `app2`, `beta`, ni `new` → no transmite que es algo provisional.
- Permite mantener ambas apps en el ecosistema RTT sin ambigüedad de naming.
- Si en el futuro se quiere otra app específica (ej. RTT podcast, RTT en directo) hay espacio para más subdominios bajo `com.radioteletaxi.*`.

Si prefieres otro `applicationId`, cambiarlo es rápido **pero** sólo antes de la primera subida a Play Console. Después queda fijo de por vida — no se puede cambiar el `applicationId` de una app ya publicada.

---

## Plan a futuro

- **Corto plazo**: esta app "Lo Nuestro" sirve como vía oficial para distribuir la versión 2026 de la app a usuarios nuevos.
- **Comunicación a los 19.400 usuarios actuales**: opcionalmente, podemos enseñarles dentro de la app vieja (vía banner / push si se llega a integrar FCM) que existe una nueva versión "Lo Nuestro" y enlazarla. Como nadie puede actualizar la app vieja, los usuarios quedarían en una versión congelada hasta que migren manualmente.
- **Mayo 2027**: cuando termine el cooldown, podemos pedir un nuevo reset de upload key a Google para la app original y volver a recuperar el control. Entonces se decide si seguir con dos apps o consolidar en una.
