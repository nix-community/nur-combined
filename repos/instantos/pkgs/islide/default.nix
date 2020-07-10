{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, instantASSIST
}:
stdenv.mkDerivation rec {

  pname = "islide";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "islide";
    rev = "master";
    sha256 = "1rdx9g6ljbc5m55g9vjxj10zfn1qv3d54nfiv12cmsz365a0i135";
  };

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr/" "PREFIX = $out"
    substituteInPlace islide.c \
      --replace /opt/instantos/menus "${instantASSIST}/opt/instantos/menus" \
  '';
  
  # installPhase = ''
  #   install -Dm 555 autostart.sh $out/bin/instantautostart
  #   install -Dm 644 desktop/st-luke.desktop $out/share/applications/st-luke.desktop
  # '';

  # propagatedBuildInputs = [ st instantDotfiles neofetch firefox nitrogen instantConf acpi instantTHEMES dunst instantShell rangerplugins ];
  # propagatedBuildInputs = [];
  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];

  propagatedBuildInputs = [ instantASSIST ];

  meta = with lib; {
    description = "instantOS Slide";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/islide";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
