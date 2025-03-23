{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adguard-cli";
  version = "0.99.30-nightly";

  src = fetchzip {
    url = "https://github.com/AdguardTeam/AdGuardCLI/releases/download/v${finalAttrs.version}/adguard-cli-${lib.head (lib.splitString "-" finalAttrs.version)}-linux-x86_64.tar.gz";
    hash = "sha256-SxY20QLj97NuMXl0VPBndU54Ec0B667oKxLn0op7x+o=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/adguard-cli}

    cp -r . $out/share/adguard-cli

    ln -s $out/share/adguard-cli/adguard-cli $out/bin/

    runHook postInstall
  '';

  meta = {
    description = "AdGuard Ad Blocker command-line version ";
    homepage = "https://adguard.com/adguard-linux/overview.html";
    # license = with lib.licenses; [ unfree ];
    license = with lib.licenses; [ free ];
    mainProgram = "adguard-cli";
    platforms = lib.platforms.linux;
  };
})
