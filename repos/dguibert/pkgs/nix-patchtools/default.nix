{ stdenv, fetchFromGitHub, file, getopt}:

stdenv.mkDerivation {
  name = "autopatchelf";
  src = fetchFromGitHub {
    owner = "svanderburg";
    repo = "nix-patchtools";
    rev = "b6fe3f8dfe39502b1511bee101890eaa19196808";
    sha256 = "0bq0dwcyd1zfgnw9gd04s14x5zf5d60c0svmf74snds996y6k9pi";

  };
  buildCommand = ''
    mkdir -p $out/bin
    cp $src/autopatchelf $out/bin/autopatchelf
    sed -i \
      -e "s|file |${file}/bin/file |" \
      -e "s|getopt |${getopt}/bin/getopt |" $out/bin/autopatchelf
    chmod +x $out/bin/autopatchelf
    patchShebangs $out/bin
  '';
}

