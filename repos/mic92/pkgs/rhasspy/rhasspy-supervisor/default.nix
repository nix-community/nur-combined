{ lib
, buildPythonPackage
, fetchFromGitHub
, rhasspy-profile
, pyyaml
}:

buildPythonPackage rec {
  pname = "rhasspy-supervisor";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "rhasspy-supervisor";
    rev = "v${version}";
    sha256 = "sha256-z/oCinw9Veu8P/rd6h7brXv954mhtrabsfy9bwWSChA=";
  };

  propagatedBuildInputs = [
    rhasspy-profile
    pyyaml
  ];

  postPatch = ''
    patchShebangs ./configure
    sed -i "s/pyyaml==.*/pyyaml/" requirements.txt
  '';

  meta = with lib; {
    description = "Tool for generating supervisord configurations from Rhasspy profile";
    homepage = "https://github.com/rhasspy/rhasspy-supervisor";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
