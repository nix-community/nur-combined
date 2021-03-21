{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "hass-smartbox";
  version = "0.1.0-pre";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "75c2d92ee3ddbfe96d63d1728b84c0c46e6365b0";
    sha256 = "061d9mb9lp3illi936y5ygwlbm0rbgh793cgw4hj7aspcch3js8i";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
