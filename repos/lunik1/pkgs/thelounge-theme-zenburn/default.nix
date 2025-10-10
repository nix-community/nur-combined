{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "thelounge-theme-zenburn";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "thelounge";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-tbgyT1f2wWBimQH4X1ZxSCV263apbL0mKQCLHRwPgFQ=";
  };

  npmDepsHash = "sha256-cnttTQt0e02UW2yHIl6HxLwT7ElgFO1dtIDnxVpGMeE=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontBuild = true;

  meta = {
    description = "Dark & low-contrast theme based on the Vim's Zenburn color scheme";
    homepage = "https://github.com/thelounge/thelounge-theme-zenburn";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lunik1 ];
  };
}
