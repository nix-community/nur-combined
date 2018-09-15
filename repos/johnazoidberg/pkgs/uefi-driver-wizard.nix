{ stdenv, fetchFromGitHub, python27Packages }:
python27Packages.buildPythonApplication {
  name = "uefi-driver-wizard";

  src = fetchFromGitHub {
    owner = "JohnAZoidberg";
    repo = "edk2-share";
    rev = "0b2004d5e7973c7a351674b317209248b14a72e8";
    sha256 = "034hkqmf2cgwqdfsn7f8fhqmrdarh8lll184ifsbzkn2da8rzp75";
  };

  # TODO: Is this a good way to do this?
  preBuild = ''
    cd DriverDeveloper
  '';

  propagatedBuildInputs = [
    python27Packages.wxPython
  ];

  meta = with stdenv.lib; {
    description = "UEFI Driver Wizard for EDK2";
    license = licenses.bsd2;
    homepage = https://github.com/tianocore/edk2-share;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

