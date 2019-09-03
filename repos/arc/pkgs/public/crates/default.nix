{
  rust-analyzer = { fetchFromGitHub, rustPlatform, lib, darwin, hostPlatform }: rustPlatform.buildRustPackage rec {
    pname = "rust-analyzer";
    version = "4647e89defd367a92d00d3bbb11c2463408bb3ad";
    src = fetchFromGitHub {
      owner = "rust-analyzer";
      repo = pname;
      rev = version;
      sha256 = "1m3v5fwvqapd61llzbinji62s029kfwrfl24wbls59v3x816b23b";
    };
    cargoBuildFlags = ["--features" "jemalloc" "-p" "ra_lsp_server"];
    buildInputs = lib.optionals hostPlatform.isDarwin [ darwin.cf-private darwin.apple_sdk.frameworks.CoreServices ];
    # darwin undefined symbol _CFURLResourceIsReachable: https://discourse.nixos.org/t/help-with-rust-linker-error-on-darwin-cfurlresourceisreachable/2657

    cargoSha256 = "0f0vpbczysb1mhcdq6rva9k5w3jy65zqshzm04bmrs0glibdnhci";
    meta.broken = lib.versionAtLeast "1.36.0" rustPlatform.rust.rustc.version;

    doCheck = false;
  };
  cargo-binutils-unwrapped = {
    lib, fetchFromGitHub, rustPlatform
  }: rustPlatform.buildRustPackage rec {
    pname = "cargo-binutils";
    version = "3d1d4a83a49f890a604c1c75d712402e6f457bff";
    src = fetchFromGitHub {
      owner = "rust-embedded";
      repo = pname;
      rev = version;
      sha256 = "14fkgfx9jbadm119f962yy46lbln7c42myrpapxw94nhrlw71h7n";
    };
    cargoPatches = [ ./cargo-binutils-lock.patch ];
    patches = [ ./cargo-binutils-path.patch ];

    cargoSha256 = if lib.isNixpkgsStable
      then "1lqdcjwfndak59i89rzb1bfyc4p0644ahyyi6mvbll3p5h6h47gj"
      else "0cvsw06r174xc5zn04glcvlc2ckjj32y7bs8qk1wicm28nkq71qp";

    doCheck = false;

    postInstall = ''
      rm $out/bin/rust-*
    '';
  };
  cargo-binutils = {
    cargo-binutils-unwrapped, makeWrapper
  , stdenvNoCC, stdenv, bintools ? stdenv.cc.bintools.bintools
  }: stdenvNoCC.mkDerivation {
    pname = "cargo-binutils-wrapper";
    inherit (cargo-binutils-unwrapped) version;

    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ cargo-binutils-unwrapped ];

    # $bintools/bin should contain: ar, nm, objcopy, objdump, profdata, readobj/readelf, size, strip
    cargoBinutils = cargo-binutils-unwrapped;
    inherit bintools;
    buildCommand = ''
      mkdir -p $out
      for binary in $cargoBinutils/bin/cargo-*; do
        makeWrapper $binary $out/bin/$(basename $binary) \
          --run '[[ -z $CARGO_BUILD_TARGET ]] || extraFlagsArray+=(--target $CARGO_BUILD_TARGET)' \
          --prefix PATH : $bintools/bin
      done
      if [[ -e $bintools/bin/readelf && ! -e $bintools/bin/readobj ]]; then
        ln -s $bintools/bin/readelf $out/bin/readobj
      fi
    '';
  };

  cargo-call-stack = {
    lib, fetchFromGitHub, rustPlatform
  }: rustPlatform.buildRustPackage rec {
    pname = "cargo-call-stack";
    version = "0.1.3";

    src = fetchFromGitHub {
      owner = "japaric";
      repo = pname;
      rev = "v${version}";
      sha256 = "0bbkvxb0y8czidvmsrnk46gm7r8da7cckdbkwxwby2bcvv2fg812";
    };

    cargoPatches = [ ./cargo-call-stack-lock.patch ];
    patches = [ ./cargo-call-stack-intrinsics.patch ];
    cargoSha256 = if lib.isNixpkgsStable
      then "1ssb5kwjmiwnzsxpc9581vmv77xrycvxpjb42gm3hj8vnhlqc2ml"
      else "0wwdyzavq2x9iand65nzrabn7hlv36ygvrmr3996dxc90k7jg7v9";

    meta.broken = !lib.rustVersionAtLeast rustPlatform "1.33";
  };

  cargo-stack-sizes = {
    lib, fetchFromGitHub, rustPlatform
  }: rustPlatform.buildRustPackage rec {
    pname = "stack-sizes";
    version = "0.4.0";

    src = fetchFromGitHub {
      owner = "japaric";
      repo = pname;
      rev = "v${version}";
      sha256 = "0k260hkv734zwwwz5r93zriimrg13v4h0cmhmqf5a4svkns8z06h";
    };

    cargoPatches = [ ./cargo-stack-sizes-lock.patch ];
    patches = [ ./cargo-stack-sizes-warn.patch ./cargo-stack-sizes-features.patch ];
    cargoSha256 = if lib.isNixpkgsStable
      then "0ph5lhxk01rn68jk7981r61pi1wfhrzrv6h4a0h2cndg3n93vg1x"
      else "1zmfa7s0zcwkkqfqk2svashl9a0mnpscyn1p9ds9k423r52gifwk";

    doCheck = false; # there are no tests
  };
}
