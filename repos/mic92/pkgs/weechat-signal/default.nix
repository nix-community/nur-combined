 { lib, stdenv, substituteAll, buildEnv, fetchFromGitHub, python3Packages }:

stdenv.mkDerivation rec {
  pname = "weechat-signal";
  version = "2021-02-17";

  src = fetchFromGitHub {
    owner = "thefinn93";
    repo = "signal-weechat";
    rev = "75d91d9a988f7c6762d769f9cc596e4137aa31c5";
    sha256 = "sha256-TQwpdxM3XH5AzRctRSjJWYuIipypR9egLDx2Iwn7E1g=";
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
