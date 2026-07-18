{
  region ? "cn",
  game ? "gi",
  stdenvNoCC,
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;
  type = "${game}-${region}";

  title = lib.strings.toUpper "${game} (${region})";
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "yaagl-${type}";
    inherit (ver) version;

    src = fetchurl (lib.helper.getVariant type ver);

    extraInstall = ''
            app=$(find "$out/Applications" -maxdepth 1 -name "*.app" -type d | head -n1)
            name=$(basename "$app")
            bin=$(basename "$(find "$app/Contents/MacOS" -type f -maxdepth 1 | head -n1)")

            mkdir -p "$out/lib/yaagl"
            mv "$app" "$out/lib/yaagl/$name"
            store="$out/lib/yaagl/$name"

            wrapper="$out/Applications/$name"
            mkdir -p "$wrapper/Contents/MacOS"
            cp "$store/Contents/Info.plist" "$wrapper/Contents/Info.plist"

            cat > "$wrapper/Contents/MacOS/$bin" << EOF
      #!/bin/bash
      STORE="$store"
      DEST="/Applications/$name"
      if [ ! -d "\$DEST" ]; then
        cp -R "\$STORE" "\$DEST"
        chmod -R u+w "\$DEST"
      fi
      exec "\$DEST/Contents/MacOS/$bin" "\$@"
      EOF
            chmod +x "$wrapper/Contents/MacOS/$bin"
    '';

    meta = {
      description = "Yet another anime game launcher for ${title}";
      homepage = "https://github.com/yaagl/yet-another-anime-game-launcher";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [Prinky];
    };
  })
