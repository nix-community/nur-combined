{ lib, buildPythonPackage, hfst, swig }:

buildPythonPackage rec {
  pname = "python-hfst";
  inherit (hfst) src version;

  buildInputs = [ hfst ];

  nativeBuildInputs = [ swig ];

  preConfigure = "cd python";

  meta = with lib; {
    description = "Python bindings for HFST";
    homepage = "https://github.com/hfst/python/wiki";
    license = hfst.meta.license;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
