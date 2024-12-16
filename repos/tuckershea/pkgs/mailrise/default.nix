{
  fetchPypi,
  lib,
  python3Packages
}:
python3Packages.buildPythonApplication rec {
  pname = "mailrise";
  version = "1.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-BKl5g4R9L5IrygMd9Vbi20iF2APpxSSfKxU25naPGTc=";
  };

  dependencies = with python3Packages; [
    apprise
    aiosmtpd
    pyyaml
  ];

  pythonImportsCheck = [ "mailrise" ];

  meta = with lib; {
    description = "An SMTP gateway for Apprise notifications";
    longDescription = ''
      Mailrise is an SMTP server that converts the emails it receives into Apprise notifications. The intended use case is as an email relay for a home lab or network. By accepting ordinary email, Mailrise enables Linux servers, Internet of Things devices, surveillance systems, and outdated software to gain access to the full suite of 60+ notification services supported by Apprise, from Matrix to Nextcloud to your desktop or mobile device.
    '';
    homepage = https://mailrise.xyz;
    license = licenses.mit;
    maintainers = [  ];
    platforms = platforms.all;
  };
}

