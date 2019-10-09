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
    version = "16a7d44d6c00cec9023eb4043a3faeeac5054270";
    src = fetchFromGitHub {
      owner = "ul";
      repo = pname;
      rev = version;
      sha256 = "1wwpxq87plyxpkfwgy5lnadiv69h7jd7xwaclhck6f2yjkxmswjm";
      fetchSubmodules = true;
    };

    buildInputs = lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;

    cargoSha256 = "1hqnxjn898kpi850m3qz361hkkhjkhr5j4gk828isqlwl8q75dpr";

    preBuild = ''
      sed -e "s,\"kak-tree\",\"$out/bin/kak-tree\"," -i rc/tree.kak
    '';

    postInstall = ''
      install -Dm0644 rc/tree.kak $out/$kakrc
    '';
  };
  kak-lsp = { fetchFromGitHub, rustPlatform, buildKakPluginFrom2Nix, lib, darwin, hostPlatform }: buildKakPluginFrom2Nix rec {
    mkDerivation = rustPlatform.buildRustPackage;
    kakInstall = false;

    pname = "kak-lsp";
    version = "6.2.1";
    src = fetchFromGitHub {
      owner = "ul";
      repo = pname;
      rev = "v${version}";
      sha256 = "0bazbz1g5iqxlwybn5whidvavglvgdl9yp9qswgsk1jrjmcr5klx";
    };

    buildInputs = lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;

    cargoSha256 = "0w0mnh8fnl8zi9n0fxzqaqbvmfagf3ay5v2na3laxb72jm76hrwa";

    defaultConfig = "share/kak/kak-lsp.toml";
    kakrc = "share/kak/autoload/kak-lsp.kak";

    postInstall = ''
      install -Dm0644 kak-lsp.toml $out/$defaultConfig

      cat > kakrc <<EOF
      eval %sh{$out/bin/kak-lsp --kakoune -s \$kak_session}
      EOF
      install -Dm0644 kakrc $out/$kakrc
    '';
  };
}
