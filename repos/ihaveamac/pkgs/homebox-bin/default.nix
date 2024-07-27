{ stdenvNoCC, fetchzip, lib }:

stdenvNoCC.mkDerivation rec {
  pname = "homebox-bin";
  version = "0.13.0";

  src = passthru.sources.${stdenvNoCC.hostPlatform.system}
    or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  passthru = {
    sources = rec {
      x86_64-linux = fetchzip {
        url = "https://github.com/sysadminsmedia/homebox/releases/download/v${version}/homebox_Linux_x86_64.tar.gz";
        sha256 = "sha256-vsgvqhHGwzOqsh/Rf1pPwU7zTUb5lfRujUqfBRHf0Ng=";
      };
      i686-linux = fetchzip {
        url = "https://github.com/sysadminsmedia/homebox/releases/download/v${version}/homebox_Linux_i386.tar.gz";
        sha256 = "sha256-K9N8ychmCRuktiG0yte+auZdWsWCQptBCz9axnMzlpA=";
      };
      aarch64-linux = fetchzip {
        url = "https://github.com/sysadminsmedia/homebox/releases/download/v${version}/homebox_Linux_arm64.tar.gz";
        sha256 = "sha256-KgUS+p49+EcE8S5la0o2ybFFy8u7hOxB0/lgpvSdfQE=";
      };
      armv6l-linux = fetchzip {
        url = "https://github.com/sysadminsmedia/homebox/releases/download/v${version}/homebox_Linux_armv6.tar.gz";
        sha256 = "sha256-RpSY+MDdn8lmgikfIzSi0daUa48tEa6cCN27POnXB6k=";
      };
      armv7l-linux = armv6l-linux;
      x86_64-darwin = fetchzip {
        url = "https://github.com/sysadminsmedia/homebox/releases/download/v${version}/homebox_Darwin_x86_64.tar.gz";
        sha256 = "sha256-tqKlpDPGJr3+4+85WdQi14NXAxOUgVjd04L4ZZw2b78=";
      };
      aarch64-darwin = fetchzip {
        url = "https://github.com/sysadminsmedia/homebox/releases/download/v${version}/homebox_Darwin_arm64.tar.gz";
        sha256 = "sha256-BNw/v0w2tbi2Y099ONYg/TMXNOdCXIpcjDrGM0aWubg=";
      };
    };
  };

  installPhase = ''
    mkdir -p $out/bin
    cp homebox $out/bin
  '';
}
