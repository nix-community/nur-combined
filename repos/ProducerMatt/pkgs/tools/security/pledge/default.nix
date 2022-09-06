{ lib, fetchFromGitHub, stdenv }:

# TODO(ProducerMatt): verify executable's license block against a checksum for
# automated CYA. One possible route:
#
# $ readelf -a o//tool/build/pledge.com.dbg |\
#    grep kLegalNotices |\
#    awk '{print $2}'
#
# Gets the hex address of where the licenses start. From there it's a double-nul
# terminated list of strings.


let
  commonMeta = rec {
    name = "pledge";
    version = "2022-09-06"; # September 6th 2022
  };

  cosmoMeta = {
    mode="rel";
    path="tool/build";
    targets = [ "pledge.com" "unveil.com" ];
    make = "make";
    #make = "./build/bootstrap/make.com";
    platformFlag = "";
    # Since we're only compiling for Linux, it makes sense to pass
    # "CPPFLAGS=-DSUPPORT_VECTOR=0b00000001", which disables all non-Linux code.
    # However this currently fails.
  };
  cosmoSrc = fetchFromGitHub {
    owner = "jart";
    repo = "cosmopolitan";
    rev = "dbf12c3";
    sha256 = "k8L2KuaWTvn838Uqr8/rX/IfVrG4IptSuZE8Ft7Wqx4=";
  };
  buildStuff = toString (map (item: ''
      ${cosmoMeta.make} MODE=${cosmoMeta.mode} -j$NIX_BUILD_CORES \
          ${cosmoMeta.platformFlag} V=0 \
          o/${cosmoMeta.mode}/${cosmoMeta.path}/${item}
      '') cosmoMeta.targets);
  installStuff = toString (map (item: ''
      o/${cosmoMeta.mode}/${cosmoMeta.path}/${item} --assimilate
      cp o/${cosmoMeta.mode}/${cosmoMeta.path}/${item} $out/bin/
      '') cosmoMeta.targets);
in
  stdenv.mkDerivation {
    name = "${commonMeta.name}-${commonMeta.version}";
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];

    src = cosmoSrc;
    buildPhase = ''
      sh ./build/bootstrap/compile.com --assimilate
      sh ./build/bootstrap/cocmd.com --assimilate
      sh ./build/bootstrap/echo.com --assimilate
      sh ./build/bootstrap/rm.com --assimilate
      '' + buildStuff + ''
      echo "" # workaround for nix's "malformed json" errors
    '';
    installPhase = ''
      mkdir $out
      mkdir $out/bin
      '' + installStuff;

    meta = {
      homepage = "https://justine.lol/pledge/";
      mainProgram = "pledge.com";
      changelog = "https://github.com/jart/cosmopolitan/commits/dbf12c30b05e8bffaa73356c229391538fd0b322";
      description = "Easily launch commands in a sandbox inspired by the design of openbsd's pledge() and unveil() system calls.";
      platforms = [ "x86_64-linux" ];

      # NOTE(ProducerMatt): Cosmo embeds relevant licenses near the top of the
      # executable. You can manually inspect by viewing the binary with `less`.
      # Grep for "Copyright".
      #
      # At the time of this writing in MODE=rel: ISC for Cosmo, BSD3 for getopt,
      # zlib. Unveil includes gdtoa which is MIT.
      license = with lib.licenses; [ isc bsd3 zlib mit ];

      maintainers = [ lib.maintainers.ProducerMatt ];
    };
  }

# NOTE(ProducerMatt): Landlock Make is currently unhappy with the Nix build
# environment. For this reason we use the stdenv make, which is slower and
# theoretically less secure. WWhen landlock is working add this back to the
# build And set $cosmoMeta.make to "o/optlinux/third_party/make/make.com"
#
#      ./build/bootstrap/make.com --assimilate
#
#      # build ape headers
#      ./build/bootstrap/make.com -j$NIX_BUILD_CORES \
#         ${cosmoMeta.platformFlag} o//ape o//libc
#
#      # build optimized make
#      ./build/bootstrap/make.com -j$NIX_BUILD_CORES \
#          ${cosmoMeta.platformFlag} V=0 \
#          MODE=optlinux ${cosmoMeta.make}
