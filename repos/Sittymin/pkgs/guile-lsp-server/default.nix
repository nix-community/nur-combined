{ lib
, stdenv
, fetchFromGitea
, fetchzip
, guile
, pkg-config
, automake
, autoconf
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "guile-lsp-server";
  version = "0.4.6";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "rgherdt";
    repo = "scheme-lsp-server";
    rev = "${version}";
    hash = "sha256-uhAh4sbGvue82f8rB65a3RDh8RN/tZg0nNt9zDaLtLk=";
  };

  srfi = fetchFromGitea {
    domain = "codeberg.org";
    owner = "rgherdt";
    repo = "srfi";
    rev = "e598c28eb78e9c3e44f5c3c3d997ef28abb6f32e";
    hash = "sha256-kvM2v/nDou0zee4+qcO5yN2vXt2y3RUnmKA5S9iKFE0=";
  };
  irregex = fetchzip {
    url = "http://synthcode.com/scheme/irregex/irregex-0.9.10.tar.gz";
    hash = "sha256-zeKbqsY3KoAhh16+EzZpI/11+lzgKV53odW6W4pQDnI=";
  };
  json-rpc = fetchFromGitea {
    domain = "codeberg.org";
    owner = "rgherdt";
    repo = "scheme-json-rpc";
    rev = "70192263f3947624400803e00fa37e69b9e574a3";
    hash = "sha256-sTJxPxHKovMOxfu5jM/6EpB9RFpG+9E3388xeE2Fpgw=";
  };

  nativeBuildInputs = [
    guile
    pkg-config
    automake
    autoconf
    makeWrapper
  ];

  postUnpack = ''
    build_dir=`pwd`
    mkdir -p $build_dir
    site_dir=$build_dir/share/guile/site/3.0;
    lib_dir=$build_dir/lib/guile/3.0/site-ccache;
    mkdir -p $site_dir
    mkdir -p $lib_dir
    export GUILE_LOAD_PATH=$site_dir
    export GUILE_LOAD_COMPILED_PATH=$lib_dir
    # for guild compile
    export XDG_CACHE_HOME=$build_dir/cache
    echo "==================="

    echo "install srfi-145"
    mkdir -p $site_dir/srfi
    cp ${srfi}/srfi/srfi-145.scm $site_dir/srfi
    echo "==================="

    echo "install irregex"
    mkdir -p $site_dir/rx/source
    mkdir -p $lib_dir/rx/source
    cp ${irregex}/irregex-guile.scm $site_dir/rx/irregex.scm
    cp ${irregex}/irregex.scm $site_dir/rx/source/irregex.scm
    cp ${irregex}/irregex-utils.scm $site_dir/rx/source/irregex-utils.scm
    guild compile --r7rs $site_dir/rx/irregex.scm -o $lib_dir/rx/irregex.go
    guild compile --r7rs $site_dir/rx/source/irregex.scm -o $lib_dir/rx/source/irregex.go
    echo "==================="

    echo "install srfi-180"
    # guild compile will use relative path
    cd ${srfi}
    mkdir -p $lib_dir/srfi
    cp ${srfi}/srfi/srfi-180.scm $site_dir/srfi
    cp -R ${srfi}/srfi/srfi-180/ $site_dir/srfi
    cp -R ${srfi}/srfi/180/ $site_dir/srfi
    guild compile -x "sld" --r7rs $site_dir/srfi/srfi-180/helpers.sld -o $lib_dir/srfi/srfi-180/helpers.go
    guild compile --r7rs $site_dir/srfi/srfi-180.scm -o $lib_dir/srfi/srfi-180.go
    cd -
    echo "==================="

    echo "install json-rpc"
    mkdir -p $XDG_CACHE_HOME/json-rpc
    cp -r ${json-rpc}/* $XDG_CACHE_HOME/json-rpc
    cd $XDG_CACHE_HOME/json-rpc/guile
    # configure will create file
    chmod -R +w $XDG_CACHE_HOME/json-rpc/guile
    ./configure --prefix=$build_dir
    make
    make install
    cd $build_dir
    mkdir -p $out/lib
    cp -r $build_dir/share $out
    cp -r $build_dir/lib $out
    echo "==================="
  '';

  sourceRoot = "${src.name}/guile";

  configurePhase = ''
    ./configure --prefix=$out --libdir=$out/lib
  '';

  postInstall = ''
    wrapProgram $out/bin/guile-lsp-server \
      --set GUILE_AUTO_COMPILE "0" \
      --set GUILE_LOAD_PATH "$out/share/guile/site/3.0" \
      --set GUILE_LOAD_COMPILED_PATH "$out/lib/guile/3.0/site-ccache" \
      --prefix PATH : ${lib.makeBinPath [ guile ]}
  '';

  meta = with lib; {
    description = "An LSP server for Scheme.";
    homepage = "https://codeberg.org/rgherdt/scheme-lsp-server";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
