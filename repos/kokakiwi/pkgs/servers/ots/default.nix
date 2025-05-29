{
  lib,
  stdenv,
  _common,
  buildGoModule,
  fetchYarnDeps,
  yarnConfigHook,
  font-awesome,
  nodejs,
  ots-cli,
}:
buildGoModule rec {
  pname = "ots";
  inherit (_common) version src;

  frontend = stdenv.mkDerivation {
    pname = "${pname}-frontend";
    inherit version src;

    yarnOfflineCache = fetchYarnDeps {
      name = "${pname}-frontend-offline";
      inherit src;
      hash = "sha256-OymZGx2aszwtkmNdNZCjpEwC1wSNXcEX+neXBBNu11o=";
    };

    nativeBuildInputs = [
      yarnConfigHook
      nodejs
    ];

    buildPhase = ''
      node ci/build.mjs
    '';

    installPhase = ''
      cp -Tr frontend $out
    '';
  };

  vendorHash = "sha256-+foydlBnVA3FvJM1ffrfg+GY/s3mPGDShEr6F+zn0Dc=";

  ldflags = [
    "-X main.version=${version}"
  ];
  subPackages = [ "." ];

  preBuild = ''
    rm -rf frontend
    cp -Tr ${frontend} frontend
    chmod +w frontend

    for d in css js webfonts; do
      cp -Tr ${font-awesome.src}/$d frontend/$d
    done
  '';

  passthru = {
    cli = ots-cli;
  };

  meta = with lib; {
    homepage = "https://ots.fyi";
    description = "One-Time-Secret sharing platform with a symmetric 256bit AES encryption in the browser";
    license = licenses.asl20;
    mainProgram = "ots";
  };
}
