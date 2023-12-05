{
  lib,
  fetchFromGitHub,
  buildGoModule,
  mkYarnPackage,
  fetchYarnDeps,
  esbuild,
}: let
  version = "1.33.0";
  srcHash = "sha256-kjiDAeYqPMjX197qK47Ond8TeqVeEX3D/9EQbX1Wvas=";
  yarnHash = "sha256-M+mrQhmwL1ufMzFduyXwcZTjMoK5hEU2I5YSTd16/MI=";
  rev = "v${version}";

  common = {
    inherit version yarnHash;

    src = fetchFromGitHub {
      inherit rev;

      owner = "autobrr";
      repo = "autobrr";
      sha256 = srcHash;
    };
  };

  autobrr-frontend = mkYarnPackage {
    name = "autobrr-frontend";
    src = "${common.src}/web";
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;

    offlineCache = fetchYarnDeps {
      yarnLock = ./yarn.lock;
      hash = common.yarnHash;
    };

    ESBUILD_BINARY_PATH = "${lib.getExe (esbuild.override {
      buildGoModule = args:
        buildGoModule (args
          // rec {
            version = "1.33.0";
            src = fetchFromGitHub {
              owner = "evanw";
              repo = "esbuild";
              rev = "v${version}";
              hash = "sha256-mED3h+mY+4H465m02ewFK/BgA1i/PQ+ksUNxBlgpUoI=";
            };
            vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
          });
    })}";

    buildPhase = ''
      runHook preBuild

      yarn --offline build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -R deps/web/dist $out

      runHook postInstall
    '';

    # Do not attempt generating a tarball for autobrr-frontend again.
    doDist = false;
  };
in
  buildGoModule {
    inherit (common) version src;

    pname = "autobrr";
    vendorHash = "sha256-15uzlsVbskJ3z3snwuadugePqiU+JQNPdpSBkqow5kQ=";

    ldflags = [
      "-X main.version=${version}"
      "-X main.commit=${rev}"
    ];

    preBuild = ''
      cp -r ${autobrr-frontend}/* web/dist
    '';

    meta = with lib; {
      description = "Modern, easy to use download automation for torrents and usenet. ";
      homepage = "https://autobrr.com/";
      license = with licenses; [gpl2];
      maintainers = with maintainers; [pborzenkov];
    };
  }
