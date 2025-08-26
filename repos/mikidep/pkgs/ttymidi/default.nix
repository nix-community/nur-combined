{
  gcc13Stdenv,
  fetchFromGitHub,
  alsa-lib,
}:
gcc13Stdenv.mkDerivation {
  name = "ttymidi";
  src = let
    hard-dj = fetchFromGitHub {
      owner = "robelix";
      repo = "hard-dj";
      rev = "b361983";
      hash = "sha256-u+mMzDPzAwQKtSw3vBUWBXIgfgC/ZDW1FwGoWfsVsl4=";
    };
  in "${hard-dj}/ttymidi";
  buildInputs = [alsa-lib];

  installPhase = ''
    install -m 0755 ttymidi -Dt $out/bin/
  '';
}
