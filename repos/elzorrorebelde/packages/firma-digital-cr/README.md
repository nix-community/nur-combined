# firma-digital-cr

Paquetes Nix para usar la Firma Digital de Costa Rica
(https://www.soportefirmadigital.com) en NixOS. El ZIP oficial trae
binarios precompilados para Ubuntu 24.04, empaquetados aquí con
`autoPatchelfHook` y `buildFHSEnv` según lo que cada binario necesita.

## Paquetes disponibles

| Atributo             | Qué es                                                                                            | Uso típico                                      |
|----------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------|
| `ca-certificates`    | 19 certificados CA (Raíz Nacional, Persona Física/Jurídica, SINPE, Sellado de Tiempo, GlobalSign) | Confiar en el sistema (ver abajo)               |
| `pkcs11`             | `libASEP11.so` + `libaseLaserP11.so`                                                              | Cargar en Firefox/Chrome como "security device" |
| `idopte`             | GUI `SCManager` para gestionar la tarjeta/token                                                   | `environment.systemPackages`                    |
| `idocachesrv`        | Daemon de caché de Idopte, necesario para operaciones PKCS#11                                     | `environment.systemPackages` o un servicio      |
| `agente-gaudi`       | Agente de firma del BCCR (bandeja del sistema)                                                    | `environment.systemPackages`                    |
| `nautilus-extension` | Menú contextual en Nautilus (Firmar/Cifrar/Abrir)                                                 | Opcional, ver abajo                             |

Todos viven bajo el atributo `firma-digital-cr` de este repositorio
(`elzorrorebelde/nur`). Si lo agregaste mediante el agregador de NUR
(`nix-community/NUR`), el path completo desde `pkgs` es:

```
pkgs.nur.repos.elzorrorebelde.firma-digital-cr.<atributo>
```

por ejemplo `pkgs.nur.repos.elzorrorebelde.firma-digital-cr.pkcs11`.
Todos los ejemplos de este README usan esa ruta. Si en cambio agregaste
este repo directamente como input de flake (sin pasar por el
agregador de NUR), el atributo queda expuesto sin el prefijo
`nur.repos.elzorrorebelde`: `firma-digital-cr.<atributo>` directamente
en los `packages.<system>` de este flake.

El software es de licencia no libre (`unfreeRedistributable`), así que
necesitas `nixpkgs.config.allowUnfree = true;` en tu configuración, o
exportar `NIXPKGS_ALLOW_UNFREE=1` al compilar manualmente.

## 1. Agregar los certificados CA al sistema

Los certificados vienen en `$out/etc/ssl/certs/` con nombres que
incluyen espacios y paréntesis (p. ej. `CA POLITICA PERSONA FISICA -
COSTA RICA v2(1).crt`), así que en vez de escribirlos uno por uno en tu
`configuration.nix`, generá la lista dinámicamente con
`builtins.readDir`:

```nix
{ pkgs, ... }:

let
  firmaCerts = pkgs.nur.repos.elzorrorebelde.firma-digital-cr.ca-certificates;
  certDir = "${firmaCerts}/etc/ssl/certs";
in
{
  security.pki.certificateFiles =
    map (name: "${certDir}/${name}") (builtins.attrNames (builtins.readDir certDir));
}
```

Esto hace que todo el sistema (curl, navegadores que usan el store de
certificados del sistema, etc.) confíe en las CA de Costa Rica.
Aplicá con `sudo nixos-rebuild switch` y listo — no hace falta tocar
nada más para este paso.

> Nota: hay certificados duplicados con sufijo `(1)`, `(2)`, `(3)` tal
> como vienen en el ZIP oficial (parecen ser reemisiones/renovaciones
> con distintas fechas de vigencia). Agregar todos no hace daño; el
> store de confianza del sistema simplemente terminará con algunas
> entradas repetidas o superpuestas.

## 2. Instalar los programas

```nix
environment.systemPackages = with pkgs.nur.repos.elzorrorebelde.firma-digital-cr; [
  idopte
  idocachesrv
  agente-gaudi
];

services.pcscd.enable = true; # necesario para leer la tarjeta/token
```

Tras `nixos-rebuild switch`, `SCManager` y `Agente-GAUDI` aparecen en
el menú de aplicaciones (tienen `.desktop` generado por este paquete;
el ZIP original no traía ninguno).

`idocachesrv` es un daemon — actualmente se instala solo el binario en
`$out/bin/idocachesrv`; no hay unidad systemd todavía. Si lo necesitás
correr siempre, se puede agregar un `systemd.services` de usuario más
adelante.

## 3. Usar la firma desde el navegador (PKCS#11)

Firefox pide una **ruta real del sistema de archivos**, no una
expresión Nix. Primero resolvé el path real del paquete con:

```bash
# consumiendo este NUR a través del agregador (nixpkgs.overlays con NUR)
nix-build '<nixpkgs>' -A nur.repos.elzorrorebelde.firma-digital-cr.pkcs11 --no-out-link

# consumiendo elzorrorebelde/nur directamente como input de flake
nix build .#firma-digital-cr.pkcs11 --no-link --print-out-paths
```

Cualquiera de los dos imprime algo como:

```
/nix/store/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-firma-digital-cr-pkcs11-26.08
```

Ese es el path que usás: en Firefox, `about:preferences#privacy` →
Certificados → Dispositivos de seguridad → Cargar → pegar:

```
/nix/store/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-firma-digital-cr-pkcs11-26.08/lib/libASEP11.so
```

(agregando `/lib/libASEP11.so` al final del path que obtuviste). Usá
`libaseLaserP11.so` en vez de `libASEP11.so` según el tipo de
lector/token que tengas.

## 4. Extensión de Nautilus (opcional)

Agrega ítems "Firmar", "Cifrar", "Firmar y Cifrar" y "Abrir" al menú
contextual de archivos en GNOME Files, comunicándose con `SCManager`
por HTTP local. No depende de paquetes Python externos (se parchó para
usar solo la librería estándar).

Para habilitarla:

```nix
environment.variables.XDG_DATA_DIRS = [
  "${pkgs.nur.repos.elzorrorebelde.firma-digital-cr.nautilus-extension}/share"
];

environment.systemPackages = [
  pkgs.zenity   # diálogos de error
  pkgs.procps   # pidof, para localizar SCManager
];
```

o, sin tocar variables de entorno globales, symlink por usuario:

```bash
mkdir -p ~/.local/share/nautilus-python/extensions
ln -s ${pkgs.nur.repos.elzorrorebelde.firma-digital-cr.nautilus-extension}/share/nautilus-python/extensions/CryptoshellExtension.py \
  ~/.local/share/nautilus-python/extensions/
```

Requiere `nautilus-python` instalado (`pkgs.nautilus-python`) y
reiniciar Nautilus (`nautilus -q`).

## Notas técnicas

- `idopte` e `idocachesrv` corren dentro de un `buildFHSEnv` porque
  los binarios tienen paths hardcodeados (`/usr/share/SCMiddleware`) y
  usan una versión de OpenSSL más nueva que la que trae `openssl_3` en
  este canal de nixpkgs (se usa `openssl_3_6` explícitamente).
- Las `.so` que ya vienen en el DEB (libcrypto, libssl, libpodofo,
  etc.) tienen prioridad sobre las de nixpkgs vía `RUNPATH
  $ORIGIN:/usr/lib64` — así evitamos mezclar ABIs incompatibles.
- `agente-gaudi` trae su propio JRE embebido; también corre en
  `buildFHSEnv` porque JavaFX necesita X11/GTK/ALSA que `autoPatchelf`
  no puede resolver automáticamente en un runtime tan grande.
- El ZIP fuente no se versiona en git (94 MB); se descarga vía
  `fetchurl` desde una URL externa mantenida por el autor del paquete.
