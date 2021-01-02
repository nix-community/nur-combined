{ lib, python3Packages, hfst, swig }:

python3Packages.buildPythonPackage {
  pname = "python-hfst";
  inherit (hfst) src version;

  sourceRoot = "hfst-src/python";

  buildInputs = [ hfst ];

  nativeBuildInputs = [ swig ];

  meta = with lib; {
    description = "Python bindings for HFST";
    homepage = "https://github.com/hfst/python/wiki";
    license = hfst.meta.license;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
