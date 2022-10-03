{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "ha-dyson-cloud";
  version = "0.15.0";
  format = "other";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
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
    mkdir -p $out/custom_components
    cp -r custom_components/dyson_cloud $out/custom_components/
  '';

  meta = with lib; {
    homepage = "https://github.com/shenxn/ha-dyson-cloud";
    license = licenses.mit;
    description = "Cloud integration for ha-dyson";
    maintainers = with maintainers; [ graham33 ];
  };
}
