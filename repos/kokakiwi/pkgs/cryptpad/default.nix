{ lib
, stdenvNoCC

, buildNpmPackage
, fetchFromGitHub

, nodejs

, withOnlyOffice ? true
}: let
  onlyOfficeVersions = {
    v1 = {
      rev = "4f370bebe96e3a0d4054df87412ee5b2c6ed8aaa";
      hash = "sha256-TE/99qOx4wT2s0op9wi+SHwqTPYq/H+a9Uus9Zj4iSY=";
    };
    v2b = {
      rev = "d9da72fda95daf93b90ffa345757c47eb5b919dd";
      hash = "sha256-SiRDRc2vnLwCVnvtk+C8PKw7IeuSzHBaJmZHogRe3hQ=";
    };
    v4 = {
      rev =  "6ebc6938b6841440ffad2efc1e23f1dc1ceda964";
      hash = "sha256-eto1+8Tk/s3kbUCpbUh8qCS8EOq700FYG1/KiHyynaA=";
    };
    v5 = {
      rev = "88a356f08ded2f0f4620bda66951caf1d7f02c21";
      hash = "sha256-8j1rlAyHlKx6oAs2pIhjPKcGhJFj6ZzahOcgenyeOCc=";
    };
    v6 = {
      rev = "abd8a309f6dd37289f950cd8cea40df4492d8a15";
      hash = "sha256-BZdExj2q/bqUD3k9uluOot2dlrWKA+vpad49EdgXKww=";
    };
    v7 = {
      rev = "9d8b914a81f0f9e5d0bc3f0fc631adf4b6d480e7";
      hash = "sha256-M+rPJ/Xo2olhqB5ViynGRaesMLLfG/1ltUoLnepMPnM=";
    };
  };
  mkOnlyOffice = {
    pname, version
  }: stdenvNoCC.mkDerivation (final: {
    pname = "${pname}-onlyoffice";
    inherit version;

    srcs = lib.mapAttrsToList (version: { rev, hash ? lib.fakeHash }: fetchFromGitHub {
      name = "${final.pname}-${version}-source";
      owner = "cryptpad";
      repo = "onlyoffice-builds";
      inherit rev hash;
    }) onlyOfficeVersions;

    dontBuild = true;

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out
      ${lib.concatLines (map
        (version: "cp -Tr ${final.pname}-${version}-source $out/${version}")
        (builtins.attrNames onlyOfficeVersions)
      )}
    '';
  });
in buildNpmPackage rec {
  pname = "cryptpad";
  version = "2024.3.0";

  src = fetchFromGitHub {
    owner = "cryptpad";
    repo = "cryptpad";
    rev = version;
    hash = "sha256-VUW6KvoSatk1/hlzklMQYlSNVH/tdbH+yU4ONUQ0JSQ=";
  };

  npmDepsHash = "sha256-tvTkoxxioPuNoe8KIuXSP7QQbvcpxMnygsMmzKBQIY0=";

  inherit nodejs;

  onlyOffice = lib.optional withOnlyOffice (mkOnlyOffice {
    inherit pname version;
  });

  makeCacheWritable = true;
  dontFixup = true;

  postPatch = ''
    cp -T ${./package-lock.json} package-lock.json
  '';

  preBuild = ''
    npm run install:components
  '' + lib.optionalString withOnlyOffice ''
    ln -s $onlyOffice www/common/onlyoffice/dist
  '';

  postBuild = ''
    rm -rf customize
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R . $out/

    substituteInPlace $out/lib/workers/index.js \
      --replace-warn "lib/workers/db-worker" "$out/lib/workers/db-worker"

    makeWrapper ${lib.getExe nodejs} $out/bin/cryptpad-server \
      --chdir $out \
      --add-flags server.js

    runHook postInstall
  '';

  meta = {
    homepage = "https://cryptpad.org";
    mainProgram = "cryptpad-server";
  };
}
