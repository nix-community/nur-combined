{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, libdyson
, setuptools
}:

buildHomeAssistantComponent rec {
  owner = "graham33";
  domain = "dyson_cloud";
  version = "0.15.0";
  format = "other";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = "ha-dyson-cloud";
    rev = "v${version}";
    sha256 = "1vzv6gpip5b0ljdiwq7d863xd72hkwh5376brqbaabhhiy6m4n5v";
  };

  postPatch = ''
    substituteInPlace custom_components/dyson_cloud/manifest.json \
      --replace "libdyson==0.8.7" "libdyson>=0.8.7"
  '';

  propagatedBuildInputs = [
    libdyson
    setuptools
  ];

  installPhase = ''
    mkdir -p $out
    cp -r custom_components $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/shenxn/ha-dyson-cloud";
    license = licenses.mit;
    description = "Cloud integration for ha-dyson";
    maintainers = with maintainers; [ graham33 ];
  };
}
