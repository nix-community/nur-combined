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
  version = "0.147.0";

  sources = {
    x86_64-linux = {
      url = "https://downloads.factory.ai/factory-cli/releases/${version}/linux/x64/droid";
      hash = "sha256-+X1OizF6YI1BNNnBWenB0fLAk/yOBuhG3Mb2UY8DEhI=";
    };
    aarch64-linux = {
      url = "https://downloads.factory.ai/factory-cli/releases/${version}/linux/arm64/droid";
      hash = "sha256-1V+H92bE7rXjzoZaL7tB4Z1KidAi/OEyoRDzJ3k9mco=";
    };
    x86_64-darwin = {
      url = "https://downloads.factory.ai/factory-cli/releases/${version}/darwin/x64/droid";
      hash = "sha256-8sAtjs9bDjMSea+lkhKgJpLLCiNnkbz8o8HfGiGovTY=";
    };
    aarch64-darwin = {
      url = "https://downloads.factory.ai/factory-cli/releases/${version}/darwin/arm64/droid";
      hash = "sha256-tNaqfl6Y/7Ma6fpCB3j91j7dKZa5uYifqlJIy7cuM4Y=";
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
