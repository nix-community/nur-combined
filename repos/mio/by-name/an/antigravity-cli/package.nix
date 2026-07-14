{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  versionCheckHook,
  versionCheckHomeHook,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version urls hashes;

  platform = stdenv.hostPlatform.system;
in
stdenv.mkDerivation {
  pname = "antigravity-cli";
  inherit version;

  src = fetchurl {
    url = urls.${platform} or (throw "Unsupported system: ${platform}");
    hash = hashes.${platform} or (throw "Unsupported system: ${platform}");
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    (lib.getLib stdenv.cc.cc)
  ];

  dontStrip = true;

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 antigravity $out/bin/agy
    ln -s agy $out/bin/antigravity

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHomeHook
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isLinux) [ versionCheckHook ];

  installCheckPhase = lib.optionalString stdenv.hostPlatform.isLinux ''
    runHook preInstallCheck

    $out/bin/agy --help >/dev/null

    runHook postInstallCheck
  '';

  passthru.category = "AI Coding Agents";

  meta = with lib; {
    description = "CLI for Google Antigravity, an agentic development platform";
    homepage = "https://antigravity.google/";
    changelog = "https://antigravity.google/cli";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ ryoppippi ];
    mainProgram = "agy";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
