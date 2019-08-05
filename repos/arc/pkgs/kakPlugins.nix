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

    kakrc = "share/kak/autoload/tree.kak";
    pname = "kak-tree";
    version = "6d32dda895fbfcbb772ab234ffa04dd257b9309d";
    src = fetchFromGitHub {
      owner = "ul";
      repo = pname;
      rev = version;
      sha256 = "0c42v7kypcn4s24kr6mrjx2yxdcmay0z9jzggvay9z7766ja9d8r";
      fetchSubmodules = true;
    };

    buildInputs = lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;

    cargoSha256 = if lib.isNixpkgsStable
      then "15rc6p437vxmz3ng5gk060qpdh120r6p10jd9z8w31cdpa82pc4n"
      else "05fd53l4i94857z66byy2fc481g10sg07aysgjj6kllkmlsb3wix";

    preBuild = ''
      sed -e "s,\"kak-tree\",\"$out/bin/kak-tree\"," -i rc/tree.kak
    '';

    postInstall = ''
      install -Dm0644 rc/tree.kak $out/$kakrc
    '';
  };
  kak-lsp = { fetchFromGitHub, rustPlatform, buildKakPluginFrom2Nix, lib, darwin, hostPlatform }: buildKakPluginFrom2Nix rec {
    mkDerivation = rustPlatform.buildRustPackage;

    pname = "kak-lsp";
    version = "6.2.0";
    src = fetchFromGitHub {
      owner = "ul";
      repo = pname;
      rev = "v${version}";
      sha256 = "0gv7acx2vy2n9wbgays0s3ag43sqqx9pqyr90ffglli0rsm0m1p6";
    };

    buildInputs = lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;

    cargoSha256 = if lib.isNixpkgsStable
      then "0bzb3i9cq1p5s2nxlq1z2rhc3f70rakgrd9xyvw7b2sk7zx2yh5c"
      else "0w0mnh8fnl8zi9n0fxzqaqbvmfagf3ay5v2na3laxb72jm76hrwa";

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
