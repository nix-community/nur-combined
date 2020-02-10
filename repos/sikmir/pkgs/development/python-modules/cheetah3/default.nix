{ lib, buildPythonPackage, cheetah3 }:

buildPythonPackage rec {
  pname = "cheetah3";
  version = lib.substring 0 7 src.rev;
  src = cheetah3;

  doCheck = false;

  meta = with lib; {
    description = cheetah3.description;
    homepage = cheetah3.homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
