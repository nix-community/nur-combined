{
  lib,
  stdenv,

  gcc,
  fetchzip
}:
stdenv.mkDerivation rec {
  pname = "libspeedhack";
  version = "0.1";

  src = fetchzip {
    url = "https://github.com/evg-zhabotinsky/${pname}/releases/download/${version}-x86-multilib/libspeedhack.tar.gz";
    sha256 = "sha256-IrBH9MUXO7amMt9geuIc49Kr3H+K4rnmfUYuOV4qnnw=";
  };

  nativeBuildInputs = [ gcc ];

  # just copy
  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';

  meta = with lib; {
    description = "A library for speedhacking x86 games";
    homepage = "https://github.com/evg-zhabotinsky/libspeedhack";
    license = licenses.mit;
  };

  preferLocalBuild = true;

}
