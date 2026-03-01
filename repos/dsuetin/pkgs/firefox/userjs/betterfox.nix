{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "betterfox";
  version = "148.0";

  src = fetchFromGitHub {
    owner = "yokoffing";
    repo = "Betterfox";
    rev = version;
    hash = "sha256-rUuEfbjIXox5x5ul/4VarIm7bii/SCcDJjocEbHA1kM=";
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
