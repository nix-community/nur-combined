{
  lib,
  stdenv,
  fetchurl,
  unzip,
  makeWrapper,
  nix-update-script,
}:
stdenv.mkDerivation rec {
  pname = "cline-cli-bin";
  version = "1.0.5";

  src = fetchurl {
    url = "https://registry.npmjs.org/cline/-/cline-${version}.tgz";
    hash = "sha512-XhM+rkLbwTdLuxBfy0g8txTDzPnH38EPjQWlF3mV/7LC2RDUnrpLrIu2o7q3QAh4wiOXYxeqqz9Tb+rUT4YpZA==";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  sourceRoot = "package";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Create bin directory
    mkdir -p $out/bin

    # Determine platform-specific binary names
    if [[ "${stdenv.hostPlatform.system}" == "x86_64-linux" ]]; then
      CLINE_BIN="cline-linux-amd64"
      CLINE_HOST_BIN="cline-host-linux-amd64"
    elif [[ "${stdenv.hostPlatform.system}" == "aarch64-linux" ]]; then
      CLINE_BIN="cline-linux-arm64"
      CLINE_HOST_BIN="cline-host-linux-arm64"
    elif [[ "${stdenv.hostPlatform.system}" == "x86_64-darwin" ]]; then
      CLINE_BIN="cline-darwin-amd64"
      CLINE_HOST_BIN="cline-host-darwin-amd64"
    elif [[ "${stdenv.hostPlatform.system}" == "aarch64-darwin" ]]; then
      CLINE_BIN="cline-darwin-arm64"
      CLINE_HOST_BIN="cline-host-darwin-arm64"
    else
      echo "Unsupported platform: ${stdenv.hostPlatform.system}"
      exit 1
    fi

    # Install platform-specific binaries
    install -Dm755 bin/$CLINE_BIN $out/bin/cline
    install -Dm755 bin/$CLINE_HOST_BIN $out/bin/cline-host

    # Create wrapper for the generic cline script if it exists
    if [[ -f bin/cline ]]; then
      install -Dm755 bin/cline $out/bin/cline-script
    fi

    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script {};
  };

  meta = {
    description = "Autonomous coding agent CLI - capable of creating/editing files, running commands, using the browser, and more";
    longDescription = ''
      Cline CLI is the command-line version of Cline, an autonomous coding agent
      that can create/edit files, execute commands, use the browser, and more
      with your permission every step of the way. It brings the power of AI-assisted
      coding directly to your terminal.
    '';
    homepage = "https://cline.bot";
    license = lib.licenses.asl20;
    platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    mainProgram = "cline";
    maintainers = with lib.maintainers; [
      inogai
    ];
  };
}
