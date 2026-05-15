# Instrucciones para el Owner de la cuenta "Radio TeleTaxi" en Google Play Console

> Este documento explica cómo solicitar a Google el cambio de la **upload key** de la app "Radio TeleTaxi - Oficial" (`com.radioteletaxi.app`). Es necesario porque la empresa que subió la app en 2023 conserva el keystore original y no podemos firmar nuevas versiones con la clave actual.
>
> El procedimiento es estándar de Google, **no afecta a los 19.400 usuarios actuales** ni rompe la app instalada; sólo cambia con qué clave podemos firmar las nuevas versiones que subamos.
>
> Tiempo total: **5 minutos** del Owner + **1-2 días laborables** de espera a Google.

---

## Lo que necesitas a mano

1. **Usuario Owner / Admin** de la cuenta de organización "Radio TeleTaxi" en Play Console (ID `7778656863799887990`). Si no estás seguro de qué cuenta es, es la principal que paga la cuota anual y tiene control total. La cuenta con la que estuve antes tenía permisos limitados ("Necesitas permiso" salía bloqueado).

2. **El certificado PEM** ya generado. Está aquí:
   ```
   C:\Users\Admin\AndroidKeystores\rtt-upload-certificate.pem
   ```
   Tamaño: 1.344 bytes. Si abres el archivo verás algo como:
   ```
   -----BEGIN CERTIFICATE-----
   MIIDozCCAougAwIBAgIIZBcjNc5cjeYwDQYJKoZIhvcNAQEMBQAwfzELMAkGA1UE
   ...
   -----END CERTIFICATE-----
   ```
   **Si vas a hacer el trámite en otro PC**, cópialo en un pendrive o adjúntalo a un email cifrado para ti mismo. Es la huella pública de nuestra nueva clave de firma, así que aunque alguien lo intercepte no compromete nada — pero por orden lo mejor es no airearlo.

---

## Paso a paso

### 1. Entra en Play Console como Owner

URL directa:
```
https://play.google.com/console/u/0/developers/7778656863799887990/app/4976461555978627244/keymanagement
```

(o navega: **Inicio** → app **"Radio TeleTaxi - Oficial"** → barra izquierda **Probar y publicar** → **Integridad de la app** → **Firma de aplicaciones** → botón **Ajustes**.)

### 2. Haz scroll hacia abajo dentro de "Firma de aplicaciones"

Vas a pasar por estas secciones:
1. *Certificado de la clave de firma de aplicación* (la que tiene Google)
2. *Actualizar tu clave de firma de aplicación* — **NO toques esta, no es la que queremos.**
3. *Certificado de clave de subida* — esta es la que vamos a cambiar.
4. **"Solicitar cambio de la clave de subida"** ← aquí es donde tienes que pulsar.

### 3. Pulsa "Solicitar cambio de la clave de subida"

Como Owner el botón debe estar habilitado (a la cuenta anterior le salía "Necesitas permiso"). Si también te lo bloquea a ti, no estás como Owner real — comprueba con qué cuenta has entrado.

### 4. En el diálogo que se abre

Te pedirá:

**a) Motivo del cambio.** Marca la opción:
```
○ Un desarrollador con acceso al almacén de claves ha dejado mi empresa.
```
(es la que mejor describe la situación: el desarrollador anterior tiene el .jks y ya no estamos en contacto.)

**b) Genera una clave de subida.** Ya está generada por nosotros, **salta este paso**.

**c) Exporta el certificado de clave de subida como un archivo PEM.** Ya está exportado por nosotros, **salta este paso**.

**d) Sube el archivo .PEM.** Pulsa el botón de subida y selecciona:
```
C:\Users\Admin\AndroidKeystores\rtt-upload-certificate.pem
```

**e) Pulsa "Solicitar".**

### 5. Confirmación

- Verás un mensaje de que la solicitud está en revisión.
- Google envía un email automático a la cuenta Owner cuando se aplica el cambio. Tardan habitualmente **1-2 días laborables**, ocasionalmente hasta 5.
- Mientras tanto la app sigue funcionando con normalidad para los 19.400 usuarios.

### 6. Cuando llegue el email de Google diciendo "Upload key changed"

Avísame. A partir de ese momento ya puedo subir el AAB que tenemos preparado y la actualización llegará a los usuarios actuales por Play Store sin ningún cambio para ellos.

---

## Datos técnicos (por si Google los pide en algún momento)

- **Cuenta de organización**: Radio TeleTaxi (ID 7778656863799887990)
- **Aplicación**: Radio TeleTaxi - Oficial
- **Package name**: `com.radioteletaxi.app`
- **Versión actual en producción**: 2.0.63 (20063)

- **Firma de aplicación (Google)** — *no cambia*:
  - SHA-256: `BF:84:C5:92:CD:69:A6:72:0F:AC:12:C9:68:B9:C7:55:59:80:5F:B9:D2:7F:DF:30:68:C7:FF:8D:64:3A:F6:75`

- **Upload key actual** (la que perdimos) — *la que se sustituye*:
  - SHA-256: `BF:84:C5:92:CD:69:A6:72:0F:AC:12:C9:68:B9:C7:55:59:80:5F:B9:D2:7F:DF:30:68:C7:FF:8D:64:3A:F6:75`

- **Upload key nueva** (la que sube en el PEM) — *la que pasará a ser válida*:
  - SHA-256: `A6:8E:3B:4C:86:AD:7F:58:B2:73:9C:02:79:6B:13:87:76:F1:54:AC:FA:5D:E2:A0:55:F1:ED:CB:0E:CF:16:C1`
  - SHA-1:   `AF:10:23:4C:41:88:74:CD:15:23:FC:E5:C4:D2:84:3F:00:93:39:7D`
  - Owner:   `CN=Radio TeleTaxi, OU=App Mobile, O=Radio TeleTaxi SA, L=Barcelona, ST=Catalunya, C=ES`
  - Validez: Hasta 29 septiembre 2053

---

## Si Google rechaza la solicitud (raro)

A veces piden documentación adicional para verificar que tienes derecho a cambiar la clave. Suele bastar con:
- Que el Owner conteste desde la cuenta de Google asociada
- Adjuntar acreditación de Radio TeleTaxi SA (CIF, escritura de constitución o certificado equivalente)

Si llega ese caso, avísame y te ayudo a redactarlo.
