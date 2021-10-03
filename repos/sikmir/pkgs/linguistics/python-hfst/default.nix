{ lib, python3Packages, hfst, swig }:

python3Packages.buildPythonPackage rec {
  pname = "python-hfst";
  inherit (hfst) src version;

  sourceRoot = "${src.name}/python";

  buildInputs = [ hfst ];

  nativeBuildInputs = [ swig ];

  meta = with lib; {
    description = "Python bindings for HFST";
    homepage = "https://github.com/hfst/python/wiki";
    license = hfst.meta.license;
    maintainers = [ maintainers.sikmir ];
  };
}
