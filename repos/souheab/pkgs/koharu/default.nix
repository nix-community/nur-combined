{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  dpkg,
  buildFHSEnv,
}:

let
  pname = "koharu";
  version = "0.83.5";

  source =
    if stdenv.hostPlatform.isAarch64 then
      {
        arch = "arm64";
        hash = "sha256-Un4MTGn/lrmc0n1fCTJy8ctFhAmMRN8kGrDvC/5DtG0=";
      }
    else
      {
        arch = "amd64";
        hash = "sha256-5BUeWZlM6qMUaMnUtkVtyCh8CWiH5JPaycBtvvCkRMI=";
      };

  src = fetchurl {
    url = "https://github.com/koharu-rs/koharu/releases/download/${version}/koharu_${version}_${source.arch}.deb";
    inherit (source) hash;
  };

  meta = {
    description = "AI-powered manga translator";
    homepage = "https://koharu.rs";
    changelog = "https://github.com/koharu-rs/koharu/releases/tag/${version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = pname;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [
      {
        name = "Souheab";
        github = "Souheab";
        githubId = 85948717;
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };

  unwrapped = stdenvNoCC.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit version src meta;

    nativeBuildInputs = [ dpkg ];
    dontUnpack = true;
    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      dpkg --fsys-tarfile "$src" | tar --extract --no-same-permissions
      mkdir -p "$out"
      cp -r usr/. "$out/"

      runHook postInstall
    '';
  };
in
buildFHSEnv {
  inherit pname version meta;

  # Keep CEF's resource layout and support ML libraries downloaded at runtime.
  targetPkgs =
    pkgs: with pkgs; [
      unwrapped
      alsa-lib
      at-spi2-core
      cairo
      cups
      dbus
      expat
      fontconfig
      gdk-pixbuf
      glib
      graphene
      gtk3
      gtk4
      libGL
      libdrm
      libgbm
      libxkbcommon
      nspr
      nss
      openssl
      pango
      stdenv.cc.cc.lib
      systemd
      vulkan-loader
      xdg-utils
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      zlib
    ];
  multiPkgs = _: [ ];

  runScript = "/usr/bin/koharu";

  extraInstallCommands = ''
    mkdir -p "$out/share"
    cp -r ${unwrapped}/share/{applications,icons} "$out/share/"
    chmod u+w "$out/share/applications/koharu.desktop"
    substituteInPlace "$out/share/applications/koharu.desktop" \
      --replace-fail "Exec=koharu" "Exec=$out/bin/koharu"
  '';

  passthru = { inherit src unwrapped; };
}
