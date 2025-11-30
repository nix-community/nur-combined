{
  blender,
  fetchurl,
  lib,
  libGLU,
  libdecor,
  libdrm,
  libglvnd,
  libxkbcommon,
  makeWrapper,
  numactl,
  ocl-icd,
  openal,
  stdenv,
  vulkan-loader,
  wayland,
  xorg,
  zlib,
  SDL2,
}:

let
  mkBlender =
    {
      pname,
      version,
      src,
    }:

    let
      libs = [
        wayland
        libdecor
        xorg.libX11
        xorg.libXi
        xorg.libXxf86vm
        xorg.libXfixes
        xorg.libXrender
        libxkbcommon
        libGLU
        libglvnd
        numactl
        SDL2
        libdrm
        ocl-icd
        stdenv.cc.cc.lib
        openal
      ]
      ++ lib.optionals (lib.versionAtLeast version "3.5") [
        xorg.libSM
        xorg.libICE
        zlib
      ]
      ++ lib.optionals (lib.versionAtLeast version "4.3") [
        vulkan-loader
      ];
    in

    stdenv.mkDerivation {
      inherit pname version src;

      nativeBuildInputs = [ makeWrapper ];

      preUnpack = ''
        mkdir -p $out/libexec
        cd $out/libexec
      '';

      installPhase = ''
        runHook preInstall

        cd $out/libexec
        mv blender-* blender

        mkdir -p $out/share/applications
        mkdir -p $out/share/icons/hicolor/scalable/apps
        mv ./blender/blender.desktop $out/share/applications/blender.desktop
        mv ./blender/blender.svg $out/share/icons/hicolor/scalable/apps/blender.svg

        mkdir $out/bin

        makeWrapper $out/libexec/blender/blender $out/bin/blender \
          --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${lib.makeLibraryPath libs}

        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          blender/blender

        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)"  \
          $out/libexec/blender/*/python/bin/python3*

        runHook postInstall
      '';

      meta = {
        inherit (blender.meta) mainProgram homepage description;
      };
    };
