final: prev: let
  wrapCCWith = with prev;
    {
      cc,
      # This should be the only bintools runtime dep with this sort of logic. The
      # Others should instead delegate to the next stage's choice with
      # `targetPackages.stdenv.cc.bintools`. This one is different just to
      # provide the default choice, avoiding infinite recursion.
      bintools ?
        if targetPlatform.isDarwin
        then darwin.binutils
        else binutils,
      libc ? bintools.libc,
      ...
    } @ extraArgs:
      callPackage ./build-support/cc-wrapper (let
        self =
          {
            nativeTools = targetPlatform == hostPlatform && stdenv.cc.nativeTools or false;
            nativeLibc = targetPlatform == hostPlatform && stdenv.cc.nativeLibc or false;
            nativePrefix = stdenv.cc.nativePrefix or "";
            noLibc = !self.nativeLibc && (self.libc == null);

            isGNU = cc.isGNU or false;
            isClang = cc.isClang or false;

            inherit cc bintools libc;
          }
          // extraArgs;
      in
        self);

  nvhpcPackages = {
    version,
    url,
    sha256,
    ...
  } @ args: let
    args_ = builtins.removeAttrs args ["version" "url" "sha256"];
  in rec {
    unwrapped = prev.callPackage ./nvhpc {
      inherit version url sha256;
    };
    nvhpc = wrapCCWith (rec {
        cc = unwrapped;
        extraPackages = [
        ];
        extraBuildCommands = ''
          ccLDFlags+=" -L${prev.numactl}/lib -rpath,${prev.numactl}/lib"
          echo "$ccLDFlags" > $out/nix-support/cc-ldflags
        '';
      }
      // args_);
    stdenv = prev.overrideCC prev.stdenv nvhpc;
  };
in {
  nvhpcPackages_21_7 = nvhpcPackages {
    version = "21.7";
    url = "https://developer.download.nvidia.com/hpc-sdk/21.7/nvhpc_2021_217_Linux_x86_64_cuda_11.4.tar.gz";
    sha256 = "sha256-4gYuC09W9LMe2I0I+MufNxvy8vsMWaBrJHODPHQsi3U=";
    libcxx = null;
  };
}
