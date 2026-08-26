{
  lib,
  appimageTools,
  buildFHSEnv,
  fetchurl,
  makeWrapper,
  nix-update-script,
  stdenvNoCC,
}:

let
  pname = "oh-dsh";
  version = "0.1.10";

  src = fetchurl {
    url = "https://github.com/hust-open-atom-club/oh-dsh/releases/download/v${version}/Oh-DSH-Desktop-${version}-x86_64.AppImage";
    hash = "sha256-KjH7yGqO3HzCTHSWbyQQwkbgU+2tjQve+kU78a5gAXA=";
  };

  contents = appimageTools.extract {
    inherit pname version src;
  };

  desktop = appimageTools.wrapType2 {
    pname = "oh-dsh-desktop";
    inherit version src;
  };

  ohdsh = buildFHSEnv {
    pname = "ohdsh";
    inherit version;
    runScript = "${contents}/resources/bin/ohdsh";
    extraInstallCommands = ''
      ln -s ohdsh "$out/bin/oh-dsh"
    '';
    meta = {
      mainProgram = "ohdsh";
    };
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share/applications"

    makeWrapper ${lib.getExe desktop} "$out/bin/oh-dsh-desktop" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    makeWrapper ${lib.getExe ohdsh} "$out/bin/ohdsh" \
      --set OH_DSH_DESKTOP_APP "$out/bin/oh-dsh-desktop" \
      --prefix PATH : "$out/bin"

    ln -s ohdsh "$out/bin/oh-dsh"

    install -Dm444 ${contents}/oh-dsh-desktop.desktop \
      "$out/share/applications/oh-dsh.desktop"
    substituteInPlace "$out/share/applications/oh-dsh.desktop" \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=oh-dsh-desktop %U'

    if [ -d ${contents}/usr/share/icons ]; then
      cp -r ${contents}/usr/share/icons "$out/share/"
    fi

    runHook postInstall
  '';

  passthru = {
    inherit desktop ohdsh;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "DSH runtime with Desktop, Web, and TUI interfaces";
    homepage = "https://github.com/hust-open-atom-club/oh-dsh";
    changelog = "https://github.com/hust-open-atom-club/oh-dsh/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "ohdsh";
    platforms = [ "x86_64-linux" ];
  };
}
