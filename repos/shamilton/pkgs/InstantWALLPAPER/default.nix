{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, InstantLOGO
, InstantConf
, InstantUtils
, Paperbash
, imagemagick
, nitrogen
}:
stdenv.mkDerivation rec {

  pname = "instantWALLPAPER";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantWALLPAPER";
    rev = "master";
    sha256 = "1ril747fiwg0lzz4slc9ndzy5an3mwnmqk6fk58pp09z5g2wjhla";
  };

  postPatch = ''
    substituteInPlace wall.sh \
      --replace /usr/share/backgrounds/readme.jpg ${InstantLOGO}/share/backgrounds/readme.jpg \
      --replace /usr/share/instantwallpaper/wallutils.sh wallutils.sh \
      --replace "iconf" "${InstantConf}/bin/iconf" \
      --replace "checkinternet" "${InstantUtils}/bin/checkinternet" \
      --replace "/usr/share/paperbash" "${Paperbash}/share/paperbash"
    substituteInPlace wallutils.sh \
      --replace "iconf" "${InstantConf}/bin/iconf" \
      --replace "identify" "${imagemagick}/bin/identify" \
      --replace "convert" "${imagemagick}/bin/convert" \
      --replace "-composite" "__tmp_placeholder" \
      --replace "composite" "${imagemagick}/bin/composite" \
      --replace "__tmp_placeholder" "-composite" \
      --replace "ifeh" "${InstantUtils}/bin/ifeh" \
      --replace "nitrogen" "${nitrogen}/bin/nitrogen"

  '';
  
  installPhase = ''
    install -Dm 555 wall.sh $out/bin/wall.sh
    install -Dm 555 wallutils.sh $out/bin/wallutils.sh
  '';

  propagatedBuildInputs = [ InstantLOGO InstantConf InstantUtils Paperbash imagemagick nitrogen ];

  meta = with lib; {
    description = "Window manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
