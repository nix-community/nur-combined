{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, instantAssist
}:
stdenv.mkDerivation {

  pname = "islide";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "islide";
    rev = "7363ce094d5260c6932375d7d312b102e3d201dc";
    sha256 = "1rdx9g6ljbc5m55g9vjxj10zfn1qv3d54nfiv12cmsz365a0i135";
    name = "instantOS_islide";
  };

  postPatch = ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr/" "PREFIX = $out"
    substituteInPlace islide.c \
      --replace /opt/instantos/menus "${instantAssist}/opt/instantos/menus" \
  '';

  # installPhase = ''
  #   install -Dm 555 autostart.sh $out/bin/instantautostart
  #   install -Dm 644 desktop/st-luke.desktop $out/share/applications/st-luke.desktop
  # '';

  # propagatedBuildInputs = [ st instantDotfiles neofetch firefox nitrogen instantConf acpi instantThemes dunst instantShell rangerplugins ];
  # propagatedBuildInputs = [];
  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];

  propagatedBuildInputs = [ instantAssist ];

  meta = with lib; {
    description = "instantOS Slide";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/islide";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
