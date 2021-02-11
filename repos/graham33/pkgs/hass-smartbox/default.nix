{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "hass-smartbox";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "v${version}";
    sha256 = "0a3v26dig7j89d2kbc4fzz0gvj2bgl8vknyrgqajp2vsnjb8cair";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
