# Almost 1:1 copy of idris2's nix/platform.nix. Some work done in their flake.nix
# we do here instead.
{ stdenv, lib, chez, gmp, fetchFromGitHub, gnumake }:

# NOTICE: An `idris2WithPackages` is available at: https://github.com/claymager/idris2-pkgs

let
  # Taken from Idris2/idris2/flake.nix. Check if the idris2 project does it this
  # way, still, every now and then.
  idris2-commit = "2994e23fd06d696828d4cee9e71958314dccd956";
  pack = fetchFromGitHub {
    owner = "stefan-hoeck";
    repo = "idris2-pack";
    name = "idris2-pack";
    rev = "63a32d7f7526a90df19508c789ac038d5091fdb4";
    sha256 = "sha256-BebSQkDeA9N/DFiD4mc0W+43j0wqybWHWzSEUURraOk=";
  };
  pack-db = fetchFromGitHub {
    owner = "stefan-hoeck";
    repo = "idris2-pack-db";
    name = "idris2-pack-db";
    rev = "80bdf903e3aa302c36080557eba60d38de9008d5";
    sha256 = "sha256-GEUyMobvnE+BjvZYqZQ/03aA05ncl7DLxrtTBdE7Lfk=";
  };
  repo-idris2 = fetchFromGitHub {
    owner = "idris-lang";
    repo = "Idris2";
    name = "Idris2";
    rev = idris2-commit;
    sha256 = "sha256-xKeHOEeAoHN3GHedHcnlPfqpNGCoXsZg1UN4Mzc+/pU=";
  };
  filepath = fetchFromGitHub {
    owner = "stefan-hoeck";
    repo = "idris2-filepath";
    name = "idris2-filepath";
    rev = "63dab635a40fd1ee19c07cd789c9099b357d92d1";
    sha256 = "sha256-lyKevOBgWhDvHlLkSkjBsMNXPhPr0EEhhAPJuKpCF7A=";
  };

  toml = fetchFromGitHub {
    owner = "cuddlefishie";
    repo = "toml-idr";
    name = "toml-idr";
    rev = "b4f5a4bd874fa32f20d02311a62a1910dc48123f";
    sha256 = "sha256-+bqfCE6m0aJ+S65urT+zQLuZUtUkC1qcuSsefML/fAE=";
  };

  # Uses scheme to bootstrap the build of idris2
in stdenv.mkDerivation rec {
  pname = "idris2-pack";
  version = "2024-06-18";

  srcs = [ pack pack-db filepath toml repo-idris2 ];
  sourceRoot = "idris2-pack";

  # 设置环境变量

  SCHEME = "scheme";
  CG = "chez";
  IDRIS2_CG = "chez";
  IDRIS2_COMMIT = idris2-commit;

  buildPhase = ''
    echo "Building..............."
    chmod -R 777 $NIX_BUILD_TOP
    sh ${./install.sh}
  '';

  nativeBuildInputs = [
    chez
    gmp
    gnumake
  ];

  buildInputs = [
    chez
    gmp
  ];

  installPhase = ''
    echo "Installing..."
    # 这里可以添加你的安装脚本
    mkdir -p $out/bin
    cp -r $NIX_BUILD_TOP/idris2-pack/build/exec/* $out/bin
    cp -r $NIX_BUILD_TOP/.pack/install/idris2/bin/* $out/bin

    # pushd $out/bin
    # cat <<EOF >>idris2
    # #!/bin/sh

    # APPLICATION="\$($out/bin/pack app-path idris2)"
    # export IDRIS2_PACKAGE_PATH="\$($out/bin/pack package-path)"
    # export IDRIS2_LIBS="\$($out/bin/pack libs-path)"
    # export IDRIS2_DATA="\$($out/bin/pack data-path)"
    # export IDRIS2_CG="$CG"
    # \$APPLICATION "\$@"
    # EOF

    # chmod +x idris2

  '';

  meta = {
    description = "An Idris2 Package Manager with Curated Package Collections";
    homepage = "https://github.com/stefan-hoeck/idris2-pack";
    license = lib.licenses.bsd3;
    inherit (chez.meta) platforms;
  };
}
