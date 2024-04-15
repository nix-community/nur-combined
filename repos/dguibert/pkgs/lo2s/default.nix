{
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  otf2,
  binutils,
  git,
  libbfd,
  zlib,
  libiberty,
  pkg-config,
}:
stdenv.mkDerivation {
  name = "lo2s-1.4.0";
  src = fetchFromGitHub {
    owner = "tud-zih-energy";
    repo = "lo2s";
    rev = "53c0b85166bf50208838380186e50350f6e79f14";
    sha256 = "sha256-ylan66n5HwO3EVrWn+3WI0eYNhnsa+sSy8Z0zKCx2rk=";
    fetchSubmodules = true;
    leaveDotGit = true;
  };
  preConfigure = ''
    sed -i -e "s/git_submodule_update()/#git_submodule_update()/" CMakeLists.txt
    sed -i -e "s/git_submodule_update()/#git_submodule_update()/" lib/nitro/CMakeLists.txt
  '';

  cmakeFlags = [
    "-Dlo2s_USE_STATIC_LIBS=OFF"
  ];

  buildInputs = [
    cmake
    #(boost.override { enableStatic=true; }).all
    boost
    otf2
    git
    libbfd
    zlib
    libiberty
    pkg-config
  ];
  #  meta.broken = true;
}
