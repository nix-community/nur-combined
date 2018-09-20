{ stdenv, fetchgit, python2 }:

let
  python = python2;
in stdenv.mkDerivation rec {
  name = "z3-${version}";
  version = "spacer";

  src = fetchgit {
    url = "https://bitbucket.org/spacer/code.git";
    rev = "027d30376543f28d3a5a35e49c72418e42b572ae";
    sha256 = "1sa61z9mzs107dcxcx8mpgd25bdnxldrp35nzi2paywynw2p08c9";
  };

  buildInputs = [ python ];
  enableParallelBuilding = true;

  configurePhase = "${python.interpreter} scripts/mk_make.py --prefix=$out && cd build";

  # z3's install phase is stupid because it tries to calculate the
  # python package store location itself, meaning it'll attempt to
  # write files into the nix store, and fail.
  soext = if stdenv.system == "x86_64-darwin" then ".dylib" else ".so";
  installPhase = ''
    mkdir -p $out/bin $out/${python.sitePackages} $out/include
    cp ../src/api/z3*.h       $out/include
    cp ../src/api/c++/z3*.h   $out/include
    cp z3                     $out/bin
    cp libz3${soext}          $out/lib
    cp libz3${soext}          $out/${python.sitePackages}
    cp z3*.pyc                $out/${python.sitePackages}
    cp ../src/api/python/*.py $out/${python.sitePackages}
  '';

  passthru.src = src;

  meta = {
    description = "A high-performance theorem prover and SMT solver, SPACER edition!";
    license     = stdenv.lib.licenses.mit;
    platforms   = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ thoughtpolice sheganinans dtzWill ];
  };
}
