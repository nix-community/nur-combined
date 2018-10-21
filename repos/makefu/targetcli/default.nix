{ pkgs, fetchFromGitHub, ... }:
with pkgs.python2Packages;
let
  version = "2.1";
  rtslib = buildPythonPackage rec {
    pname = "rtslib";
    inherit version;
    src = fetchFromGitHub {
      owner = "datera";
      repo = "rtslib";
      rev = version;
      sha256 = "1d58k9i4xigfqgycyismsqzkz65ssjdri2v9fg0wpica1klyyv22";
    };
    propagatedBuildInputs = [ ipaddr netifaces configobj ];
  };
  configshell = buildPythonPackage rec {
    pname = "configshell";
    version = "1.6";
    src = fetchFromGitHub {
      owner = "datera";
      repo = "configshell";
      rev = version;
      sha256 = "14n7xbcaicsvwajv1aihz727dlkn6zfaqjbnn7mcpns83c2hms7y";
    };
    propagatedBuildInputs = [ pyparsing ];
  };

  tcm-py  = buildPythonPackage rec {
    pname = "tcm-py";
    version = "0ac9091c1ff7a52d5435a4f4449e82637142e06e";
    src = fetchFromGitHub {
      owner = "datera";
      repo = "lio-utils";
      rev = "0ac9091c1ff7a52d5435a4f4449e82637142e06e";
      sha256 = "0fc922kxvgr7rwg1y875vqvkipcrixmlafsp5g8mipmq90i8zcq0";
    } + "/tcm-py";
    propagatedBuildInputs = [ ];
  };

  lio-py = buildPythonPackage rec {
    pname = "lio-py";
    version = "0ac9091c1ff7a52d5435a4f4449e82637142e06e";
    src = fetchFromGitHub {
      owner = "datera";
      repo = "lio-utils";
      rev = "0ac9091c1ff7a52d5435a4f4449e82637142e06e";
      sha256 = "0fc922kxvgr7rwg1y875vqvkipcrixmlafsp5g8mipmq90i8zcq0";
    } + "/lio-py";
    propagatedBuildInputs = [ ];
  };

in buildPythonApplication rec {
  pname = "targetcli";
  inherit version;

  propagatedBuildInputs = [ rtslib configshell lio-py tcm-py ];

  src = fetchFromGitHub {
    owner = "datera";
    repo = "targetcli";
    rev = version;
    sha256 = "10nax7761g93qzky01y3hra8i4s11cgyy9w5w6l8781lj21lgi3d";
  };
}
