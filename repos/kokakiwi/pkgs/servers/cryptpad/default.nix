{ lib
, stdenvNoCC

, buildNpmPackage
, fetchFromGitHub
, fetchzip

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
      rev = "e1267803ea749cd93e9d5f81438011ea620d04af";
      hash = "sha256-iIds0GnCHAyeIEdSD4aCCgDtnnwARh3NE470CywseS0=";
    };
  };
  mkOnlyOffice = {
    pname, version
  }: stdenvNoCC.mkDerivation (final: {
    pname = "${pname}-onlyoffice";
    inherit version;

    x2t = let
      version = "v7.3+1";
    in fetchzip {
      url = "https://github.com/cryptpad/onlyoffice-x2t-wasm/releases/download/${version}/x2t.zip";
      hash = "sha256-d5raecsTOflo0UpjSEZW5lker4+wdkTb6IyHNq5iBg8=";
      stripRoot = false;
    };

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
      cp -Tr $x2t $out/x2t
    '';
  });
in buildNpmPackage rec {
  pname = "cryptpad";
  version = "2024.6.1";

  src = fetchFromGitHub {
    owner = "cryptpad";
    repo = "cryptpad";
    rev = version;
    hash = "sha256-qwyXpTY8Ds7R5687PVGZa/rlEyrAZjNzJ4+VQZpF8v0=";
  };

  npmDepsHash = "sha256-GSTPsXqe/rxiDh5OW2t+ZY1YRNgRSDxkJ0pvcLIFtFw=";

  inherit nodejs;

  onlyOffice = lib.optional withOnlyOffice (mkOnlyOffice {
    inherit pname version;
  });

  makeCacheWritable = true;
  dontFixup = true;

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

  passthru = {
    inherit onlyOffice;
  };

  meta = {
    description = "Collaborative office suite, end-to-end encrypted and open-source.";
    homepage = "https://cryptpad.org";
    changelog = "https://github.com/cryptpad/cryptpad/releases/tag/${version}";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.all;
    mainProgram = "cryptpad-server";
  };
}
