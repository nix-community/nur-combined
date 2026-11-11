{
  appimageTools,
  buildFHSEnv,
  curl,
  desktop-file-utils,
  dpkg,
  fetchurl,
  lib,
  maintainer,
  python3,
  stdenvNoCC,
  writeShellApplication,
  writeShellScript,
}:

let
  launcher = writeShellScript "curseforge-launch" ''
    set -e
    ${lib.getExe python3} ${./register_desktop.py} \
      "@out@/share/applications/curseforge.desktop" \
      "${lib.getExe' desktop-file-utils "update-desktop-database"}"
    exec "@out@/bin/.curseforge-fhs" "$@"
  '';
  source = builtins.fromJSON (builtins.readFile ./source.json);
  unwrapped = stdenvNoCC.mkDerivation {
    dontBuild = true;
    dontConfigure = true;
    # The FHS launcher supplies the ELF loader and libraries for the vendor binaries.
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/lib" "$out/share"
      cp -a opt/CurseForge "$out/lib/curseforge"
      cp -a usr/share/applications usr/share/doc usr/share/icons "$out/share/"

      runHook postInstall
    '';

    meta = {
      description = "Official CurseForge mod and addon manager";
      homepage = "https://www.curseforge.com/download/app";
      license = lib.licenses.unfree;
      mainProgram = "curseforge";
      maintainers = [ maintainer ];
      platforms = [ "x86_64-linux" ];
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };

    nativeBuildInputs = [ dpkg ];
    pname = "curseforge";
    src = fetchurl {
      inherit (source) hash url;
    };

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x "$src" .
      runHook postUnpack
    '';

    inherit (source) version;
  };
in
# Reuse the AppImage library set for Java and game launchers downloaded by CurseForge.
buildFHSEnv (
  appimageTools.defaultFhsEnvArgs
  // {
    extraInstallCommands = ''
      mkdir -p "$out/share"
      cp -R ${unwrapped}/share/applications ${unwrapped}/share/doc ${unwrapped}/share/icons "$out/share/"
      chmod u+w "$out/share/applications" "$out/share/applications/curseforge.desktop"
      substituteInPlace "$out/share/applications/curseforge.desktop" \
        --replace-fail 'Exec=/opt/CurseForge/curseforge %U' "Exec=$out/bin/curseforge %U"
      # Identify our installed entries so automatic registration can retain live profile paths.
      ${lib.getExe' desktop-file-utils "desktop-file-edit"} \
        --set-key=X-Nix-CurseForge --set-value=true "$out/share/applications/curseforge.desktop"
      ${lib.getExe' desktop-file-utils "desktop-file-validate"} "$out/share/applications/curseforge.desktop"
      # Register on the host before entering FHS so the browser's portal can discover the callback handler.
      mv "$out/bin/curseforge" "$out/bin/.curseforge-fhs"
      # Fill in this output's path after FHS has generated its launcher, without a Nix self-reference.
      substitute ${launcher} "$out/bin/curseforge" --replace-fail '@out@' "$out"
      chmod +x "$out/bin/curseforge"
    '';

    inherit (unwrapped) meta pname;
    passthru = {
      inherit (unwrapped) src;
      inherit unwrapped;
      updateScript = lib.getExe (writeShellApplication {
        name = "update-curseforge";
        runtimeInputs = [
          curl
          dpkg
          python3
        ];
        text = "exec python3 pkgs/curseforge/update.py";
      });
    };
    runScript = "${unwrapped}/lib/curseforge/curseforge";
    targetPkgs =
      pkgs:
      appimageTools.defaultFhsEnvArgs.targetPkgs pkgs
      ++ [
        # The bundled .NET agent loads ICU dynamically for globalization support.
        pkgs.icu
      ];
    inherit (unwrapped) version;
  }
)
