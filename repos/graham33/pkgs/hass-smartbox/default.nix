{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "hass-smartbox";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "v${version}";
    sha256 = "1ja3904lkjvaswrdaap8k75xz504vz2xkgahlfkxi37sv13shkvk";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
