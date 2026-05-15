# Patch · Bug de fechas en `rtt-app-api`

## Problema

El endpoint `/app-rest/v1/eventos` devuelve cada `fecha_inicio` y `fecha_fin` **un día por debajo de la fecha que se introdujo en el panel de ACF**.

Ejemplo: el concierto de Los Chunguitos se introdujo como **25/05/2026** y el endpoint devuelve `"24/05/2026"`. La app móvil muestra esa fecha tal cual.

## Causa

En `rtt-app-api.php`, el plugin hace:

```php
date_default_timezone_set('Europe/Madrid');   // línea 539
$fecha_inicio = get_field('fecha_inicio', $id);
$dt = new DateTime($fecha_inicio);            // línea 610 ← bug
$fecha_inicio_txt = $dt->format('d/m/Y');     // línea 618
```

`new DateTime($fecha)` sin segundo argumento usa la TZ por defecto de PHP. Si ACF guardó la fecha como UTC y el servidor está en Madrid (o viceversa), al desplazar la hora se pierde el día cuando la hora es 00:00.

## Fix (1 línea por DateTime)

Reemplazar las 2 ocurrencias de `new DateTime(...)` para forzar la interpretación en Europe/Madrid:

```php
// línea 610 — fecha_inicio
$dt = new DateTime($fecha_inicio, new DateTimeZone('Europe/Madrid'));

// línea 628 — fecha_fin
$dtf = new DateTime($fecha_fin, new DateTimeZone('Europe/Madrid'));
```

(También se aplica el patch a las funciones `endpoint_directo` y `endpoint_programacion` si se cargan otras fechas — sólo si se ven afectadas. En las pruebas actuales únicamente la sección de eventos lo necesita.)

## Cómo aplicarlo

1. WordPress Admin → **Plugins → Editor de archivos de plugins → rtt-app-api**.
2. Localiza la función `endpoint_eventos` (alrededor de la línea 535).
3. Cambia las 2 líneas señaladas arriba.
4. Guarda.
5. Verifica con curl:
   ```bash
   curl -s 'https://radioteletaxi.com/app-rest/v1/eventos' | python -c "import json,sys; d=json.load(sys.stdin); print(d[0]['fecha_inicio'])"
   ```
   Tiene que devolver `"25/05/2026"` (el día correcto que tienes en el panel para Los Chunguitos).

## Por qué no se "arregla" desde la app

Si la app sumara 1 día como workaround, el día que arregles el plugin PHP la app mostraría día+1 sobre la fecha ya correcta, **sumándole otro día** y empeorando el problema.

Es más sano dejar la app tal cual está (muestra lo que dice el backend) y arreglar el origen.
