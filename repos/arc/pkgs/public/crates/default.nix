{
  rustdoc-stripper = {
    rustPlatform, fetchFromGitHub,
  }: rustPlatform.buildRustPackage rec {
    pname = "rustdoc-stripper";
    version = "0.1.18";
    src = fetchFromGitHub {
      owner = "GuillaumeGomez";
      repo = pname;
      rev = "f6643dd300a71c876625260f190c63a5be41f331";
      sha256 = "01h15sczxgc778avxsk7zakf9sakg7rx9dkjhmq4smx4pr5l033r";
    };

    cargoHash = "sha256-3pcNjNA2/N3sL92l8sX2t/0HUIuVsNZbGpWDjukwcp0=";
  };

  cargo-download-arc = {
    fetchFromGitHub, rustPlatform, lib
  , openssl, pkg-config, hostPlatform, darwin,
  }: rustPlatform.buildRustPackage rec {
    pname = "cargo-download";
    version = "0.1.2";
    src = fetchFromGitHub {
      owner = "Xion";
      repo = pname;
      rev = "b73f6ced56799757945d5bdf2e03df32e9b9ed39";
      sha256 = "1knwxx9d9vnkxib44xircgw1zhwjnf6mlpkcq81dixp3f070yabl";
    };

    nativeBuildInputs = lib.optional hostPlatform.isLinux pkg-config;
    buildInputs = lib.optional hostPlatform.isLinux openssl
      ++ lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;
    cargoHash = "sha256-oH+BBf9R5KHjj4shkngiOafRmMA2YXuC96acCV6VQwU=";
    cargoPatches = [ ./cargo-download-lock.patch ];
  };

  cargo-with = { fetchFromGitHub, rustPlatform }: rustPlatform.buildRustPackage rec {
    pname = "cargo-with";
    version = "0.3.2";
    src = fetchFromGitHub {
      owner = "cbourjau";
      repo = pname;
      rev = "2eb3cbd87f221f24e780b84306574541de38a1e4";
      sha256 = "127ifblgp7v2vv8iafl88y1cjyskymqdi0nzsavnyab0x9jiskcr";
    };

    cargoPatches = [ ./cargo-with-lock.patch ];
    cargoHash = "sha256-7FYQYxUBnLhHcu6WJFfLWCCO7vIUZ7pYnJP/5hUNOx8=";
  };

  cargo-info = {
    fetchFromGitLab, fetchurl, rustPlatform, lib
  , hostPlatform, darwin
  , openssl, pkg-config
  }: rustPlatform.buildRustPackage rec {
    pname = "cargo-info";
    version = "0.7.6";
    src = fetchFromGitLab {
      owner = "imp";
      repo = pname;
      rev = version;
      sha256 = "sha256-02Zkp7Vc1M5iZsG4iJL30S73T2HHg3lqrPJ9mW3FOuk=";
    };

    postPatch = ''
      echo 'pedantic = []' >> Cargo.toml
    '';

    cargoHash = "sha256-zp7qklME28HNGomAcQgrEi7W6zQ1QCJc4FjxtnKySUE=";

    nativeBuildInputs = lib.optional hostPlatform.isLinux pkg-config;
    buildInputs = lib.optional hostPlatform.isLinux openssl
      ++ lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;
  };

  cargo-binutils-unwrapped = {
    fetchFromGitHub, rustPlatform
  }: rustPlatform.buildRustPackage rec {
    pname = "cargo-binutils";
    version = "0.3.2";
    src = fetchFromGitHub {
      owner = "rust-embedded";
      repo = pname;
      rev = "v${version}";
      sha256 = "0h7lrqrgmmm3qdgn0l45kh1rpdvb24q8fl49ji5ynadfk188mkf3";
    };
    cargoPatches = [ ./cargo-binutils-lock.patch ];
    patches = [ ./cargo-binutils-path.patch ];

    cargoHash = "sha256-FPt8DoY4eDd192u4XQinmBQhU1bcWpSK4XaqgBvGdU4=";

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
          --run '[[ -z $CARGO_BUILD_TARGET ]] || set -- --target "$CARGO_BUILD_TARGET" "$@"' \
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
    version = "0.1.15";

    src = fetchFromGitHub {
      owner = "japaric";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-+IommgiXYbZyauoulcDXmss2P2knJg/pyztkf9KELFQ=";
    };

    patches = [
      ./cargo-call-stack-warnings.patch
    ];
    cargoHash = "sha256-2m62LRUh7N9WEWKxpJQU3Ut9D9j8ttDNu03Y+f8I/Lk=";
  };

  cargo-stack-sizes = {
    fetchFromGitHub, rustPlatform
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
    cargoHash = "sha256-6gtANxX+4fg71sDr1UVamRdMvJX6my3jq3/b+Azvk64=";

    doCheck = false; # there are no tests
  };

  cargo-llvm-lines = {
    fetchFromGitHub, rustPlatform
  }: rustPlatform.buildRustPackage rec {
    pname = "cargo-llvm-lines";
    version = "0.4.9";

    src = fetchFromGitHub {
      owner = "dtolnay";
      repo = pname;
      rev = "${version}";
      sha256 = "0lkg1xfabb1psxizbis7rymr70yz5l5rjsn6k7w5wpzqqsni0qyv";
    };

    cargoHash = "sha256-4fHtCw3WdpKoj7rjMLbScDNVU6UyFHS3q/gnxfEi8qg=";
  };

  ladspa-rnnoise = {
    fetchFromGitHub
  , rustPlatform
  , lib
  }: rustPlatform.buildRustPackage rec {
    pname = "ladspa-rnnoise";
    version = "2021-05-24";
    src = fetchFromGitHub {
      owner = "kittywitch";
      repo = "ladspa-rnnoise-rs";
      rev = "b516b4e0790f30a73d3e6ce6e9f9a8fd32cc8e88";
      sha256 = "178056z1z6dybhhbpgr9lyi73az6jp40c2zw104mhwcv9cqbqpis";
    };

    NIX_LDFLAGS = "-u ladspa_descriptor"; # ladspa.rs linker symbol workaround

    postInstall = ''
      install -d $out/lib/ladspa
      mv $out/lib/*.so $out/lib/ladspa/
    '';

    meta.platforms = lib.platforms.linux;

    cargoHash = "sha256-mLdL9OextVhNYJ+8CxLyOdwqBo0j0TN5G9MAmynnnrY=";
  };

  rbw-bitw = {
    fetchFromGitHub
  , rustPlatform
  , makeWrapper
  , pkg-config
  , openssl
  , gnupg, enableGpg ? true
  , lib
  , hostPlatform, darwin
  }: rustPlatform.buildRustPackage rec {
    pname = "rbw-bitw";
    version = "2022-07-10";
    src = fetchFromGitHub {
      owner = "arcnmx";
      repo = "rbw";
      rev = "91b7a0518aeb7bbaefccf848e1610fb760ca09b0";
      sha256 = "sha256-OmZGpAyKjVUqAx/0ZfaRzPUhpoc4IikxWLUGHOS04wo=";
    };

    nativeBuildInputs = [ pkg-config makeWrapper ];
    buildInputs = [ openssl ]
      ++ lib.optional enableGpg gnupg
      ++ lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;

    cargoBuildFlags = ["--bin" "bitw" ];
    cargoHash = "sha256-S1ioEb1/xCtScliXm/uxyeIKUiym2SSi+ziXzABVrYs=";

    postInstall = lib.optionalString enableGpg ''
        wrapProgram $out/bin/bitw \
          --prefix PATH : ${gnupg}/bin
    '';

    doCheck = false;
  };
}
