{ lib, stdenv, pins
, buildGoModule
, napalm
, nodejs
}:
buildGoModule rec {
  pname = "broadcast-box";
  version = "unstable-2023-09-09";

  src = pins.broadcast-box.outPath;

  vendorHash = "sha256-0jmm0v/8SKm7ulucH68S8To5/LD4Dlz1T4KqtdBCNT0=";

  meta = with lib; {
    description = "WebRTC broadcast server";
    homepage = https://github.com/Glimesh/broadcast-box;
    maintainers = with maintainers; [ arobyn ];
    platforms   = [ "x86_64-linux" ];
    license     = licenses.mit;
  };

  passthru.web = napalm.buildPackage "${src}/web" {
    pname = "${pname}-web";
    inherit version nodejs;
    preBuild = ''
      cp "${src}/.env.production" ../
      substituteInPlace package.json \
        --replace "dotenv -e" "node node_modules/dotenv-cli/cli.js -e"
    '';
    # preNpmHook = ''
    #   if ! [[ -f ../.env.production ]]; then
    #     cp "${src}/.env.production" ../
    #   fi
    # '';
    npmCommands = [
      "npm install --loglevel verbose --nodedir=${nodejs}/include/node"
      "npm run build --loglevel verbose --nodedir=${nodejs}/include/node"
    ];
    installPhase = ''
      runHook preInstall

      cp -r $sourceRoot/build $out

      runHook postInstall
    '';

    inherit meta;
  };
}
