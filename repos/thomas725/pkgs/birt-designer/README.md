# BIRT Designer (Eclipse BIRT 4.22.0) on NixOS – Notes

## Why this is wrapped

- Upstream distributes BIRT as a prebuilt Eclipse bundle with its own launcher.
- On NixOS the launcher needs:
  - `patchelf` to set the dynamic loader (glibc’s `ld-linux-x86-64.so.2`).
  - A Nix‑managed JDK instead of the embedded JustJ runtime.
  - Access to GTK GSettings schemas, otherwise the GTK file chooser crashes.

## File chooser crash

Symptom:

> GLib-GIO-ERROR **: No GSettings schemas are installed on the system

Fix:

- Add `gtk3` to `buildInputs`.
- In the wrapper, set:
  - `GSETTINGS_SCHEMA_DIR` to `gtk3`’s `glib-2.0/schemas` directory.
  - `XDG_DATA_DIRS` to include `${gtk3}/share`.

If the file chooser starts crashing again after updating `gtk3`, check that:

```bash
echo "$GSETTINGS_SCHEMA_DIR"
echo "$XDG_DATA_DIRS"
