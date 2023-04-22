{ lib
, fetchFromGitHub
, stdenv
,
}:
stdenv.mkDerivation rec {
  pname = "monocraft";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "IdreesInc";
    repo = "Monocraft";
    rev = "v${version}";
    sha256 = "sha256-frg7LcMv6zWPWxkr6RIl01fC68THELbb45mJVqefXC0=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/fonts/opentype
    mv Monocraft.otf $out/share/fonts/opentype
  '';

  meta = with lib; {
    description = "A programming font based on the typeface used in Minecraft";
    homepage = "https://github.com/IdreesInc/Monocraft";
    license = licenses.ofl;
    maintainers = with maintainers; [ minion3665 ];
  };
}
