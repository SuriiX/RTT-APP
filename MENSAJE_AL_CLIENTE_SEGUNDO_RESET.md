# Mensaje al Owner para hacer el segundo reset hoy

## Versión WhatsApp / corta

```
Hola, mala noticia con el primer reset de Play Console: el .jks que se
subió tiene su contraseña perdida (Juan Carlos no la encuentra), así
que aunque Google lo aceptó, nadie puede firmar la nueva versión con él.
Hay que pedir a Google un segundo reset apuntando al PEM original que
generamos en mi PC (donde sí controlamos la contraseña). Mismo
procedimiento que la otra vez, 5 min tuyos + 1-2 días de Google. Sin
afectación a los usuarios actuales. Te paso por email las instrucciones
y el archivo. ¿Cuándo tienes 5 min hoy? Cuanto antes lo solicites,
antes Google lo aplica y antes lanzamos la versión nueva.
```

## Versión email

**Asunto:** `Segundo reset de upload key en Play Console — 5 min y desbloqueamos la publicación`

**Cuerpo:**

```
Hola,

Mala noticia con el reset de upload key del 14 de mayo: el certificado
que se subió a Google fue uno generado por Juan Carlos en lugar del que
preparamos nosotros. Google lo aceptó, pero la contraseña de ese keystore
se ha perdido (Juan Carlos no la encuentra y un keystore sin contraseña
es matemáticamente irrecuperable, no es algo que se pueda forzar).

Resultado: aunque tenemos el archivo .jks, no podemos firmar la nueva
versión de la app con él. La app de 19.400 usuarios sigue funcionando
sin problema — esto sólo afecta a la capacidad de SUBIR actualizaciones.

SOLUCIÓN

Hacer un segundo reset de upload key, esta vez apuntando al certificado
PEM que generamos en mi PC el 14 de mayo (donde sí tengo la contraseña
guardada y respaldada). Google permite reset múltiples veces, no hay
cooldown.

QUÉ NECESITO QUE HAGAS

Lo mismo que la otra vez, idéntico procedimiento:

1) Entra en Play Console como Owner.

2) App "Radio TeleTaxi - Oficial" → Configuración → Integridad de la
   aplicación → Firma de aplicaciones.

3) Scroll abajo → "Solicitar cambio de la clave de subida".

4) Motivo: "He perdido el almacén de claves original" (esta vez es
   literalmente cierto).

5) Saltas los pasos de generar clave / exportar PEM (ya está hecho).

6) En "Sube el PEM", sube ESTE archivo (el que generamos en mi PC,
   no el de Juan Carlos):
   
       C:\Users\Admin\AndroidKeystores\rtt-upload-certificate.pem
   
   (Te lo adjunto en este email para que lo bajes y subas tú desde tu
   PC.)

7) Pulsas "Solicitar".

Google tarda 1-2 días laborables en aplicar el cambio. Te llegará un
email "Your upload key has been changed" y a partir de ahí subo el AAB
en horas.

DETALLES TÉCNICOS POR SI GOOGLE LOS PIDE

- Upload key actual (la rota): CN=Juan Carlos Gil
  SHA-256: 6A:89:B4:26:82:16:C8:41:E5:80:95:26:D6:9E:6A:FC:AC:41:60:
           40:59:C9:60:07:2B:4D:3F:E2:BF:83:B0:43

- Upload key nueva (la que sube): CN=Radio TeleTaxi SA
  SHA-256: A6:8E:3B:4C:86:AD:7F:58:B2:73:9C:02:79:6B:13:87:76:F1:54:
           AC:FA:5D:E2:A0:55:F1:ED:CB:0E:CF:16:C1
  SHA-1:   AF:10:23:4C:41:88:74:CD:15:23:FC:E5:C4:D2:84:3F:00:93:39:7D

MIENTRAS GOOGLE PROCESA

He preparado un APK directo de la versión nueva (2.0.74) con los iconos
RTT actualizados y el fix de fecha/lugar separados en las cards de
entradas. Te lo paso por WhatsApp para que tú y los testers que quieras
podáis probarlo desde el móvil sin esperar a Play Store. Se instala
activando "fuentes desconocidas" en Android.

Un saludo
```

**Adjuntos:**

1. `INSTRUCCIONES_SEGUNDO_RESET_UPLOAD_KEY.md` (raíz del proyecto)
2. `C:\Users\Admin\AndroidKeystores\rtt-upload-certificate.pem`
3. (Opcional) `C:\Users\Admin\Downloads\rtt-app-2.0.74-release.apk` (61.66 MB) — para que el cliente lo pruebe
