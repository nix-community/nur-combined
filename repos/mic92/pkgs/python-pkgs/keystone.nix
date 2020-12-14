{ stdenv
, buildPythonPackage
, keystone
}:

buildPythonPackage rec {
  inherit (keystone) pname src version buildInputs nativeBuildInputs;

  dontUseCmakeConfigure = 1;
  preBuild = "cd bindings/python";

  meta = with stdenv.lib; {
    inherit (keystone.meta) description homepage license;
  };
}
