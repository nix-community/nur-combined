{ lib
, buildPythonApplication
, fetchFromGitHub
, msgpack
, nose
, pefile
, pyelftools
, capstone-system
, capstone
, python3
}:

buildPythonApplication rec {
  pname = "plasma-disassembler";
  version = "unstable-2019-03-04";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "plasma-disassembler";
    repo = "plasma";
    rev = "ec7df9b2b9b356dd5d8caf01b7e68c0ab5a1ef42";
    hash = "sha256-7XBvt+lYEEfXknFYrT+2KcrVSArlFNoq6cmnP1NWhsE=";
  };

  # fix: AttributeError: 'ParsedRequirement' object has no attribute 'req'
  # https://github.com/plasma-disassembler/plasma/issues/106
  postPatch = ''
    sed -i "s/if item.req:/if getattr(item, 'req', None):/" setup.py
  '';

  propagatedBuildInputs = [
    msgpack
    nose
    pefile
    pyelftools
    capstone
  ];

  buildInputs = [
    capstone-system
  ];

  # fix: Testing via this command is deprecated
  checkPhase = ''
    runHook preCheck
    ${python3.interpreter} -m unittest
    runHook postCheck
  '';

  pythonImportsCheck = [ "plasma" ];

  meta = with lib; {
    description = "Plasma is an interactive disassembler for x86/ARM/MIPS. It can generates indented pseudo-code with colored syntax";
    homepage = "https://github.com/plasma-disassembler/plasma";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
