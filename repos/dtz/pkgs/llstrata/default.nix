{ stdenv, fetchFromGitHub, rustPlatform, llvm, clang, gcc, libffi }:

rustPlatform.buildRustPackage rec {
  name = "llstrata-${version}";
  version = "2017-08-10";
  src = fetchFromGitHub {
    owner = "jcranmer";
    repo = "llstrata";
    rev = "869c980a32b4e4e7b05204a05de5a23aa3e897f4";
    sha256 = "1hk4b3fdjpnq9hvvwwnirq3m0xfcpycxgpz6f5cqiq54r2zya39j";
  };

  buildInputs = [ llvm clang.cc.lib clang libffi ];

  cargoSha256 = "04xad7sa2bkhl1zbfa3i8wfhlpii0kk9zphmgjix0achc77jbha0";

  postUnpack = ''
    cat >> .cargo/config <<EOF
    [source."https://github.com/jcranmer/llvm-rs"]
    git = "https://github.com/jcranmer/llvm-rs"
    branch = "master"
    replace-with = "vendored-sources"
    EOF
  '';
  
  prePatch = ''
    for x in build.rs llvm-mc/build.rs; do
      substituteInPlace $x \
        --replace 'version != "5.0.0svn"' '!version.starts_with("5.0.")'
    done
  '';

  configurePhase = ''
    export LIBCLANG_PATH="${clang.cc.lib}/lib"
    export CC=${gcc}/bin/cc
    export CXX=${gcc}/bin/c++
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Using Strata to generate semantics for mcsema";
    broken = true; # Needs older rust
  };
}
