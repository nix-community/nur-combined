{ lib
, stdenv
, fetchFromGitHub
, python3
, gtk
, instantConf
}:
stdenv.mkDerivation rec {

  pname = "instantWELCOME";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantwelcome";
    rev = "2acbf9b6153de37fa20696b5357c064b4f51f325";
    sha256 = "0jffhzahy9f69wis8xj8fdn2rdyjsspz4fkh0prk8sw9wy8ld237";
  };

  postPatch = ''
    substituteInPlace welcome.sh \
      --replace /usr/share/instantwelcome "$out/share/instantwelcome"
    substituteInPlace welcome.py \
      --replace /usr/share/instantwelcome "$out/share/instantwelcome"
  '';

  installPhase = ''
    install -Dm 644 instantwelcome.desktop "$out/share/applications/instantwelcome.desktop"
    install -Dm 555 welcome.sh "$out/bin/instantwelcome"
    install -Dm 555 welcome.py "$out/share/instantwelcome/welcome.py"
    install -Dm 644 welcome.glade "$out/share/instantwelcome/welcome.glade"
  '';

  propagatedBuildInputs = [ gtk python3 instantConf ];

  meta = with lib; {
    description = "Welcome app for instantOS";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantwelcome";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
