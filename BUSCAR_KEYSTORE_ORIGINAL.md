# Búsqueda del keystore original de "Radio TeleTaxi - Oficial"

La app `com.radioteletaxi.app` está en producción en Play Store desde **mayo de 2023** con **19.400 usuarios**. Su firma actual tiene este SHA-256:

```
BF:84:C5:92:CD:69:A6:72:0F:AC:12:C9:68:B9:C7:55:59:80:5F:B9:D2:7F:DF:30:68:C7:FF:8D:64:3A:F6:75
```

Necesitamos el **archivo `.jks` (o `.keystore` / `.p12`) que produjo esa firma**, junto con su **contraseña** y **alias**. Sin esos tres datos no podemos actualizar la app.

---

## Dónde mirar

### 🥇 Primer nivel — sitios obvios

1. **Tu propio PC**: busca `*.jks` o `*.keystore` en:
   ```
   C:\Users\Admin\
   ```
   Yo te he dejado el script `app/tool/search_keystores.ps1`, ejecútalo así desde PowerShell:
   ```powershell
   cd C:\Users\Admin\Documents\GitHub\RTT-APP\.claude\worktrees\optimistic-dewdney-daabd3\app
   powershell -File tool\search_keystores.ps1 -SearchPath "C:\Users\Admin"
   ```
   Tarda 2-5 minutos. Marca con ✅ los que coincidan.

2. **Google Drive / OneDrive / Dropbox** de la empresa: buscar por nombre `release`, `keystore`, `radioteletaxi`, `signing`, `rtt`. Lo típico es que la app la subiera alguien y dejara una copia en la nube de la empresa.

3. **Email**: buscar adjuntos `.jks` / `.keystore` o palabras como "release key", "signing key", "keystore" en tu correo y en el de quien gestionara la app en 2023.

### 🥈 Segundo nivel — preguntar al equipo

4. **El desarrollador o agencia que hizo la app en 2023**. La cuenta de Play Console "Radio TeleTaxi" tiene un app "com.radioteletaxi.app" subida el 22/05/2023. Quien subió ese primer AAB tiene el `.jks`. Pregúntale:

   > *Hola, necesito el keystore (.jks) que se usó para firmar la app "Radio TeleTaxi - Oficial" (com.radioteletaxi.app) en mayo de 2023, con su contraseña y alias. Estoy preparando una actualización y Play Store rechaza cualquier firma distinta.*

   Datos que confirman que es el correcto:
   - SHA-256 del certificado: `BF:84:C5:92:CD:69:A6:72:0F:AC:12:C9:68:B9:C7:55:59:80:5F:B9:D2:7F:DF:30:68:C7:FF:8D:64:3A:F6:75`
   - SHA-1: `D2:B5:B1:7F:8A:12:59:A5:D1:DE:30:80:FD:6B:9B:71:34:42:1C:6A`

5. **Repositorios privados de GitHub / GitLab / Bitbucket** del proyecto antiguo: a veces, contra la buena práctica, el `.jks` está commitado en el repo (suele estar en `android/app/` o en una carpeta `keys/`). Mírate ramas viejas también.

6. **Servidor de CI antiguo** (Jenkins, GitHub Actions, Bitrise, Codemagic). Si tenían build automático, el keystore vivía en sus secrets o en una carpeta protegida del servidor.

### 🥉 Tercer nivel — sitios menos obvios

7. **Discos duros antiguos / NAS** de la empresa.
8. **Backups de Time Machine / Acronis / Veeam** de 2023.
9. **Pendrives** en el cajón.

---

## Cómo verificar un candidato que aparezca

Cuando encuentres uno o varios `.jks` posibles, comprueba **cada uno** con el script de verificación. Te pedirá la contraseña:

```powershell
cd C:\Users\Admin\Documents\GitHub\RTT-APP\.claude\worktrees\optimistic-dewdney-daabd3\app
powershell -File tool\verify_keystore.ps1 -KeystorePath "C:\ruta\al\posible.jks"
```

Si imprime:

```
✅✅✅ COINCIDENCIA — este es el keystore correcto.
```

es ese. Guárdalo a buen recaudo (igual de cuidado que con el nuestro nuevo) y avísame con:
- Ruta absoluta del `.jks`
- Contraseña del store
- Contraseña de la key (si es distinta)
- Alias

Yo actualizo `app/android/key.properties`, reconstruyo el AAB firmado correctamente y entonces sí podemos subirlo a Internal Testing.

---

## Qué hacer mientras tanto

- **No subir el AAB que generamos hoy** (`app/build/app/outputs/bundle/release/app-release.aab`) a la app de producción. Está firmado con el keystore nuevo (`A6:8E:...`) y Play Store lo rechazará con *"Your Android App Bundle is signed with the wrong key"*. Lo dejamos guardado por si pasamos al Plan C.

- **Conservar el keystore nuevo** que generé hoy (`C:\Users\Admin\AndroidKeystores\rtt-release.jks`). Si nadie encuentra el original, sirve para el Plan B (reset de upload key via admin).

- **No es urgente**: la app actual en producción sigue funcionando para los 19.400 usuarios mientras buscamos. No estamos perdiendo nada, solo no podemos publicar la versión nueva todavía.

---

## Si después de buscar 48-72 horas no aparece nada

Avísame y pasamos al **Plan B (reset de upload key)**:

1. El Owner / Admin de la cuenta organizacional "Radio TeleTaxi" en Play Console (no el usuario actual que tiene permisos limitados) entra al mismo sitio en *Firma de aplicaciones → Solicitar cambio de la clave de subida*.
2. Yo te genero ahora mismo el `.PEM` que hay que adjuntar para esa solicitud (es el certificado público de mi keystore nuevo).
3. Google tarda 1-2 días laborables en aplicar el cambio.
4. Una vez aplicado, ya podemos subir el AAB firmado con el keystore nuevo sin perder a los 19.400 usuarios.
