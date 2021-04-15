{
  rust-analyzer = { fetchFromGitHub, rustPlatform, lib, darwin, hostPlatform }: rustPlatform.buildRustPackage rec {
    pname = "rust-analyzer";
    version = "2021-03-15";
    src = fetchFromGitHub {
      owner = "rust-analyzer";
      repo = pname;
      rev = version;
      sha256 = "150gydm0mg72bbhgjjks8qc5ldiqyzhai9z4yfh4f1s2bwdfh3yf";
    };
    #cargoBuildFlags = ["--features" "jemalloc" ]; # why removed :(
    preBuild = "pushd crates/rust-analyzer";
    postBuild = "popd";

    buildInputs = lib.optionals hostPlatform.isDarwin [ darwin.cf-private darwin.apple_sdk.frameworks.CoreServices darwin.libiconv ];
    # darwin undefined symbol _CFURLResourceIsReachable: https://discourse.nixos.org/t/help-with-rust-linker-error-on-darwin-cfurlresourceisreachable/2657

    cargoSha256 = if lib.isNixpkgsUnstable
      then "0s7ihdjbm68xr7fq1lykxjk0vy6xd4qwa64pmikj04a3n30djhfx"
      else "10hk6argjqdl0wvgadfafc049b1ny6qk0rlp621ik5j8yicsgj4q";
    meta.broken = ! lib.versionAtLeast rustPlatform.rust.rustc.version "1.46.0";

    doCheck = false;
  };

  cargo-download-arc = {
    fetchFromGitHub, rustPlatform, lib
  , openssl, pkgconfig, hostPlatform, darwin,
  }: rustPlatform.buildRustPackage rec {
    pname = "cargo-download";
    version = "0.1.2";
    src = fetchFromGitHub {
      owner = "Xion";
      repo = pname;
      rev = "b73f6ced56799757945d5bdf2e03df32e9b9ed39";
      sha256 = "1knwxx9d9vnkxib44xircgw1zhwjnf6mlpkcq81dixp3f070yabl";
    };

    nativeBuildInputs = lib.optional hostPlatform.isLinux pkgconfig;
    buildInputs = lib.optional hostPlatform.isLinux openssl
      ++ lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;
    cargoSha256 = if lib.isNixpkgsUnstable
      then "1bgiwnppbhrhx376fba4bqh1bhick80zrknwnw0qz425vxhffl5k"
      else "1q62rk253nmvvgw8ksf8nvlc1g0ynzqkk3w35wa2iiral7wnfj2r";
    cargoPatches = [ ./cargo-download-lock.patch ];
  };

  cargo-with = { fetchFromGitHub, rustPlatform, lib }: rustPlatform.buildRustPackage rec {
    pname = "cargo-with";
    version = "0.3.2";
    src = fetchFromGitHub {
      owner = "cbourjau";
      repo = pname;
      rev = "2eb3cbd87f221f24e780b84306574541de38a1e4";
      sha256 = "127ifblgp7v2vv8iafl88y1cjyskymqdi0nzsavnyab0x9jiskcr";
    };

    cargoPatches = [ ./cargo-with-lock.patch ];
    cargoSha256 = if lib.isNixpkgsUnstable
      then "07rv1laydzwkkicblrqlybp8w82qrdbj95pff93vi7012mii0mpc"
      else "0mvyimwqxg5i9m29ikzfl9dzbjsp1ksjkpxc794xnn7c0lspa2gi";
  };

  cargo-info = {
    fetchFromGitLab, fetchurl, rustPlatform, lib
  , hostPlatform, darwin
  , openssl, pkgconfig
  }: rustPlatform.buildRustPackage rec {
    pname = "cargo-info";
    version = "0.5.14";
    src = fetchFromGitLab {
      owner = "imp";
      repo = pname;
      rev = version;
      sha256 = "0gpzcfw607wfb1pv8z46yk4l2rx6pn64mhw5jrj7x8331vl2dvwv";
    };

    cargoPatches = [ (fetchurl {
      # https://gitlab.com/imp/cargo-info/merge_requests/6
      # NOTE: there's also https://gitlab.com/imp/cargo-info/merge_requests/7 which is about equivalent?
      name = "update-deps.patch";
      url = "https://gitlab.com/imp/cargo-info/commit/635a128a9e46ee9f3c443ed070da63b3ebb78033.diff";
      sha256 = "14vz860a40njx4fdaxdw1iy92isihgab65x5c6kxb68iha6bg4j9";
    }) ];
    cargoSha256 = if lib.isNixpkgsUnstable
      then "1fvdpx60v3cv07b9vzybki519x10xgmm65bj5a57gjg6vii3ywfd"
      else "0pzync67crq9raw78yyvsj5b2vflpvb17p5fwn5f5mwgfqj82dvi";

    nativeBuildInputs = lib.optional hostPlatform.isLinux pkgconfig;
    buildInputs = lib.optional hostPlatform.isLinux openssl
      ++ lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;
  };

  xargo-unwrapped = { fetchFromGitHub, rustPlatform, lib }: rustPlatform.buildRustPackage rec {
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
    cargoSha256 = if lib.isNixpkgsUnstable
      then "1y0l5mi1pvq9h9mgvig2qyam49ij33p5lr8ww0qypdg1r8kslhsa"
      else "17afazmggwlnd6cs43cbj8hghc2ddlka517vjrpiqgcw1vx4h7qw";

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
    lib, fetchFromGitHub, rustPlatform
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

    cargoSha256 = if lib.isNixpkgsUnstable
      then "0kkmqqdq1aknw6598nnwar9j254qlw45vf3byxskfy1qhq77ryql"
      else "0z13mlgnl0rs6a6yczdkwxym1iss2jmz85cf7g0yah4z44ff74a4";

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
    version = "2020-07-07";

    src = fetchFromGitHub {
      owner = "japaric";
      repo = pname;
      rev = "d8f4338adb4c8cc3dfaeba22b1a4d5d22168cb17";
      sha256 = "1sdskiykx9bvnr8dny1dg138cm6m8zhvs8n25lksg2s34xdjzh3c";
    };

    cargoPatches = [ ./cargo-call-stack-lock.patch ];
    patches = [
      ./cargo-call-stack-udf.patch # https://github.com/japaric/cargo-call-stack/issues/20
    ];
    cargoSha256 = if lib.isNixpkgsUnstable
      then "0pj6skdbmwwp49yin4fx4finbpkjhn4w904lk2s0ik17klrvmm5j"
      else "14x1m7mm4bhndp9ifgzkv7ri25vj7xfjqc85k67p841rsbncwkw3";

    # Only because of the cargo lockfile version...
    meta.broken = !lib.rustVersionAtLeast rustPlatform "1.41";
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
    cargoSha256 = if lib.isNixpkgsUnstable
      then "1blkxw6ginvzmgijv6zsjny4q5wrb92xbsy0sqxziqgy2lvl02za"
      else "1lnplkxapxl84cbrrhi0hs875d9v7mdgqj719177xy86nywsmwba";

    doCheck = false; # there are no tests
  };

  cargo-llvm-lines = {
    lib, fetchFromGitHub, rustPlatform
  }: rustPlatform.buildRustPackage rec {
    pname = "cargo-llvm-lines";
    version = "0.4.9";

    src = fetchFromGitHub {
      owner = "dtolnay";
      repo = pname;
      rev = "${version}";
      sha256 = "0lkg1xfabb1psxizbis7rymr70yz5l5rjsn6k7w5wpzqqsni0qyv";
    };

    cargoSha256 = if lib.isNixpkgsUnstable
      then "1a7j4bqwa9zqmfvp851jlm9macvhsav31qxsiyl94xnn1l5yvwg1"
      else "04s2lv0idlfssmsavyac1jy57x8f14nqlr1n552cn1pi78d4wnfr";
  };

  screenstub = {
    fetchFromGitHub
  , rustPlatform
  , pkg-config
  , lib
  , libxcb
  , udev
  , python3
  }: rustPlatform.buildRustPackage rec {
    pname = "screenstub";
    version = "2021-01-08";
    src = fetchFromGitHub {
      owner = "arcnmx";
      repo = pname;
      rev = "20c0aa961fa92c00ac4d722337c55b5cbace3675";
      sha256 = "1q0z685pq225pgrids2x2pgb9wl3m6022333srka994vf6p3d8yk";
    };

    nativeBuildInputs = [ pkg-config python3 ];
    buildInputs = [ libxcb udev ];

    cargoSha256 = if lib.isNixpkgsUnstable
      then "0i8d9pg95k9vlvyz0z8gbz3qylm05gx8jrn5xyqwj9lsp66n07ph"
      else "0w0mvj4rig3sjxyndmyl7135qdakf1dajsg4fwa08xjawfcywzwl";

    doCheck = false;
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
    version = "2020-10-05";
    src = fetchFromGitHub {
      owner = "arcnmx";
      repo = "rbw";
      rev = "d34a3347b5b3184d163111e1c925e687c7cbabc1";
      sha256 = "058wda5z2zwxn4xxqqxi8ms49v2bx7hxqh2hpxs59ypx676x61b6";
    };

    nativeBuildInputs = [ pkg-config makeWrapper ];
    buildInputs = [ openssl ]
      ++ lib.optional enableGpg gnupg
      ++ lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;

    cargoBuildFlags = ["--bin" "bitw" ];
    cargoSha256 = if lib.isNixpkgsUnstable
      then "1qs09dqyfxyxlvf98rsvvjxvf4r1dcp84siwbj1q9pch0aaf4gjr"
      else "1byz66ral9ir9k7dwnvq2x9s7wrab6q0siq88vmlmijdw82sacjp";

    postInstall = lib.optionalString enableGpg ''
        wrapProgram $out/bin/bitw \
          --prefix PATH : ${gnupg}/bin
    '';

    doCheck = false;
  };

  wezterm = {
    lib
  , fetchFromGitHub
  , autoPatchelfHook
  , rustPlatform
  , pkgconfig
  , python3
  , dbus
  , fontconfig
  , openssl
  , libxkbcommon
  , libX11
  , libxcb
  , xcbutilkeysyms
  , xcbutilwm
  , wayland
  , libGL
  , luajit
  }: rustPlatform.buildRustPackage rec {
    pname = "wezterm";
    version = "20201101-103216-403d002d";
    src = fetchFromGitHub {
      owner = "wez";
      repo = pname;
      rev = version;
      sha256 = "16hcczzhwf507vp2qh4fmlkzcw13nzjk6h33q4qn0sxwspb011gm";
      fetchSubmodules = true;
    };

    cargoSha256 = if lib.isNixpkgsUnstable
      then "1qlgn8437jnak1rpnapvqmbn4b5v2kwaf4fnkbxylg7n6m4fw9gl"
      else "0cs618v2k1fpdi8vqv1w5zqciay6vxws3rrgh1nnw6wsd2rcs631";
    cargoPatches = [
      # full of hacks around optional/platform-specific dependencies, split this up to fix the macos build
      ./wezterm-lock.patch
    ];

    nativeBuildInputs = [ pkgconfig python3 autoPatchelfHook ];
    buildInputs = [
      dbus libX11 libxcb openssl wayland libxkbcommon xcbutilkeysyms xcbutilwm fontconfig luajit
    ];
    runtimeDependencies = [ libGL ];

    doCheck = false;

    meta = {
      broken = ! lib.versionAtLeast rustPlatform.rust.rustc.version "1.46.0";
      platforms = lib.platforms.linux;
    };
  };
}
