{
  stdenv,
  apple-sdk_15,
  source,
  installShellFiles,
  xxd,
}:
let
  inherit (stdenv.hostPlatform) system;

  replacement =
    {
      "x86_64-darwin" = "arm64e?";
      "aarch64-darwin" = "x86_64";
    }
    .${system} or (throw "Unsupported system: ${system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "yabai";
  inherit (source) version src;
  nativeBuildInputs = [
    xxd
    installShellFiles
  ];
  buildInputs = [
    apple-sdk_15
  ];
  doInstallCheck = true;
  preferLocalBuild = true;

  makeFlags = [
    "all"
  ];
  configurePhase = ''
    sed -i 's/-arch ${replacement}//g' makefile
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./bin/yabai $out/bin/yabai
    installManPage ./doc/yabai.1

    runHook postInstall
  '';

})