in
{
  blender_2_79 = mkBlender {
    pname = "blender-bin";
    version = "2.79-20190523-054dbb833e15";
    src = fetchurl {
      url = "https://builder.blender.org/download/blender-2.79-054dbb833e15-linux-glibc224-x86_64.tar.bz2";
      hash = "sha256-/qbRx4KKiJBka84M4iXB8z3PKzqBIuWG5Zihyf//QTU=";
    };
  };

  blender_2_81 = mkBlender {
    pname = "blender-bin";
    version = "2.81a";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.81/blender-2.81a-linux-glibc217-x86_64.tar.bz2";
      hash = "sha256-CNcYUF0esdJh77qWsHhyIKdtNXzluUrKEI/J4MM51sY=";
    };
  };

  blender_2_82 = mkBlender {
    pname = "blender-bin";
    version = "2.82a";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.82/blender-2.82a-linux64.tar.xz";
      hash = "sha256-+0ACWBIlJcUaWJcZkZfnQBBJT3HyshIsTdEiMk5u3r4=";
    };
  };

  blender_2_83 = mkBlender {
    pname = "blender-bin";
    version = "2.83.20";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.83/blender-2.83.20-linux-x64.tar.xz";
      hash = "sha256-KuPyb39J+TUrcPUFuPNj0MtRshS4ZmHZTuTpxYjEFPg=";
    };
  };

  blender_2_90 = mkBlender {
    pname = "blender-bin";
    version = "2.90.1";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.90/blender-2.90.1-linux64.tar.xz";
      hash = "sha256-BUZoxGo+VpIfKDcJ9Ro194YHhhgwAc8uqb4ySdE6xmc=";
    };
  };

  blender_2_91 = mkBlender {
    pname = "blender-bin";
    version = "2.91.2";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.91/blender-2.91.2-linux64.tar.xz";
      hash = "sha256-jx4eiFJ1DhA4V5M2x0YcGlSS2pc84Yjh5crpmy95aiM=";
    };
  };

  blender_2_92 = mkBlender {
    pname = "blender-bin";
    version = "2.92.0";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.92/blender-2.92.0-linux64.tar.xz";
      hash = "sha256-LNF61unWwkGsFLhK1ucrUHruyXnaPZJrGhRuiODrPrQ=";
    };
  };

  blender_2_93 = mkBlender {
    pname = "blender-bin";
    version = "2.93.18";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.93/blender-2.93.18-linux-x64.tar.xz";
      hash = "sha256-+H9z8n0unluHbqpXr0SQIGf0wzHR4c30ACM6ZNocNns=";
    };
  };

  blender_3_0 = mkBlender {
    pname = "blender-bin";
    version = "3.0.1";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.0/blender-3.0.1-linux-x64.tar.xz";
      hash = "sha256-TxeqPRDtbhPmp1R58aUG9YmYuMAHgSoIhtklTJU+KuU=";
    };
  };

  blender_3_1 = mkBlender {
    pname = "blender-bin";
    version = "3.1.2";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.1/blender-3.1.2-linux-x64.tar.xz";
      hash = "sha256-wdNFslxvg3CLJoHTVNcKPmAjwEu3PMeUM2bAwZ5UKVg=";
    };
  };

  blender_3_2 = mkBlender {
    pname = "blender-bin";
    version = "3.2.2";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.2/blender-3.2.2-linux-x64.tar.xz";
      hash = "sha256-FyZWAVfZDPKqrrbSXe0Xg9Zr/wQ4FM2VuQ/Arx2eAYs=";
    };
  };

  blender_3_3 = mkBlender {
    pname = "blender-bin";
    version = "3.3.21";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.3/blender-3.3.21-linux-x64.tar.xz";
      hash = "sha256-KvaLcca7JOLT4ho+LbOax9c2tseEPASQie/qg8zx8Y0=";
    };
  };

  blender_3_4 = mkBlender {
    pname = "blender-bin";
    version = "3.4.1";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.4/blender-3.4.1-linux-x64.tar.xz";
      hash = "sha256-FJf4P5Ppu73nRUIseV7RD+FfkvViK0Qhdo8Un753aYE=";
    };
  };

  blender_3_5 = mkBlender {
    pname = "blender-bin";
    version = "3.5.1";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.5/blender-3.5.1-linux-x64.tar.xz";
      hash = "sha256-2Crn72DqsgsVSCbE8htyrgAerJNWRs0plMXUpRNvfxw=";
    };
  };

  blender_3_6 = mkBlender {
    pname = "blender-bin";
    version = "3.6.23";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.6/blender-3.6.23-linux-x64.tar.xz";
      hash = "sha256-DpoYr00AYLgl6WF+JKd191ng+fZyccBi89U6U5AwrwA=";
    };
  };

  blender_4_0 = mkBlender {
    pname = "blender-bin";
    version = "4.0.2";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.0/blender-4.0.2-linux-x64.tar.xz";
      hash = "sha256-VYOlWIc22ohYxSLvF//11zvlnEem/pGtKcbzJj4iCGo=";
    };
  };

  blender_4_1 = mkBlender {
    pname = "blender-bin";
    version = "4.1.1";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.1/blender-4.1.1-linux-x64.tar.xz";
      hash = "sha256-qy6j/pkWAaXmvSzaeG7KqRnAs54FUOWZeLXUAnDCYNM=";
    };
  };

  blender_4_2 = mkBlender {
    pname = "blender-bin";
    version = "4.2.12";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.2/blender-4.2.12-linux-x64.tar.xz";
      hash = "sha256-lTcXAR4Aohv9TM8OivDZAbTD7wnEjxTBahjBRthYvPc=";
    };
  };

  blender_4_3 = mkBlender {
    pname = "blender-bin";
    version = "4.3.2";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.3/blender-4.3.2-linux-x64.tar.xz";
      hash = "sha256-TaHJVmc8BIXmMFTlY+5pGYzI+A2BV911kt/8impVkuY=";
    };
  };

  blender_4_4 = mkBlender {
    pname = "blender-bin";
    version = "4.4.3";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.4/blender-4.4.3-linux-x64.tar.xz";
      hash = "sha256-jTvgfSvEErUCxr/jz+PiIZWkFkB2hn2ph84UjXPCeUY=";
    };
  };

  blender_4_5 = mkBlender {
    pname = "blender-bin";
    version = "4.5.3";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.5/blender-4.5.3-linux-x64.tar.xz";
      hash = "sha256-l1xY/LJEJzg4U0u6dx5krYdzkhaw+bOaiIUxpJpy2EU=";
    };
  };

  blender_5_0 = mkBlender {
    pname = "blender-bin";
    version = "5.0.0";
    src = fetchurl {
      url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender5.0/blender-5.0.0-linux-x64.tar.xz";
      hash = "sha256-nelugUMq+6nApxXHIz8e/2FnBbdSJtxdD6Jwjd+w5SU=";
    };
  };
}
