{
  lib,
  stdenv,
  kicad,
  adwaita-icon-theme,
  cups,
  dconf,
  darwin,
  gsettings-desktop-schemas,
  gtk3,
  hicolor-icon-theme,
  libngspice,
  librsvg,
  makeWrapper,
  runCommand,
  symlinkJoin,
}:

# nixpkgs marks KiCad broken on Darwin and disables ngspice there. KiCad's
# CMake code also assumes an embedded Python.framework, which Nix's Python does
# not provide, and the KiCad library repositories install their data at the
# output root rather than under share/kicad.
let
  isDarwin = stdenv.hostPlatform.isDarwin;

  kicadWithNgspice = kicad.override { withNgspice = true; };

  base = kicadWithNgspice.base.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      broken = false;
    };

    patches = (old.patches or [ ]) ++ [ ./darwin.patch ];

    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      "-DNGSPICE_LIB_NAME:STRING=libngspice.0.dylib"
      "-DNGSPICE_LIBRARY:FILEPATH=${libngspice}/lib/libngspice.0.dylib"
    ];
  });

  libraries = kicadWithNgspice.passthru.libraries;

  template_dir = symlinkJoin {
    name = "KiCad_template_dir";
    paths = [
      "${libraries.templates}/template"
      "${libraries.footprints}/template"
      "${libraries.symbols}/template"
    ];
  };

  baseWithTemplate = runCommand "kicad-stock-data" { } ''
    mkdir -p "$out"

    for entry in ${base}/KiCad.app/Contents/SharedSupport/*; do
      name="$(basename "$entry")"
      if [[ "$name" != template ]]; then
        ln -s "$entry" "$out/$name"
      fi
    done

    ln -s ${template_dir} "$out/template"
  '';

in
if !isDarwin then
  kicad
else
  kicadWithNgspice.overrideAttrs (old: {
    pname = "kicad_patched";
    base = base;
    src = base;

    inherit template_dir baseWithTemplate;
    stockDataPath = baseWithTemplate;

    makeWrapperArgs = [
      "--prefix XDG_DATA_DIRS : ${base}/KiCad.app/Contents/SharedSupport"
      "--prefix XDG_DATA_DIRS : ${hicolor-icon-theme}/share"
      "--prefix XDG_DATA_DIRS : ${adwaita-icon-theme}/share"
      "--prefix XDG_DATA_DIRS : ${gtk3}/share/gsettings-schemas/${gtk3.name}"
      "--prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
      "--prefix XDG_DATA_DIRS : ${cups}/share"
      "--prefix GIO_EXTRA_MODULES : ${dconf}/lib/gio/modules"
      "--set-default KICAD10_FOOTPRINT_DIR ${libraries.footprints}/footprints"
      "--set-default KICAD10_SYMBOL_DIR ${libraries.symbols}/symbols"
      "--set-default KICAD10_TEMPLATE_DIR ${template_dir}"
      "--set-default NIX_KICAD10_STOCK_DATA_PATH ${baseWithTemplate}"
      "--set-default KICAD10_3DMODEL_DIR ${libraries.packages3d}/3dmodels"
      "--prefix LD_LIBRARY_PATH : ${libngspice}/lib"
      "--set GDK_PIXBUF_MODULE_FILE ${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
    ];

    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      darwin.cctools
      darwin.signingUtils
      makeWrapper
    ];

    pythonPath = old.pythonPath;

    installPhase = ''
      runHook preInstall

      buildPythonPath "${base} ''${pythonPath[*]}"

      mkdir -p "$out/Applications"
      cp -R ${base}/KiCad.app "$out/Applications/KiCad.app"
      chmod -R u+w "$out/Applications/KiCad.app"

      python_versions="$out/Applications/KiCad.app/Contents/Frameworks/Python.framework/Versions"
      python_version="$(find "$python_versions" -mindepth 1 -maxdepth 1 -type d -print | head -n 1)"
      ln -s "$(basename "$python_version")" "$python_versions/Current"

      for tool in kicad kicad-cli dxf2idf idf2vrml idfcyl idfrect pcbnew eeschema gerbview pcb_calculator pl_editor bitmap2component; do
        executable=$out/Applications/KiCad.app/Contents/MacOS/"$tool"
        case "$tool" in
          pcbnew | eeschema | gerbview | pcb_calculator | pl_editor | bitmap2component)
            executable=$out/Applications/KiCad.app/Contents/Applications/"$tool".app/Contents/MacOS/"$tool"
            ;;
        esac

        makeWrapper "$executable" "$out/bin/$tool" \
          $makeWrapperArgs \
          --set PYTHONPATH "$program_PYTHONPATH"
      done

      runHook postInstall
    '';

    postInstall = "";
    dontFixup = false;

    postFixup = ''
      source ${darwin.signingUtils}

      app="$out/Applications/KiCad.app"
      find "$app" -type f \( -perm -111 -o -name '*.dylib' -o -name '*.so' -o -name '*.kiface' \) |
      while IFS= read -r file; do
        changed=
        while IFS= read -r dependency; do
          install_name_tool -change "$dependency" \
            "$app/Contents/Frameworks/''${dependency##*/}" "$file"
          changed=1
        done < <(otool -L "$file" | awk 'NR > 1 && $1 ~ "^/nix/var/nix/builds/" { print $1 }')

        case "$file" in
          *.dylib)
            install_id=
            while IFS= read -r install_id; do
              install_name_tool -id "$app/Contents/Frameworks/''${install_id##*/}" "$file"
              changed=1
            done < <(otool -D "$file" | awk 'NR == 2 && $1 ~ "^/nix/var/nix/builds/" { print $1 }')
            ;;
        esac

        if [[ -n "$changed" ]]; then
          signIfRequired "$file"
        fi
      done
    '';

    meta = (old.meta or { }) // {
      broken = false;
      platforms = lib.platforms.darwin;
    };

    passthru = (old.passthru or { }) // {
      inherit base;
    };
  })
