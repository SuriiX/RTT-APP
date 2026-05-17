# Segundo reset de upload key — RadioTeleTaxi en Play Console

> Este documento es el **plan B** del reset original ([INSTRUCCIONES_RESET_UPLOAD_KEY.md](INSTRUCCIONES_RESET_UPLOAD_KEY.md)). Es necesario porque el primer reset se aplicó con un certificado generado por Juan Carlos Gil cuyo password se ha perdido, por lo que ya no podemos firmar AABs aunque tengamos el `.jks`.
>
> Procedimiento idéntico al anterior, sólo cambia el archivo PEM que se sube.
>
> Tiempo: **5 min del Owner + 1-2 días laborables de Google**. Los 19.400 usuarios no se ven afectados.

---

## Contexto rápido (qué pasó)

1. **14 mayo 2026**: Generamos en este PC el keystore `rtt-release.jks` (Radio TeleTaxi SA) + su PEM correspondiente. Owner inició el primer reset con ese PEM.
2. **Entre el 14 y el 16 mayo**: Juan Carlos Gil generó **su propio** keystore `upload-keystore.jks` (CN=Juan Carlos Gil) + su PEM, y subió ESE PEM a Google en vez del nuestro.
3. **16 mayo (hoy)**: Google ya tiene registrado el certificado de Juan Carlos. Comprobado en Play Console → Integridad de la aplicación, SHA-256 visible:
   ```
   6A:89:B4:26:82:16:C8:41:E5:80:95:26:D6:9E:6A:FC:AC:41:60:40:59:C9:60:07:2B:4D:3F:E2:BF:83:B0:43
   ```
4. **Problema**: nadie tiene el password de ese `.jks`. Juan Carlos no lo recuerda. Sin el password no se puede firmar AABs. Y un `.jks` sin password es matemáticamente irrecuperable.
5. **Solución**: pedir a Google un segundo reset apuntando al PEM que SÍ controlamos (el `rtt-upload-certificate.pem` del 14 mayo). Sin pérdida para los usuarios.

---

## Lo que necesitas a mano

1. **Cuenta Owner** de Radio TeleTaxi en Play Console (la misma que usaste el 14 de mayo).
2. **El PEM original**:
   ```
   C:\Users\Admin\AndroidKeystores\rtt-upload-certificate.pem
   ```
   1.344 bytes. Owner: `CN=Radio TeleTaxi SA, OU=App Mobile, L=Barcelona`.
   SHA-256: `A6:8E:3B:4C:86:AD:7F:58:B2:73:9C:02:79:6B:13:87:76:F1:54:AC:FA:5D:E2:A0:55:F1:ED:CB:0E:CF:16:C1`

---

## Paso a paso (idéntico al primer reset)

### 1. Entra a Play Console como Owner

URL directa:
```
https://play.google.com/console/u/0/developers/7778656863799887990/app/4976461555978627244/keymanagement
```

O navega: **Inicio → Radio TeleTaxi - Oficial → Configuración → Integridad de la aplicación → Firma de aplicaciones**.

### 2. Haz scroll hasta el final

Verás otra vez la sección **"Solicitar cambio de la clave de subida"** (el botón vuelve a estar disponible — Google permite múltiples resets, no hay cooldown).

### 3. Pulsa "Solicitar cambio de la clave de subida"

### 4. Diálogo

**a) Motivo**. Marca:
```
○ He perdido el almacén de claves original.
```
(esta vez es literal — el `.jks` que tenía Juan Carlos es irrecuperable porque nadie tiene el password.)

**b) Salta los pasos de generar clave** — ya está hecho.

**c) Sube el PEM**:
```
C:\Users\Admin\AndroidKeystores\rtt-upload-certificate.pem
```

**d) Pulsa "Solicitar"**.

### 5. Espera 1-2 días laborables

Te llegará un email "Your upload key has been changed". Avísame en cuanto lo recibas y subo el AAB que ya tengo construido.

---

## Verificación posterior

Cuando Google confirme, vuelve a la sección **Certificado de clave de subida** y comprueba que ahora aparece:

| Huella esperada | Valor |
|---|---|
| SHA-1 | `AF:10:23:4C:41:88:74:CD:15:23:FC:E5:C4:D2:84:3F:00:93:39:7D` |
| SHA-256 | `A6:8E:3B:4C:86:AD:7F:58:B2:73:9C:02:79:6B:13:87:76:F1:54:AC:FA:5D:E2:A0:55:F1:ED:CB:0E:CF:16:C1` |

Si coincide → todo listo. Si sigue apareciendo el de Juan Carlos → Google aún no ha procesado, espera más.

---

## Qué hacer mientras tanto (1-2 días)

- La versión 2.0.63 actual en Play Store **sigue funcionando** sin cambios para los 19.400 usuarios.
- Para probar la versión 2.0.74 con los iconos nuevos y el fix de fecha/lugar **antes** del lanzamiento oficial, está el APK instalable:
  ```
  C:\Users\Admin\Downloads\rtt-app-2.0.74-release.apk  (61.66 MB)
  ```
  Pásalo por WhatsApp / Drive / Telegram a quien quieras que lo pruebe. Para instalarlo el receptor tiene que activar "Permitir instalar de fuentes desconocidas" → instalar → listo. No requiere Play Store.

---

## Para que esto no vuelva a pasar

- El `.jks` de Juan Carlos (`upload-keystore (1).jks` en Downloads) ya no sirve para nada → bórralo.
- El PEM de Juan Carlos (`upload_certificate.pem` en Downloads) tampoco → bórralo.
- A partir del segundo reset, el único keystore válido es `C:\Users\Admin\AndroidKeystores\rtt-release.jks` con las credenciales documentadas en `C:\Users\Admin\Documents\RTT-CREDENCIALES-KEYSTORE.txt`.
- Guarda copia cifrada de ese `.jks` + sus credenciales en tu gestor de contraseñas (Bitwarden/1Password/Proton Pass) **hoy mismo**. Si lo pierdes esta vez, el tercer reset puede ser más complicado.
