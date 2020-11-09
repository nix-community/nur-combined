{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, pydash
, aiofiles
, aiohttp
, json5
, python3
, dataclasses-json
}:

buildPythonPackage rec {
  pname = "rhasspy-profile";
  version = "0.3.1";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "rhasspy-profile";
    rev = "v${version}";
    sha256 = "sha256-T0rb2UByL8+WEsK9CyGFwl+XTyttX4uVSfmRk7CNaXE=";
  };

  postPatch = ''
    patchShebangs ./configure
    sed -i "s/aiofiles==.*/aiofiles/" requirements.txt
    sed -i "s/json5==.*/json5/" requirements.txt
  '';

  postInstall = ''
    cp -r rhasspyprofile/profiles $out/${python3.sitePackages}/rhasspyprofile
  '';

  propagatedBuildInputs = [
    pydash
    aiofiles
    aiohttp
    json5
    dataclasses-json
  ];

  meta = with lib; {
    description = "Python library for Rhasspy settings";
    homepage = "https://github.com/rhasspy/rhasspy-profile";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
