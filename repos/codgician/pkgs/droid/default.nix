{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  patchelf,
  makeWrapper,
  ripgrep,
  xdg-utils,
}:

let
  version = "0.57.17";

  sources = {
    x86_64-linux = {
      url = "https://downloads.factory.ai/factory-cli/releases/${version}/linux/x64/droid";
      hash = "sha256-UPnVxR8dCqM1wSAUW1r1iN4taAZvvw2hek+hC9hMqp4=";
    };
    aarch64-linux = {
      url = "https://downloads.factory.ai/factory-cli/releases/${version}/linux/arm64/droid";
      hash = "sha256-GcvCYqcUH+LwV6B4DLA8OZhK1RF5eyBg9dYkhaoIh9g=";
    };
    x86_64-darwin = {
      url = "https://downloads.factory.ai/factory-cli/releases/${version}/darwin/x64/droid";
      hash = "sha256-Xp4z14MOy5i0TdlI5cqVBWYq3JzI5zm0Msu8nmJw9Yo=";
    };
    aarch64-darwin = {
      url = "https://downloads.factory.ai/factory-cli/releases/${version}/darwin/arm64/droid";
      hash = "sha256-QqZUhQJOzE+NmZUB5k2Qfl5RieeqBIPDInHObnh86H0=";
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "droid";
  inherit version;

  src = fetchurl (
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "droid: unsupported system ${stdenvNoCC.hostPlatform.system}")
  );

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchELF = true;

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ patchelf ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/libexec/droid

    makeWrapper $out/libexec/droid $out/bin/droid \
      --prefix PATH : ${
        lib.makeBinPath ([ ripgrep ] ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ xdg-utils ])
      }

    runHook postInstall
  '';

  # The droid binary has JavaScript resources appended after the ELF structure.
  # Using autoPatchelfHook or patchelf --set-rpath corrupts this appended data.
  # Only --set-interpreter is safe for this binary.
  postFixup = lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
    patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} $out/libexec/droid
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Factory's AI-powered coding agent for autonomous software development";
    homepage = "https://factory.ai";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames sources;
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "droid";
  };
}
