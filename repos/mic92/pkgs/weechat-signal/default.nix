 { lib, stdenv, substituteAll, buildEnv, fetchFromGitHub, python3Packages }:

stdenv.mkDerivation rec {
  pname = "weechat-signal";
  version = "2020-12-22";

  src = fetchFromGitHub {
    owner = "thefinn93";
    repo = "signal-weechat";
    rev = "ebe2d25bf7b2cb6f80eb6bb236b25ee2b0335e3d";
    sha256 = "sha256-ZLYc+5k0T/4A7KECufacfdpWbFxRJZUo4QCMK+r9c00=";
  };

  passthru.scripts = [ "signal.py" ];

  installPhase = ''
    install -D signal.py $out/share/signal.py
  '';

  meta = with lib; {
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    description = "Use Signal via signald in weechat.";
  };
}
