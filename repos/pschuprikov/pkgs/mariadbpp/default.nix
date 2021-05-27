{ stdenv, fetchFromGitHub, cmake, mariadb-connector-c ? null }:
stdenv.mkDerivation rec {
  version = "HEAD";
  name = "mariadbpp-${version}";

  src = fetchFromGitHub {
    owner = "viaduck";
    repo = "mariadbpp";
    rev = "81af4f95461a58e8e6a3e6497b75358a8c71c2b1";
    sha256 = "0kfbcnic30s4d56gxrv8md8wjj17gny30fzfs3g8s32cs55f7440";
    fetchSubmodules = true;
  };

  buildInputs = [ cmake mariadb-connector-c ];

  meta = {
    broken = isNull mariadb-connector-c;
  };
}
