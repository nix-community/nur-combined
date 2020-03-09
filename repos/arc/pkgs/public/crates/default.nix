{
  rust-analyzer = { fetchFromGitHub, rustPlatform, lib, darwin, hostPlatform }: rustPlatform.buildRustPackage rec {
    pname = "rust-analyzer";
    version = "2020-03-09";
    src = fetchFromGitHub {
      owner = "rust-analyzer";
      repo = pname;
      rev = version;
      sha256 = "1m97sinfyg43p3crhbjrsgf64bn5pyj7m96ikvznps80w8dnsv5n";
    };
    cargoBuildFlags = ["--features" "jemalloc" ];
    preBuild = "pushd crates/rust-analyzer";
    postBuild = "popd";

    buildInputs = lib.optionals hostPlatform.isDarwin [ darwin.cf-private darwin.apple_sdk.frameworks.CoreServices ];
    # darwin undefined symbol _CFURLResourceIsReachable: https://discourse.nixos.org/t/help-with-rust-linker-error-on-darwin-cfurlresourceisreachable/2657

    cargoSha256 = "1iisny73l0qflbwz0s9yiqzb6k5srm39knccs21hfqwq8srpv50h";
    legacyCargoFetcher = true;
    meta.broken = lib.versionAtLeast "1.38.0" rustPlatform.rust.rustc.version;

    doCheck = false;
  };

  cargo-deps = { fetchFromGitHub, rustPlatform, lib }: rustPlatform.buildRustPackage rec {
    pname = "cargo-deps";
    version = "1.3.0";
    src = fetchFromGitHub {
      owner = "m-cat";
      repo = pname;
      rev = "9f2344b";
      sha256 = "0d4gy78jyibwnga3g5xr354gy2r23nb26lcwa05nd0kmwsdkb6cq";
    };

    cargoSha256 = "0nxmr8b3j7p08bvdm1b3ql7wnsyfg3qzd5m0zjs5l7f0gzbz6471";
    legacyCargoFetcher = true;
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
    cargoSha256 = "1ak0idi1wlwndw5rsp9ff1l3j05hf26h06rjs2ldfh09rss4s54b";
    legacyCargoFetcher = true;
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
    cargoSha256 = "0x08nc9d6jgrfnlrnyrln2lvxr7dpys4sfh2lvq0814bfg22byid";
    legacyCargoFetcher = true;
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
    cargoSha256 = "1fw8fd67ixhy13xvfkssssy5b78n5dgq4qr0m0xvi50i2553rlgj";
    legacyCargoFetcher = true;

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
    cargoSha256 = "0cmdi9dcdn2nzk1h5n764305h9nzk5qzzjwgq1k86mxsn49i5w8c";
    legacyCargoFetcher = true;

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
    version = "3d1d4a83a49f890a604c1c75d712402e6f457bff";
    src = fetchFromGitHub {
      owner = "rust-embedded";
      repo = pname;
      rev = version;
      sha256 = "14fkgfx9jbadm119f962yy46lbln7c42myrpapxw94nhrlw71h7n";
    };
    cargoPatches = [ ./cargo-binutils-lock.patch ];
    patches = [ ./cargo-binutils-path.patch ];

    cargoSha256 = "0cvsw06r174xc5zn04glcvlc2ckjj32y7bs8qk1wicm28nkq71qp";
    legacyCargoFetcher = true;

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
    version = "0.1.4";

    src = fetchFromGitHub {
      owner = "japaric";
      repo = pname;
      rev = "v${version}";
      sha256 = "0ccskajkikkkmxc6bd60kj5mxwdfyw5wbrnvc35y9r0g2k7r5f9m";
    };

    cargoPatches = [ ./cargo-call-stack-lock.patch ];
    patches = [
      ./cargo-call-stack-udf.patch # https://github.com/japaric/cargo-call-stack/issues/20
    ];
    cargoSha256 = "0ih8z2jkvjs9krsqkpc353charqymlz65kf78n7x304p2i9jbwxx";
    legacyCargoFetcher = true;

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
    cargoSha256 = "1zmfa7s0zcwkkqfqk2svashl9a0mnpscyn1p9ds9k423r52gifwk";
    legacyCargoFetcher = true;

    doCheck = false; # there are no tests
  };

  cargo-llvm-lines = {
    lib, fetchFromGitHub, rustPlatform
  }: rustPlatform.buildRustPackage rec {
    pname = "cargo-llvm-lines";
    version = "0.1.6";

    src = fetchFromGitHub {
      owner = "dtolnay";
      repo = pname;
      rev = "${version}";
      sha256 = "0g3vb8zicz8ib6ydjl5vn5lijfx6z61ips60x1zfhyx8h44xp7v5";
    };

    cargoPatches = [ ./cargo-llvm-lines-lock.patch ];
    patches = [ ./cargo-llvm-lines-features.patch ./cargo-llvm-lines-fix-filter.patch ];
    cargoSha256 = "0arjrs67z9rqbkrs77drj068614kg2n3y4f1wyf103bsad0vy783";
    legacyCargoFetcher = true;
  };

  screenstub = {
    fetchFromGitHub
  , rustPlatform
  , lib
  , makeWrapper
  , qemucomm ? arc'private.qemucomm, arc'private ? null
  , libxcb
  , python3
  , ddcutil
  }: let
    ddcutil_0_8 = ddcutil.overrideAttrs (old: rec {
      version = "0.8.6";
      src = fetchFromGitHub {
        owner = "rockowitz";
        repo = "ddcutil";
        rev = "v${version}";
        sha256 = "1c4cl9cac90xf9rap6ss2d4yshcmhdq8pdfjz3g4cns789fs1vcf";
      };
      NIX_CFLAGS_COMPILE = toString [
        "-Wno-error=format-truncation"
        "-Wno-error=format-overflow"
        "-Wno-error=stringop-truncation"
      ];
      enableParallelBuilding = true;
    });
  in rustPlatform.buildRustPackage rec {
    pname = "screenstub";
    version = "2018-03-13";
    src = fetchFromGitHub {
      owner = "arcnmx";
      repo = pname;
      rev = "4fb8b12";
      sha256 = "0d5vvj7dyp664c302n9jh5rcwlfwnlnshdj1k4jb83pfx91dlvh8";
    };

    nativeBuildInputs = [ python3 makeWrapper ];
    buildInputs = [ libxcb ddcutil_0_8 ];
    depsPath = lib.makeBinPath [ qemucomm ];

    cargoSha256 = "047nwakmz01yvz92wyfvz6w1867j9279njj75kjsanajm7nybdw1";
    legacyCargoFetcher = true;

    postInstall = ''
      wrapProgram $out/bin/screenstub --prefix PATH : $depsPath
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
  }: rustPlatform.buildRustPackage rec {
    pname = "wezterm";
    version = "2020-01-29";
    src = fetchFromGitHub {
      owner = "wez";
      repo = pname;
      rev = "5f2f359";
      sha256 = "174kvxyc5jbhhapd6pvkc9mvvrjy5kdg165wvnnb8hzgfxjyjqqf";
      fetchSubmodules = true;
    };

    cargoSha256 = "1z2gqlg2pdfq9hlj4p7ngv29ijxfcld41v44g08jf6lwz81lh1bs";
    legacyCargoFetcher = true;
    cargoPatches = [
      # full of hacks around optional/platform-specific dependencies, split this up to fix the macos build
      ./wezterm-lock.patch
    ];

    nativeBuildInputs = [ pkgconfig python3 autoPatchelfHook ];
    buildInputs = [
      dbus libX11 libxcb openssl wayland libxkbcommon xcbutilkeysyms xcbutilwm fontconfig
    ];
    runtimeDependencies = [ libGL ];

    doCheck = false;

    meta = {
      broken = lib.versionAtLeast "1.38.0" rustPlatform.rust.rustc.version;
      platforms = lib.platforms.linux;
    };
  };
}
