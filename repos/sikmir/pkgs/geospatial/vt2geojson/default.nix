{
  lib,
  buildGoModule,
  fetchFromGitHub,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "vt2geojson";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "wangyoucao577";
    repo = "vt2geojson";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2wBMWrraWFDLHc/s/RMW4a4moftwTFeBj7FfaCJgdU0=";
  };

  vendorHash = "sha256-FnLxhhytgNC4OIvh9pUM+cVDdNfqVOocjmkzFDU1fmA=";

  ldflags = [
    "-s"
    "-w"
    "-X main.appVersion=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = {
    description = "Command line tool to dump Mapbox Vector Tiles to GeoJSON";
    homepage = "https://github.com/wangyoucao577/vt2geojson";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
