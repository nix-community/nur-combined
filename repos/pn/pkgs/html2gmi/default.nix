{ stdenv, lib, fetchFromGitHub, buildGoModule }:
with lib;

let
  pname = "html2gmi";
  version = "unstable-15-11-2020";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "LukeEmmet";
    repo = pname;
    rev = "928eec33eeabae7443d5a6abcbfbfbc9f95ebe8a";
    sha256 = "0v8hys174nrqjn1xwc2ij097hijpbkad0hx2w1l2mngfkgi0liwb";
  };

  vendorSha256 = "016cgpa5z1l1pn3f80r2sl0sxwsnrvychsbfcr2hvb9qi1lm0wkl";

  buildPhase = ''
    go build -o html2gmi
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp html2gmi $out/bin
  '';

  meta = {
    description = "A command line application to convert HTML to GMI (Gemini text/gemini)";
    homepage = "https://github.com/LukeEmmet/html2gmi";
    license = "MIT";
    platforms = platforms.linux;
  };
}
