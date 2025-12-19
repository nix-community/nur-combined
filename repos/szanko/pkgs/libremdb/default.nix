{ lib
, stdenv
, fetchFromGitHub
, bash
, nodejs_20
, pnpm
}:

let
    # 1) fetch pnpm deps in a fixed-output derivation
    #
    # this one may use the network, but you must supply a hash.
    # first time you build, Nix will say “got: sha256-XXXX, expected …”
    # copy that value here.
    pnpmDeps = stdenv.mkDerivation {
      pname = "libremdb-pnpm-deps";
      version = "4.4.0";

      src = ./.;

      nativeBuildInputs = [
        nodejs_20
        pnpm
      ];

      # fixed-output bits:
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      # placeholder: build once, copy actual hash from error
      outputHash = "sha256-FgoYOwTq34snOhhWjKgR2FlDCaQ42+31CaQr+kPCbEI=";

      # we only need the store, so we can keep build simple
      buildPhase = ''
        # create local pnpm store from the frozen-lockfile
        export HOME=$PWD/.home
        mkdir -p $HOME
        pnpm fetch --frozen-lockfile --store-dir .pnpm-store
      '';

      installPhase = ''
        mkdir -p $out
        # pnpm by default makes .pnpm-store in the project
        cp -r .pnpm-store $out/store
      '';
    };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libremdb";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "zyachel";
    repo = "libremdb";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rDDJzhTuOknBaUhVKyow52qxATiV8Cprjpoxx8jW7Gs=";
  };

  
  buildInputs = [
    nodejs_20
    pnpm
  ];

  buildPhase = ''
    export HOME=$PWD/.home
    mkdir -p $HOME

    export NODE_ENV=production

    # install using the pre-fetched store
    pnpm install \
      --frozen-lockfile \
      --offline \
      --store-dir=${pnpmDeps}/store

    # build next (produces the .next tree you showed)
    pnpm run build
  '';


  

  postInstall = ''
    # put app files in a clean spot
    mkdir -p $out/app

    # buildNpmPackage leaves node_modules in $out/lib/node_modules/<name>
    # and your source in $out
    # Next.js runtime needs .next + public + config + node_modules

    cp -r .next $out/app/.next

    if [ -d public ]; then
      cp -r public $out/app/public
    fi

    if [ -f package.json ]; then
      cp package.json $out/app/package.json
    fi
    if [ -f next.config.js ]; then
      cp next.config.js $out/app/next.config.js
    fi
    if [ -f next.config.mjs ]; then
      cp next.config.mjs $out/app/next.config.mjs
    fi

    # node_modules is here (buildNpmPackage layout):
    #   $out/lib/node_modules/<pname>
    cp -r $out/lib/node_modules/${"nextjs-app"} $out/app/node_modules

    mkdir -p $out/bin
    cat > $out/bin/next-app <<'EOF'
    #!${bash}/bin/bash
    set -euo pipefail
    cd $out/app
    exec ${nodejs_20}/bin/npx next start -p "${PORT:-3000}"
    EOF
    chmod +x $out/bin/next-app
  '';
  

  meta = {
    description = "A free & open source IMDb front-end";
    homepage = "https://github.com/zyachel/libremdb.git";
    changelog = "https://github.com/zyachel/libremdb/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "libremdb";
    platforms = lib.platforms.all;
  };
})
