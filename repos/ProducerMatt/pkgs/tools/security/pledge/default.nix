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
    version = "1.4"; # July 25th 2022
    rev = "${name}-${version}"; # looks redundant but useful if you want a specific Git commit

    # NOTE(ProducerMatt): Cosmo embeds relevant licenses near the top of the
    # executable. You can manually inspect by viewing the binary with `less`.
    # Grep for "Copyright".
    #
    # At the time of this writing in MODE=rel: ISC for Cosmo, BSD3 for getopt
    license = with lib.licenses; [ isc bsd3 ];
    #e if compiling in MODE=asan or dbg, add licenses.zlib

    maintainers = [ lib.maintainers.ProducerMatt ];
  };
  cosmoMeta = {
    mode="rel";
    path="tool/build";
    target = "${commonMeta.name}.com";
    make = "./build/bootstrap/make.com";
    platformFlag = "";
    # Since we're only compiling for Linux, it makes sense to pass
    # "CPPFLAGS=-DSUPPORT_VECTOR=0b00000001", which disables all non-Linux code.
    # However this currently fails.
  };
  cosmoSrc = fetchFromGitHub {
    owner = "jart";
    repo = "cosmopolitan";
    rev = commonMeta.rev;
    sha256 = "FDyQC8WoTB1dRwRp+BRuV9k8QsZbX2A9SXKuVpX/11c=";
  };
in
  stdenv.mkDerivation {
    name = "${commonMeta.name}-${commonMeta.version}";
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];

    src = cosmoSrc;
    buildPhase = ''
      sh ./build/bootstrap/cocmd.com --assimilate
      sh ./build/bootstrap/make.com --assimilate
      ${cosmoMeta.make} MODE=${cosmoMeta.mode} -j$NIX_BUILD_CORES \
          ${cosmoMeta.platformFlag} V=0 \
          o/${cosmoMeta.mode}/${cosmoMeta.path}/${cosmoMeta.target}
    '';
    installPhase = ''
      mkdir $out
      mkdir $out/bin
      o/${cosmoMeta.mode}/${cosmoMeta.path}/${cosmoMeta.target} --assimilate
      cp o/${cosmoMeta.mode}/${cosmoMeta.path}/${cosmoMeta.target} $out/bin/${commonMeta.name}
    '';

    meta = {
      homepage = "https://justine.lol/pledge/";
      platforms = [ "x86_64-linux" ];
    };
  }
