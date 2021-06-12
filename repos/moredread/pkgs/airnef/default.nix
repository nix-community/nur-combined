{ stdenv, lib, pythonPackages, buildPythonApplication, fetchurl, fetchzip }:

stdenv.mkDerivation rec {
  name = "airnef-${version}";
  version = "1.1";

  src = fetchzip rec {
    url = "http://www.testcams.com/airnef/Version_1.1/airnef_v1.1_Source.zip";
    sha256 = "00g9mz2z5lsaizzyrmssjybjhgyyv1grd6mjwgsma56ax2s3fqgy";
    curlOpts = "--user-agent \"Mozilla/4.0\"";
  };

  buildInputs = [ pythonPackages.wrapPython ];

  propagatedBuildInputs = [ pythonPackages.tkinter ];

  installPhase = ''
    mkdir -p "$out/bin"

    cp -r *.py $out/bin
    ln -s $out/bin/airnefcmd.py $out/bin/airnefcmd
    chmod 755 $out/bin/airnefcmd.py
  '';

  postFixup = ''
    echo wrapPythonProgramsIn "$out/bin" "$out $pythonPath"
    wrapPythonProgramsIn "$out/bin" "$out $pythonPath"
  '';

  meta = {
    homepage = http://www.testcams.com/airnef/;
    description = "Wireless download from your camera";
    license = lib.licenses.gpl3;
    # default "appdata" path is in the installation path, so running fails atm
    broken = true;
  };
}
