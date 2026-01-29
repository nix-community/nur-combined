{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchpatch,
  alsa-lib,
}:
stdenv.mkDerivation {
  pname = "ttymidi";
  version = "unstable-2023-04-06";

  src = fetchFromGitHub {
    owner = "kuflierl";
    repo = "ttymidi";
    rev = "bzr-orig";
    hash = "sha256-aEX+3DO6Eq4cbX9NxaLzDdn7vr+ckUEgxvnmPL4gxhM=";
  };

  patches = [
    (fetchpatch {
      name = "31250-baud-support.patch";
      url = "https://github.com/kuflierl/ttymidi/commit/3879da07aa9eb1be46746ed39912a08c17053957.patch";
      hash = "sha256-rWgxP/lMZsix7WuYfroOvTiDJ2duo8WuL639bR7uaV8=";
    })
  ];

  buildInputs = [ alsa-lib ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ttymidi -t $out/bin

    runHook postInstall
  '';

  meta = {
    description = "MIDI for your serial devices";
    homepage = "http://www.varal.org/ttymidi";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [
      kuflierl
    ];
    mainProgram = "ttymidi";
    platforms = lib.platforms.linux;
  };
}
