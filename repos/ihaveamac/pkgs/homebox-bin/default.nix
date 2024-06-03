{ stdenvNoCC, fetchzip, lib }:

stdenvNoCC.mkDerivation rec {
  pname = "homebox-bin";
  version = "0.10.3";

  src = passthru.sources.${stdenvNoCC.hostPlatform.system}
    or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  passthru = {
    sources = rec {
      x86_64-linux = fetchzip {
        url = "https://github.com/hay-kot/homebox/releases/download/v${version}/homebox_Linux_x86_64.tar.gz";
        sha256 = "sha256-R1EmV4AJv+vEFn21cUsxSs40fvcK+wPGPwqqP9K6Aek=";
      };
      i686-linux = fetchzip {
        url = "https://github.com/hay-kot/homebox/releases/download/v${version}/homebox_Linux_i386.tar.gz";
        sha256 = "sha256-T7XBw16/crJxk2EYcoRaPbbsq1v2l4O+b/HNw1p53bI=";
      };
      aarch64-linux = fetchzip {
        url = "https://github.com/hay-kot/homebox/releases/download/v${version}/homebox_Linux_arm64.tar.gz";
        sha256 = "sha256-5TII40HJkIItsB+VpF8tFLuI07SrmM1icPgwM0kiQtQ=";
      };
      armv6l-linux = fetchzip {
        url = "https://github.com/hay-kot/homebox/releases/download/v${version}/homebox_Linux_arm64.tar.gz";
        sha256 = "sha256-5TII40HJkIItsB+VpF8tFLuI07SrmM1icPgwM0kiQtQ=";
      };
      armv7l-linux = armv6l-linux;
      x86_64-darwin = fetchzip {
        url = "https://github.com/hay-kot/homebox/releases/download/v${version}/homebox_Darwin_x86_64.tar.gz";
        sha256 = "sha256-QAOAR6eezhVVP5htRUzdZxa6wuxoR7+EAon0rSrWNJY=";
      };
      aarch64-darwin = fetchzip {
        url = "https://github.com/hay-kot/homebox/releases/download/v${version}/homebox_Darwin_arm64.tar.gz";
        sha256 = "sha256-JU10ijRozr8unm7jnkxF5dKu39st5/8RYCWdyt5RHQc=";
      };
    };
  };

  installPhase = ''
    mkdir -p $out/bin
    cp homebox $out/bin
  '';
}
