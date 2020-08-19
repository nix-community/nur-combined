{
  kak-crosshairs = { fetchFromGitHub, buildKakPlugin }: buildKakPlugin rec {
    pname = "kak-crosshairs";
    version = "e191f6a4905ba29b1af76d96e4cf38127f93eebb";
    src = fetchFromGitHub {
      owner = "insipx";
      repo = pname;
      rev = version;
      sha256 = "14akcga20qb1dyr547xk4rpncc0724vd0krr7q19rp3g4cb0fn5p";
    };
  };
  fzf-kak = { fetchFromGitHub, buildKakPlugin }: buildKakPlugin rec {
    pname = "fzf.kak";
    version = "1.0.1";
    src = fetchFromGitHub {
      owner = "andreyorst";
      repo = pname;
      rev = "v${version}";
      sha256 = "0zdgrgz53cdxxga1n5hg3ggbmch5rdy4298v58dsqw41mn6697dr";
    };
  };
  kakoune-registers = { fetchFromGitHub, buildKakPlugin }: buildKakPlugin rec {
    pname = "kakoune-registers";
    version = "e7f7ccef5eade5030a6ef9dce3d3516d4f79e7ac";
    src = fetchFromGitHub {
      owner = "Delapouite";
      repo = pname;
      rev = version;
      sha256 = "1rwczb2yhyd01qj9bbzglh980jvy172i9p32kqmm9axpkhlbrzpc";
    };
  };
  explore-kak = { fetchFromGitHub, buildKakPlugin }: buildKakPlugin rec {
    pname = "explore.kak";
    version = "d6f5d68d009c19fd99fc22b3c7c8914b262db2d0";
    src = fetchFromGitHub {
      owner = "alexherbo2";
      repo = pname;
      rev = version;
      sha256 = "10gkjhwv2nvhh2ci89z51daskiaz0nvy25v1nwpzvhqm14d8jd81";
    };
  };
  kak-tree = { fetchFromGitHub, rustPlatform, buildKakPluginFrom2Nix, lib, darwin, hostPlatform }: buildKakPluginFrom2Nix rec {
    mkDerivation = rustPlatform.buildRustPackage;
    kakInstall = false;

    kakrc = "share/kak/autoload/tree.kak";
    pname = "kak-tree";
    version = "2020-01-21";
    src = fetchFromGitHub {
      owner = "ul";
      repo = pname;
      rev = "2fa4b122a06c6b8b802329a66e2a59ddf00e8372";
      sha256 = "17n0g9dljz700f1qd5qa4ps78mbzl24ai2zv549knv57ig09g5k5";
      fetchSubmodules = true;
    };

    buildInputs = lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;

    cargoSha256 = if lib.isNixpkgsStable
      then "0n3j2d15m039cl3fn5ibk4kyk1hnawhwbkinph50ry4pzhix3ikb"
      else "0d7k7c8gq5b9blxxz0xzj1w51x6vqvrb3ac3azhvbl3xf55z6gl4";

    preBuild = ''
      sed -e "s,\"kak-tree\",\"$out/bin/kak-tree\"," -i rc/tree.kak
    '';

    postInstall = ''
      install -Dm0644 rc/tree.kak $out/$kakrc
    '';

    passthru.ci.skip = hostPlatform.isDarwin;
  };
  kak-lsp = { fetchFromGitHub, rustPlatform, buildKakPluginFrom2Nix, lib, darwin, hostPlatform }: buildKakPluginFrom2Nix rec {
    mkDerivation = rustPlatform.buildRustPackage;
    kakInstall = false;

    pname = "kak-lsp";
    version = "7.0.0";
    src = fetchFromGitHub {
      owner = "ul";
      repo = pname;
      rev = "v${version}";
      sha256 = "1b9v417g0z9q1sqgnms5vy740xggg4fcz0fdwbc4hfvfj6jkyaad";
    };

    buildInputs = lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;

    cargoSha256 = if lib.isNixpkgsStable
      then "0kzrrphlilnyl79yfmlvd6an8iyi8zcs0inwiq74z383lnbdpk7q"
      else "1cmms8kvh24sjb0w77i1bwl09wkx3x65p49pkg1j0lipwic3apm3";

    defaultConfig = "share/kak/kak-lsp.toml";
    kakrc = "share/kak/autoload/kak-lsp.kak";

    postInstall = ''
      install -Dm0644 kak-lsp.toml $out/$defaultConfig

      cat > kakrc <<EOF
      eval %sh{$out/bin/kak-lsp --kakoune -s \$kak_session}
      EOF
      install -Dm0644 kakrc $out/$kakrc
    '';

    passthru.ci.skip = hostPlatform.isDarwin;
  };
}
