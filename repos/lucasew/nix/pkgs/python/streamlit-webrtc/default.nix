{ buildPythonPackage
, buildNpmPackage
, fetchFromGitHub
, lib
, nodejs
, npm-lockfile-fix
}:

buildPythonPackage rec {
  pname = "streamlit-webrtc";
  version = "0.47.1";
  format = "poetry";

  src = fetchFromGitHub {
    owner = "whitphx";
    repo = pname;
    rev = "v${version}";
    # hash = "sha256-9j21dLrT1/POX4OOWUHy2wuABjOsaHfCATIotSRdUwY=";

     postFetch = ''
      ${lib.getExe npm-lockfile-fix} $out/package-lock.json
      '';
  };

  frontend = buildNpmPackage {
    pname = "streamlit-webrtc-frontend";
    inherit version;

    src = "${src}/streamlit_webrtc/frontend";

    # npmDepsHash = "sha256-PBhHCOrPvxGyqEa/DJRmYCOFpdjH0MaucacuUYNsqMw=";
  };


  nativeBuildInputs = [ nodejs ];

  pythonImportsCheck = [ "streamlit_webrtc" ];
  
}
