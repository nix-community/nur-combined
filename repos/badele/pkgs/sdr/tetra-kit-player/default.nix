{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "tetra-kit-player";
  version = "2023-05-19";

  src = fetchFromGitHub {
    owner = "sonictruth";
    repo = pname;
    rev = "ea258fcfeb0ff43bf1d8911d3a7c7c6326e11750";
    sha256 = "sha256-3TjbVv3MEpKUITPxB1xvTTGLAq7hbOSJzu486AVkzAM=";
  };

  # prefetch-npm-deps package-lock.json
  npmDepsHash = "sha256-8azBX58xH+XFuvznrRxUCsxEI5aLQHIK0wDgS59ex6I=";

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  dontNpmBuild = true;

  meta = with lib; {
    description = "TKP is web application that streams events and files produced by tetra kit.";
    homepage = "https://github.com/sonictruth/tetra-kit-player";
    license = licenses.isc;
  };
}
