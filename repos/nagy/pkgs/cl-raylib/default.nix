{ lib, lispPackages, fetchFromGitHub, raylib, ... }:

lispPackages.buildLispPackage {

  baseName = "cl-raylib";
  version = "unstable-2021-07-30";

  buildSystems = [ ];

  description = "cl-raylib";

  deps = [ lispPackages."cffi" ];

  propagatedBuildInputs = [ raylib ];

  src = fetchFromGitHub {
    owner = "longlene";
    repo = "cl-raylib";
    rev = "20d2c33718804762b7ca78030d1743ca3481c30a";
    sha256 = "0v619ix3lkchqa8a2rrag5z4j4xlwxba4kbf461kfj2ivlh6w24d";
  };
}
