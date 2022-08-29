{ lib, lispPackages, fetchFromGitHub, raylib, ... }:

lispPackages.buildLispPackage {

  baseName = "cl-raylib";
  version = "unstable-2022-08-24";

  buildSystems = [ ];

  description = "cl-raylib";

  deps = [ lispPackages."cffi" ];

  propagatedBuildInputs = [ raylib ];

  src = fetchFromGitHub {
    owner = "longlene";
    repo = "cl-raylib";
    rev = "8bf7ee09e46dc5724a440800a28352ec7fe64a5a";
    sha256 = "1xx86ydns3gd0ynx47ajfyqmg1iki0182ahbjw69vcck55dhxc9g";
  };
}
