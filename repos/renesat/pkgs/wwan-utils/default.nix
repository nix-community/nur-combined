{
  lib,
  stdenv,
  fetchurl,
  fetchgit,
  perl,
  glibc,
  makeWrapper,
}: let
  MockSub = perl.pkgs.buildPerlPackage rec {
    pname = "Mock-Sub";
    version = "1.09";
    src = fetchurl {
      url = "mirror://cpan/authors/id/S/ST/STEVEB/${pname}-${version}.tar.gz";
      hash = "sha256-hqwP8kLnEt8EDFWaoNy4cZFNkvS4aXfPFAK2+BManBA=";
    };
  };
  IPCShareable = perl.pkgs.buildPerlPackage rec {
    pname = "IPC-Shareable";
    version = "1.13";
    src = fetchurl {
      url = "mirror://cpan/authors/id/S/ST/STEVEB/${pname}-${version}.tar.gz";
      hash = "sha256-RW5mX3Kj+3ulqOcOMhz8nIJZ3vsxEbUZQK0IyrnADms=";
    };
    propagatedBuildInputs = with perl.pkgs; [
      JSON
      StringCRC32
    ];
    checkInputs = with perl.pkgs; [
      TestSharedFork
      MockSub
    ];
  };
in
  stdenv.mkDerivation {
    pname = "wwan-utils";
    version = "2019-12-10";

    src = fetchgit {
      url = "https://git.mork.no/wwan.git";
      hash = "sha256-U/m1uabraUOHWXN/yRPbiapv2PBe8KHggo+fzf5GoBc=";
    };

    nativeBuildInputs = [makeWrapper];
    buildInputs =
      [
        perl
      ]
      ++ (with perl.pkgs; [
        UUIDTiny
        IPCShareable
      ]);

    installPhase = let
      h2ph-libs = [
        "sys/ioctl.h"
        "features.h"
        "features-time64.h"
        "bits/wordsize.h"
        "bits/timesize.h"
        "stdc-predef.h"
        "sys/cdefs.h"
        "bits/long-double.h"
        "gnu/stubs.h"
        "gnu/stubs-64.h"
        "bits/ioctls.h"
        "asm/ioctls.h"
        "asm-generic/ioctls.h"
        "linux/ioctl.h"
        "asm/ioctl.h"
        "asm-generic/ioctl.h"
        "bits/ioctl-types.h"
        "sys/ttydefaults.h"
      ];
    in ''
      mkdir -p $out/bin $out/${perl.libPrefix}/${perl.version}
      install -Dm755 scripts/* -t $out/bin

      for h in ${builtins.concatStringsSep " " h2ph-libs}; do
          ${perl}/bin/h2ph -d $out ${glibc.dev}/include/$h
          mkdir -p $out/include/$(dirname $h)
          mv $out${glibc.dev}/include/''${h%.h}.ph $out/include/$(dirname $h)
      done
      mv $out/_h2ph_pre.ph $out/include
      cp -r $out/include/* $out/${perl.libPrefix}/${perl.version}
      rm -r $out/{nix,include}
      wrapProgram $out/bin/swi_setusbcomp.pl --prefix PATH : ${perl}/bin:$out/bin \
         --suffix PERL5LIB : $PERL5LIB \
         --suffix PERL5LIB : $out/${perl.libPrefix}/${perl.version}
    '';

    meta = {
      description = "https://git.mork.no/wwan.git";
      homepage = "https://git.mork.no/wwan.git";
      platforms = lib.platforms.linux;
    };
  }
