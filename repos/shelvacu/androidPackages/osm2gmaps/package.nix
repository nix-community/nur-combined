{ fetchFromCodeberg, buildGradleAndroidPackage }:
buildGradleAndroidPackage rec {
  pname = "osm2gmaps";
  version = "0.6.0";
  applicationId = "net.retiolus.osm2gmaps";

  src = fetchFromCodeberg {
    owner = "retiolus";
    repo = "osm2gmaps";
    tag = "v${version}";
    hash = "sha256-Z4hjOqDsRb5YrsiYY8q4SeOwv0whvUT1Ej57yNudWBE=";
  };

  sdkVersions = [
    "34"
    "35"
  ];

  lockFile = ./gradle.lock;
}
