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

    cargoSha256 = "17bj63lqx0wm39dxdc4mid80gzdpyv2z59fx5zndvz1ns260v5yy";
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
    cargoSha256 = "sha256-oH+BBf9R5KHjj4shkngiOafRmMA2YXuC96acCV6VQwU=";
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
    cargoSha256 = "07rv1laydzwkkicblrqlybp8w82qrdbj95pff93vi7012mii0mpc";
  };

  cargo-info = {
    fetchFromGitLab, fetchurl, rustPlatform, lib
  , hostPlatform, darwin
  , openssl, pkg-config
  }: rustPlatform.buildRustPackage rec {
    pname = "cargo-info";
    version = "0.7.3";
    src = fetchFromGitLab {
      owner = "imp";
      repo = pname;
      rev = version;
      sha256 = "sha256-m8YytirD9JBwssZFO6oQ9TGqjqvu1GxHN3z8WKLiKd4=";
    };

    cargoSha256 = "sha256-gI/DGPCVEi4Mg9nYLaPpeqpV7LBbxoLP0ditU6hPS1w=";

    nativeBuildInputs = lib.optional hostPlatform.isLinux pkg-config;
    buildInputs = lib.optional hostPlatform.isLinux openssl
      ++ lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;
  };

  xargo-unwrapped = { fetchFromGitHub, rustPlatform }: rustPlatform.buildRustPackage rec {
    pname = "xargo";
    version = "0.3.16";
    src = fetchFromGitHub {
      owner = "japaric";
      repo = pname;
      rev = "v${version}";
      sha256 = "019s7jd7k8r1r0iwd40113c56sfifrzz8i4lwh75n0fpnalpcnyb";
    };

    RUSTC_BOOTSTRAP = true;

    patches = [ ./xargo-stable.patch ];
    cargoSha256 = "1y0l5mi1pvq9h9mgvig2qyam49ij33p5lr8ww0qypdg1r8kslhsa";

    doCheck = false;
  };

  xargo = { stdenvNoCC, xargo-unwrapped, makeWrapper, rustPlatform, rustc, cargo, rustcSrc ? rustPlatform.rustcSrc }: stdenvNoCC.mkDerivation {
    inherit (xargo-unwrapped) pname version;
    xargo = xargo-unwrapped;
    inherit rustcSrc rustc cargo;

    nativeBuildInputs = [ makeWrapper ];

    buildCommand = ''
      mkdir -p $out/bin
      makeWrapper $xargo/bin/xargo $out/bin/xargo \
        --set-default XARGO_RUST_SRC "$rustcSrc" \
        --set-default CARGO "$cargo/bin/cargo" \
        --set-default RUSTC "$rustc/bin/rustc"
    '';
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

    cargoSha256 = "0kkmqqdq1aknw6598nnwar9j254qlw45vf3byxskfy1qhq77ryql";

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
    version = "0.1.6";

    src = fetchFromGitHub {
      owner = "japaric";
      repo = pname;
      rev = "v${version}";
      sha256 = "00ka0yx3114wmpngs44fv2j3r6jxh1v1w9kzzmbklynpi3wmb65b";
    };

    cargoPatches = [ ./cargo-call-stack-lock.patch ];
    patches = [
      ./cargo-call-stack-udf.patch # https://github.com/japaric/cargo-call-stack/issues/20
    ];
    cargoSha256 = "14qdz805z5h9vryrjcy3vsqcaic8fh9f4x60pvbkbv3r2bz072vc";
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
    cargoSha256 = "1blkxw6ginvzmgijv6zsjny4q5wrb92xbsy0sqxziqgy2lvl02za";

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

    cargoSha256 = "1a7j4bqwa9zqmfvp851jlm9macvhsav31qxsiyl94xnn1l5yvwg1";
  };

  screenstub = {
    fetchFromGitHub
  , rustPlatform
  , pkg-config
  , libxcb
  , udev
  , python3
  }: rustPlatform.buildRustPackage rec {
    pname = "screenstub";
    version = "2021-09-09";
    src = fetchFromGitHub {
      owner = "arcnmx";
      repo = pname;
      # xinput branch
      rev = "1e2e121f18d6f5e0ea18fe94e8a95feb87955e25";
      sha256 = "02s33msf9dx9qrry42dnsn19chjqkxvvf9329zpxayw6rmjbzzmr";
    };

    nativeBuildInputs = [ pkg-config python3 ];
    buildInputs = [ libxcb udev ];

    cargoSha256 = "02lyv08p78bvq5yss5fb1c5g1b4j9g331jr19dx18r06g4lsj9ja";

    doCheck = false;
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

    cargoSha256 = "1dlywwlrn06k3dwk7l93il32mp1ry890pg4zc16middiwzs4pdwq";
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
    cargoSha256 = "sha256-S1ioEb1/xCtScliXm/uxyeIKUiym2SSi+ziXzABVrYs=";

    postInstall = lib.optionalString enableGpg ''
        wrapProgram $out/bin/bitw \
          --prefix PATH : ${gnupg}/bin
    '';

    doCheck = false;
  };
}
