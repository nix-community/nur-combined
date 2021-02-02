{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pyimagequant";
  version = "2019-10-24";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = pname;
    rev = "a467b3b2566f4edd31a272738f7c5e646c0d84a9";
    sha256 = "1alyaizr910zv885a15mmw9v74bsmmkch5n14ggi69w54sq5j6y8";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = with python3Packages; [ cython ];

  pythonImportsCheck = [ "imagequant" ];

  meta = with lib; {
    description = "python bindings for libimagequant (pngquant core)";
    homepage = "https://github.com/wladich/pyimagequant";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
  };
}
