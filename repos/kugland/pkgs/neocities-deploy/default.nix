{ pkgs
, lib
, stdenvNoCC
}:
stdenvNoCC.mkDerivation rec {
  pname = "neocities-deploy";
  version = "0.1.13";
  src = {
    "x86_64-linux" = pkgs.fetchzip {
      url = "https://github.com/kugland/neocities-deploy/releases/download/v${version}/neocities-deploy-Linux-x86_64-musl.tar.gz";
      sha256 = "sha256:0xl5nj6rb145378pqiysiv0g57skg8ydf92rqw45cfv271hizfs0";
    };
    "i686-linux" = pkgs.fetchzip {
      url = "https://github.com/kugland/neocities-deploy/releases/download/v${version}/neocities-deploy-Linux-i686-musl.tar.gz";
      sha256 = "sha256:136l3rb7gpk5dpckinyvzwk2sr8r44zhamrjv1vzmnzlrvbxbkgg";
    };
    "aarch64-linux" = pkgs.fetchzip {
      url = "https://github.com/kugland/neocities-deploy/releases/download/v${version}/neocities-deploy-Linux-aarch64-musl.tar.gz";
      sha256 = "sha256:12pkm8kjg1pqa12p9b05g106djqbrbghnrf5i0kwbzw94qz68gm4";
    };
    "armv7l-linux" = pkgs.fetchzip {
      url = "https://github.com/kugland/neocities-deploy/releases/download/v${version}/neocities-deploy-Linux-arm-musl.tar.gz";
      sha256 = "sha256:0r3gpmif47i13scr4hnzmdvd6vpqsi32jchzfrvi8gsxmanwjx5j";
    };
    "x86_64-darwin" = pkgs.fetchzip {
      url = "https://github.com/kugland/neocities-deploy/releases/download/v${version}/neocities-deploy-Darwin-x86_64.tar.gz";
      sha256 = "sha256:16mndya7s172nnr32s4vgr6iiql917szn311nk89i3lyfvaxqgna";
    };
    "aarch64-darwin" = pkgs.fetchzip {
      url = "https://github.com/kugland/neocities-deploy/releases/download/v${version}/neocities-deploy-Darwin-aarch64.tar.gz";
      sha256 = "sha256:0bcs0fay1r12liqb6w1gbvd297fda85p13476177chlimgabjm8q";
    };
  }."${pkgs.system}";
  installPhase = ''
    mkdir -p $out/bin
    cp $src/neocities-deploy $out/bin/neocities-deploy
    chmod +x $out/bin/neocities-deploy
  '';
  meta = with lib; {
    description = "A command-line tool for deploying your Neocities site";
    homepage = "https://github.com/kugland/neocities-deploy";
    license = licenses.gpl3;
    maintainers = [ lib.maintainers.kugland ];
  };
}
