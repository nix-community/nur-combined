{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, qttools
, radare2
, wrapQtAppsHook
, zip
}:

stdenv.mkDerivation rec {
  pname = "iaito";
  version = "5.7.0";

  src = fetchFromGitHub {
    owner = "radareorg";
    repo = pname;
    rev = version;
    hash = "sha256-qEJTsS669eEwo2iiuybN72O5oopCaGEkju8+ekjw2zk=";
    fetchSubmodules = true;
  };

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ dschrempf ];
  };

  nativeBuildInputs = [ pkg-config qttools wrapQtAppsHook zip ];
  buildInputs = [ radare2 ];
  # propagatedBuildInputs = [ ];
}
