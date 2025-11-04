{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  tomlplusplus
}:

stdenv.mkDerivation {
  pname = "autotoml";
  version = "unstable-2020-12-30";

  src = fetchFromGitHub {
    owner = "Ryan-rsm-McKenzie";
    repo = "AutoTOML";
    rev = "10db32f275479a5af15793358e9e9e84079d13b3";
    hash = "sha256-AJohY8q3xZ6sxh/i6+4jU6MHAfPfTIq6EtD8eGAeMsk=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    tomlplusplus
  ];

  meta = {
    description = "AutoTOML library";
    homepage = "https://github.com/Ryan-rsm-McKenzie/AutoTOML";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    platforms = lib.platforms.all;
  };
}
