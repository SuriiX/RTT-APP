# Mensaje listo para enviarle al cliente (Radio TeleTaxi)

Copia y pega lo que está dentro de la caja según el canal (WhatsApp, email, etc).

---

## Versión corta · WhatsApp

```
Hola, te necesito 5 minutos para una gestión técnica en Google Play Console — bloquea la publicación de la actualización de la app.

La empresa que hizo la app en 2023 conserva la "clave de firma" original y nosotros no la tenemos. Sin esa clave Google no nos deja subir nuevas versiones de la app que tenéis en Play Store. La solución es estándar: tú, como Owner de la cuenta de Google Play Developer de Radio TeleTaxi, pides a Google que cambie la "upload key" a una nueva que yo ya tengo generada. No afecta a los 19.400 usuarios actuales y la app sigue funcionando con normalidad mientras Google lo procesa (1-2 días laborables).

Te paso por email las instrucciones paso a paso y el archivo que tienes que subir (un .pem de 1 KB). ¿Cuándo tienes 5 min?
```

---

## Versión larga · Email

**Asunto:** `Acción de 5 minutos en Play Console para desbloquear la actualización de la app`

**Cuerpo:**

```
Hola,

Estamos a punto de subir la nueva versión de la app de RadioTeleTaxi a Google Play (Internal Testing primero, luego producción). Antes de poder hacerlo, Google nos exige un trámite que solo puedes hacer tú como Owner de la cuenta de desarrollador en Play Console.

QUÉ PASA

La app que está en producción ahora mismo en Play Store fue subida en mayo de 2023 por el equipo anterior. Ese equipo conserva en su PC la "clave de firma" (un archivo cifrado), y sin él Google no permite subir actualizaciones. Esto es una protección normal de Google contra suplantaciones de identidad.

NOSOTROS NO TENEMOS LA CLAVE ORIGINAL Y PROBABLEMENTE EL EQUIPO ANTERIOR YA NO LA CONSERVE O TARDE SEMANAS EN BUSCARLA. Por eso usamos el procedimiento estándar de Google: pedir a Google que sustituya la clave actual por una nueva que nosotros ya hemos generado.

EFECTO PARA LOS 19.400 USUARIOS ACTUALES: NINGUNO

La app instalada sigue funcionando como hasta ahora durante todo el trámite, y después también. Google solo cambia con qué llave nos autoriza a subir versiones nuevas. Para el usuario es invisible.

QUÉ NECESITO QUE HAGAS

1) Entra en Google Play Console con la cuenta Owner de Radio TeleTaxi (la cuenta principal que paga la cuota anual y firma el Developer Distribution Agreement).

2) Sigue el documento detallado que adjunto (INSTRUCCIONES_RESET_UPLOAD_KEY.md). Son 5 minutos y todas las capturas/textos están ahí.

3) En el paso donde te pida subir un archivo .PEM, sube el que también te adjunto: rtt-upload-certificate.pem

4) Cuando Google te confirme por email (en 1-2 días laborables) que han cambiado la clave, avísame por WhatsApp y yo subo la nueva versión de la app a Internal Testing ese mismo día.

Si en algún paso te bloqueas, llámame y lo hacemos juntos por TeamViewer.

Un saludo
```

**Adjuntos a incluir:**

1. `INSTRUCCIONES_RESET_UPLOAD_KEY.md` (raíz del proyecto, junto a este archivo).
2. `rtt-upload-certificate.pem` (está en `C:\Users\Admin\AndroidKeystores\` — cópialo al email).

---

## Si el cliente prefiere que vayas tú a su despacho a hacerlo en su PC

Lleva en un pendrive:

- El archivo PEM: `C:\Users\Admin\AndroidKeystores\rtt-upload-certificate.pem`
- El documento `INSTRUCCIONES_RESET_UPLOAD_KEY.md`

En su PC:

1. Inicia sesión en Play Console con la cuenta Owner del cliente (las credenciales las pone él).
2. Abre el PDF/MD de instrucciones y sigue paso a paso.
3. Toda la información técnica está en el documento.

---

## Una vez hecho

Cuando llegue el email de Google al cliente diciendo *"Your upload key has been changed"* (o similar en castellano), envíame ese email o avísame.

A partir de ese momento:

- El AAB que ya tenemos generado (`app/build/app/outputs/bundle/release/app-release.aab`, 47.9 MB) es válido para subirlo.
- Lo subiré a Internal Testing primero.
- Configuraré el Data Safety Form y la Privacy Policy URL en la ficha.
- Te enviaré el enlace de Internal Testing para que tú y los testers que quieras probéis la app antes de pasarla a producción.
