{ lib, python3Packages, sources }:

python3Packages.buildPythonPackage {
  pname = "jsonseq-unstable";
  version = lib.substring 0 10 sources.jsonseq.date;

  src = sources.jsonseq;

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    inherit (sources.jsonseq) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
