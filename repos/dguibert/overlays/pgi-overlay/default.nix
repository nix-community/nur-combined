self: super:
let
  wrapCCWith = with super; { cc
    , # This should be the only bintools runtime dep with this sort of logic. The
      # Others should instead delegate to the next stage's choice with
      # `targetPackages.stdenv.cc.bintools`. This one is different just to
      # provide the default choice, avoiding infinite recursion.
      bintools ? if targetPlatform.isDarwin then darwin.binutils else binutils
    , libc ? bintools.libc
    , ...
    } @ extraArgs:
      callPackage ./build-support/cc-wrapper (let self = {
    nativeTools = targetPlatform == hostPlatform && stdenv.cc.nativeTools or false;
    nativeLibc = targetPlatform == hostPlatform && stdenv.cc.nativeLibc or false;
    nativePrefix = stdenv.cc.nativePrefix or "";
    noLibc = !self.nativeLibc && (self.libc == null);

    isGNU = cc.isGNU or false;
    isClang = cc.isClang or false;

    inherit cc bintools libc;
  } // extraArgs; in self);

  pgiPackages = { version, mpi_version, sha256 }: rec {
    unwrapped = super.callPackage ./pgi {
      inherit version sha256;
    };
    mpi = super.callPackage ./pgi/mpi.nix {
      inherit sha256 pgi;
      version = mpi_version;
      pgi_version = version;
    };

    pgi = wrapCCWith rec {
      cc = unwrapped;
      extraPackages = [
      ];
      extraBuildCommands = ''
      ccLDFlags+=" -L${super.numactl}/lib -rpath,${super.numactl}/lib"
      echo "$ccLDFlags" > $out/nix-support/cc-ldflags
      '';
    };
    stdenv = super.overrideCC super.stdenv pgi;
  };

in
{
  pgiPackages_1804 = pgiPackages {
    version="2018-184";
    mpi_version = "2.1.2";
    sha256 ="07w5q1dv4824z4nzj1bh1xlrmb16bm0m343dzl72dbwlc5kkhmw7";
  };
  pgiPackages_1810 = pgiPackages {
    version="2018-1810";
    mpi_version = "2.1.2";
    sha256 ="09p3ndkddvqjxslx8ll93dqyyqwfzxp296fmpq0n1phk58yzhgsb";
  };
  pgiPackages_1904 = pgiPackages {
    version="2019-194";
    mpi_version = "3.1.3";
    sha256 ="13pngkq16w5n3g2578335qbvv3jk0f5vc96n8zrdc7bmvbaf1vi3";
  };
}

