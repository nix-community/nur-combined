{ stdenv
, fetchFromGitHub
, fetchpatch
, asciidoc
, cmake
, zstd
, perl
, makeWrapper
}:

let ccache = stdenv.mkDerivation rec {
  pname = "ccache";
  version = "4.0";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "1frcplrv61m2iwc6jwycpbcz1101xl6s4sh8p87prdj98l60lyrx";
  };

  # TODO: Remove patches in next release
  patches = [
    # Fix badly named man page filename
    (fetchpatch {
      url = "https://github.com/ccache/ccache/commit/223e706fb24ce86eb0ad86079a97e6f345b9ef40.patch";
      sha256 = "1h7amp3ka45a79zwlxh8qnzx6n371gnfpfgijcqljps7skhl5gjg";
    })
    # Build and install man page by default
    (fetchpatch {
      url = "https://github.com/ccache/ccache/commit/294ff2face26448afa68e3ef7b68bf4898d6dc77.patch";
      sha256 = "0rx69qn41bgksc4m3p59nk5d6rz72rwnfska9mh5j62pzfm8axja";
    })
  ];

  nativeBuildInputs = [ asciidoc cmake ];

  buildInputs = [ zstd ];

  outputs = [ "out" "man" ];

  doCheck = true;
  checkInputs = [ perl ];
  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  passthru = {
    # A derivation that provides gcc and g++ commands, but that
    # will end up calling ccache for the given cacheDir
    links = {unwrappedCC, extraConfig}: stdenv.mkDerivation {
      name = "ccache-links";
      passthru = {
        isClang = unwrappedCC.isClang or false;
        isGNU = unwrappedCC.isGNU or false;
      };
      inherit (unwrappedCC) lib;
      nativeBuildInputs = [ makeWrapper ];
      buildCommand = ''
        mkdir -p $out/bin

        wrap() {
          local cname="$1"
          if [ -x "${unwrappedCC}/bin/$cname" ]; then
            makeWrapper ${ccache}/bin/ccache $out/bin/$cname \
              --run ${stdenv.lib.escapeShellArg extraConfig} \
              --add-flags ${unwrappedCC}/bin/$cname
          fi
        }

        wrap cc
        wrap c++
        wrap gcc
        wrap g++
        wrap clang
        wrap clang++

        for executable in $(ls ${unwrappedCC}/bin); do
          if [ ! -x "$out/bin/$executable" ]; then
            ln -s ${unwrappedCC}/bin/$executable $out/bin/$executable
          fi
        done
        for file in $(ls ${unwrappedCC} | grep -vw bin); do
          ln -s ${unwrappedCC}/$file $out/$file
        done
      '';
    };
  };

  meta = with stdenv.lib; {
    description = "Compiler cache for fast recompilation of C/C++ code";
    homepage = "https://ccache.dev";
    downloadPage = "https://ccache.dev/download.html";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.unix;
  };
};
in ccache
