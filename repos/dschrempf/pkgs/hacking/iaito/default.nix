{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, radare2
, qtbase
, qttools
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "iaito";
  version = "5.7.0";

  src = fetchFromGitHub {
    owner = "radareorg";
    repo = pname;
    rev = version;
    hash = "sha256-xKVN377ETkMRCI5A0qs17ooAlxeYUv5WQrSr5+PVyt8=";
  };

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ dschrempf ];
  };

  # TODO: Not sure if qtbase or qttools need to be in here.
  nativeBuildInputs = [ pkg-config qtbase qttools wrapQtAppsHook ];
  buildInputs = [ radare2 ];
  # propagatedBuildInputs = [ ];
}
