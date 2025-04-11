{
  lib,
  buildGoModule,
  fetchFromGitHub,
  buildNpmPackage,
  removeReferencesTo,
}:
let
  frontEnd = buildNpmPackage rec {
    pname = "zui";
    version = "commit-930ae7e";

    src = fetchFromGitHub {
      owner = "project-zot";
      repo = "zui";
      rev = "${version}";
      hash = "sha256-3z6QboH/Emt38B0KHNxg9XcR/XwPJvTXC7dvXn6oxnM=";
    };

    npmDepsHash = "sha256-5f9D+DmX4I14wx5mNScero1xWQRtuLwhfDXfHM0mbB4=";
    #makeCacheWritable = true;
    npmFlags = [ "--legacy-peer-deps" ];

    installPhase = ''
      runHook preInstall

      cp -r build/ $out

      runHook postInstall
    '';
  };
in
buildGoModule {
  pname = "zot";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "project-zot";
    repo = "zot";
    rev = "v2.1.2";
    hash = "sha256-tVvqNA7imLmVQoO7giEtktJkgQTaaWjkB/aYM+or6kg=";
  };

  vendorHash = "sha256-q74nyQE8ELP54QiebCyLqepHty0kGMcJywo6N72eYDA=";

  ldflags = [
    "-s -w"
  ];

  GOFLAGS = [
    "-v"
    "-buildmode=pie"
  ];

  tags = [
    "imagetrust"
    "lint"
    "metrics"
    "mgmt"
    "profile"
    "scrub"
    "search"
    "sync"
    "ui"
    "userprefs"
    "containers_image_openpgp"
  ];

  postConfigure = ''
    mkdir -p pkg/extensions/build
    cp -R ${frontEnd}/* pkg/extensions/build/
  '';

  postInstall = ''
    mkdir -p $out/share
    cp examples/*.{json,yaml} $out/share/
  '';

  subPackages = [
    "cmd/zot"
  ];

  env.CGO_ENABLED = 1;
  doCheck = false;
}
