{ lib
, stdenvNoCC
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation rec {
  pname = "betterfox";
  version = "126.0";

  src = fetchFromGitHub {
    owner = "yokoffing";
    repo = "Betterfox";
    rev = version;
    hash = "sha256-W0JUT3y55ro3yU23gynQSIu2/vDMVHX1TfexHj1Hv7Q=";
  };

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/betterfox
    cp -r * $out/share/betterfox/
  '';

  meta = with lib; {
    description = "Firefox speed, privacy, and security: a user.js template for configuration. Your favorite browser, but better.";
    homepage = "https://github.com/yokoffing/Betterfox";
    license = licenses.mit;
    maintainers = with maintainers; [ dsuetin ];
    platforms = platforms.all;
  };
}
