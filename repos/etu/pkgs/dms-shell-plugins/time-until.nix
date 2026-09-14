{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-time-until";
  version = "1.0.1-unstable-2026-02-28";

  src = fetchFromGitHub {
    owner = "fdmarcin";
    repo = "TimeUntil";
    rev = "857720e02b688e46c207e1f37c0c53b2cdf5a940";
    hash = "sha256-0ndMXBYIZRyjO6Z5NLSTjK8q6v71sWDv4nxyYqP38f8=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget showing a customizable countdown timer for deadlines or events";
    homepage = "https://github.com/fdmarcin/TimeUntil";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
