{ lowPrio, newScope, pkgs, stdenv, cmake, libstdcxxHook
, libxml2, python, isl, fetchurl, overrideCC, wrapCCWith
, llvmPackages_7
, fetchFromGitHub
#, buildLlvmTools # tools, but from the previous stage, for cross
#, targetLlvmLibraries # libraries, but from the next stage, for cross
, hostPlatform
, targetPlatform
, darwin
, binutils
, gcc8
}:
# forked from pkgs/development/compilers/llvm/6/default.nix

let
  release_version = "7.0.1";
  version = release_version; # differentiating these is important for rc's

    flang_src = fetchFromGitHub {
      owner = "flang-compiler";
      repo = "flang";
      rev = "master";
      sha256 = "0akl3aqs1f97xm0kryfim4gsfknwpp9avqqgs5n6x18jrdg11k3k";
    };

    libraries  = let
        callPackage = newScope (libraries // { inherit stdenv cmake libxml2 python isl release_version version; });
      in   llvmPackages_7.libraries.extend (s: p: {
          openmp = callPackage ./openmp.nix { };
        });
    tools = let
      callPackage = newScope (tools // { inherit stdenv cmake libxml2 python isl release_version version flang_src; });
      mkExtraBuildCommands = cc: flang: ''
        ${pkgs.lib.optionalString (flang !=null) "echo \"-I${flang}/include -L${flang}/lib -L${tools.libpgmath}/lib -Wl,-rpath ${flang}/lib -Wl,-rpath ${tools.libpgmath}/lib -B${flang}/bin\" >> $out/nix-support/cc-cflags"}

        rsrc="$out/resource-root"
        mkdir "$rsrc"
        ln -s "${cc}/lib/clang/${release_version}/include" "$rsrc"
        ln -s "${libraries.compiler-rt.out}/lib" "$rsrc/lib"
        echo "-resource-dir=$rsrc" >> $out/nix-support/cc-cflags
      '' + stdenv.lib.optionalString stdenv.targetPlatform.isLinux ''
        echo "--gcc-toolchain=${tools.clang-unwrapped.gcc}" >> $out/nix-support/cc-cflags
      '';
      wrapCCWith = { cc
        , # This should be the only bintools runtime dep with this sort of logic. The
          # Others should instead delegate to the next stage's choice with
          # `targetPackages.stdenv.cc.bintools`. This one is different just to
          # provide the default choice, avoiding infinite recursion.
          bintools ? if targetPlatform.isDarwin then darwin.binutils else binutils
        , libc ? bintools.libc
        , ...
        } @ extraArgs:
          callPackage ../../build-support/cc-wrapper (let self = {
        nativeTools = targetPlatform == hostPlatform && stdenv.cc.nativeTools or false;
        nativeLibc = targetPlatform == hostPlatform && stdenv.cc.nativeLibc or false;
        nativePrefix = stdenv.cc.nativePrefix or "";
        noLibc = !self.nativeLibc && (self.libc == null);

        isGNU = cc.isGNU or false;
        isClang = cc.isClang or false;

        inherit cc bintools libc;
      } // extraArgs; in self);

    in llvmPackages_7.tools.extend (s: p: {
        clang-unwrapped = callPackage ./clang { };
        libpgmath = callPackage ../libpgmath.nix {
          stdenv = llvmPackages_7.stdenv;
        };
        flang-unwrapped = callPackage ../flang.nix {
          stdenv = llvmPackages_7.stdenv;
          inherit (libraries) openmp;
        };
        flang = wrapCCWith rec {
          name = "flang";
          cc = tools.clang-unwrapped;
          extraPackages = [
            libstdcxxHook
            libraries.compiler-rt
            tools.flang-unwrapped
          ];
          extraBuildCommands = mkExtraBuildCommands cc tools.flang-unwrapped;
        };
        llvm = callPackage ./llvm.nix { };
        clang = if stdenv.cc.isGNU then tools.libstdcxxClang else tools.libcxxClang;
        libstdcxxClang = wrapCCWith rec {
          cc = tools.clang-unwrapped;
          extraPackages = [
            libstdcxxHook
            libraries.compiler-rt
          ];
          extraBuildCommands = mkExtraBuildCommands cc null;
        };

        libcxxClang = wrapCCWith rec {
          cc = tools.clang-unwrapped;
          extraPackages = [
            libraries.libcxx
            libraries.libcxxabi
            libraries.compiler-rt
          ];
          extraBuildCommands = mkExtraBuildCommands cc null;
        };

      });
  in { inherit tools libraries; } // libraries // tools

