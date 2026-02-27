{
  lib,
  stdenv,
  fetchFromGitLab,
  tor,
  opusTools,
  sox,
  socat,
  openssl,
  alsa-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "terminalphone";
  version = "1.1.3-unstable";
  src = fetchFromGitLab {
    owner = "atlarator";
    repo = "terminalphone";
    rev = finalAttrs.version;
    sha256 = "sha256-+6PHAaAeq09wauY/ug5X9qMYZpotmAkgRGOa1t7HA24=";
  };

  buildPhase = ''
    echo "no need to build"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/doc/terminalphone
    install -m 0755 terminalphone.sh \
      $out/bin/terminalphone
    install -m 0755 LICENSE \
      $out/share/doc/terminalphone/LICENSE
    runHook postInstall
  '';

  propagatedBuildInputs = [
    tor
    opusTools
    sox
    socat
    openssl
    alsa-utils
  ];

  meta = {
    description = "Encrypted push-to-talk voice communication over Tor hidden services";
    homepage = "https://gitlab.com/here_forawhile/terminalphone";
    license = lib.licenses.mit;
    mainProgram = "terminalphone";
  };
})
