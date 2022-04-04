{ pkgs ? import <nixpkgs> {} }:
with pkgs;

((rustPlatform.buildRustPackage.override {
  stdenv = clangStdenv;
  # should work too.
  }) rec {
  name = "grin-miner-${version}";
  version = "0.5.2";
  buildInputs = [ ncurses cmake zlib openssl pkgconfig ];

  # Compiling "cuckoo_miner" fails with the following if we don't disable format hardening
  # cc1plus: error: -Wformat-security ignored without -Wformat [-Werror=format-security]
  hardeningDisable = [ "format" ];

  srcGitHub = fetchFromGitHub {
    owner = "mimblewimble";
    repo = "grin-miner";
    rev = "a9e4fd1fcbf173d60a97e4265f3ec7ebc5cd64f3";
    sha256 = "0kqz77x4r06dgy7zykmfy50ilk2kqq8h8b14lrv2dm81l76hv0v0";
    fetchSubmodules = true;
  };
  src = if builtins.pathExists ./src/grin-miner then srcLocal else srcGitHub;

  cargoSha256 = "053711lsgi6zhgq7a2h4mkrxymws66c8g5y60hpifz5x1sxcgiiw";

  # kill all AVX enabled build artifacts
  postUnpack = ''
    (cd source; patch -p1 < ${./grin-miner.diff})
  '';

  # Add plugins to output
  postInstall = "cp -a target/release/plugins $out/bin";

  meta = {
    description = "Grin Mimblewimble miner";
    homepage = https://grin-tech.org/;
    license = lib.licenses.asl20;
    broken = true;
  };
})
