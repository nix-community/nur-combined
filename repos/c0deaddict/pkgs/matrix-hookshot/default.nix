{ lib
, stdenv
, mkYarnPackage
, fetchFromGitHub
, rustPlatform
, napi-rs-cli
, nodejs
, matrix-sdk-crypto-nodejs
, makeWrapper
}:

mkYarnPackage rec {
  pname = "matrix-hookshot";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = pname;
    rev = version;
    sha256 = "sha256-18aw+mv2HdPJ1ieBSuDbr3I+DxkrgE1IMEOjonQ1W9k=";
  };

  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;

  packageResolutions = {
    "@matrix-org/matrix-sdk-crypto-nodejs" = "${matrix-sdk-crypto-nodejs}/lib/node_modules/@matrix-org/matrix-sdk-crypto-nodejs";
  };

  libRs = rustPlatform.buildRustPackage {
    name = "${pname}-libRs";
    inherit src;
    cargoSha256 = "sha256-xw9AvvX2AG14fVoo9NZDk1lc5zZeA7gy5zvGMre/l3g=";

    nativeBuildInputs = [ napi-rs-cli ];

    doCheck = false;

    buildPhase = ''
      napi build --release ./lib
    '';

    installPhase = ''
      mkdir $out
      cp -r ./lib $out/
    '';
  };

  # We build in a separate package, because this requires devDependencies that
  # we do not wish to bundle.
  build = mkYarnPackage {
    name = "${pname}-build";
    inherit version src yarnLock yarnNix;

    buildPhase = ''
      pushd deps/matrix-hookshot

      cp ${libRs}/lib/index.d.ts src/libRs.d.ts
      chmod u+rw src/libRs.d.ts
      mkdir ./lib
      cp ${libRs}/lib/matrix-hookshot-rs.node ./lib/

      yarn --offline run build:app:fix-defs
      yarn --offline run build:app
      yarn --offline run build:web

      popd
    '';

    installPhase = ''
      mkdir $out
      mv deps/matrix-hookshot/{lib,public} $out/
    '';

    doDist = false;
  };

  yarnFlags = [ "--production" ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    outdir=$out/libexec/matrix-hookshot
    mkdir -p $outdir
    cp deps/matrix-hookshot/package.json $outdir/
    cp -r node_modules $outdir/
    cp -r ${build}/{lib,public} $outdir/

    makeWrapper '${nodejs}/bin/node' "$out/bin/${pname}" \
      --set NODE_PATH "$outdir/node_modules" \
      --add-flags "$outdir/lib/App/BridgeApp.js"

    runHook postInstall
  '';

  # don't generate the dist tarball.
  doDist = false;

  meta = with lib; {
    homepage = "https://github.com/matrix-org/matrix-hookshot";
    description = "Bridge between Matrix and multiple project management services, such as GitHub, GitLab and JIRA.";
    maintainers = with maintainers; [ c0deaddict ];
    platforms = platforms.all;
    license = licenses.asl20;
  };
}
