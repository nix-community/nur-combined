{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "hass-smartbox";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "v${version}";
    sha256 = "0zgvhpq4jdad487qx5iqlgrc6wwhy0mzr00cbjlyh61wqf2pg6qx";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
