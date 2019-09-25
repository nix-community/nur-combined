{ stdenv, fetchFromGitHub, glib, bash, bc }:

let
  path = stdenv.lib.makeBinPath [ glib bash bc ];
in
stdenv.mkDerivation rec {
  pname = "notify-send.sh";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "vlevit";
    repo = pname;
    rev = "7ae815c1aba8356f5ca8f123e5127749e671cd59"; # okay so really this is 1.0+2 commits
    sha256 = "09z5998jda7q8h9r8rsp60hhwsnyl6cvkl6f0rl0h466bllx3mq2";
  };

  buildInputs = [ bash ]; # runtime

  dontBuild = true;

  installPhase = ''
    install -Dm755 -t $out/bin notify-send.sh notify-action.sh

    patchShebangs $out/bin/*.sh
    sed -i -e '2iexport PATH="${path}''${PATH:+":"}$PATH"' $out/bin/*.sh
  '';
}
