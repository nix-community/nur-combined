{ lib
, stdenv
, fetchFromGitLab
, bash
, gnused
, imagemagick
}:

let
  pname = "falsisign";
  version = "git-" + lib.strings.substring 0 6 commit;
  commit = "6417c42f33ef056d180bcb59750667aeb413778e";
  sha256 = "0aydhgihfcsnj62vkr6ljsfz8by2xmhx9d44j4iax8hv5ww5mvxr";
in
stdenv.mkDerivation {
  inherit pname;
  inherit version;
  inherit commit;

  src = fetchFromGitLab {
    owner = "edouardklein";
    repo = "falsisign";
    rev = commit;
    inherit sha256;
  };

  nativeBuildInputs = [ gnused ];
  buildInputs = [ bash imagemagick ];

  postPatch = ''
    sed -i 's!convert!${imagemagick}/bin/convert!' signdiv.sh
    sed -i '69,300s!convert!${imagemagick}/bin/convert!' falsisign.sh
    sed -i '2s/Eeuxo/Eeuo/' *.sh
  '';

  doBuild = false;  

  installPhase = ''
    mkdir -p $out/bin
    cp falsisign.sh $out/bin/falsisign.sh
    cp signdiv.sh $out/bin/signdiv.sh
  '';

  doCheck = false;

  meta = with lib; {
    homepage = "https://gitlab.com/edouardklein/falsisign";
    description = "a tool to read and modify the write lock flags on SD cards";
    license = [ licenses.wtfpl ] ;
    maintainers = with maintainers; [ wamserma ];
    platforms = platforms.linux;
  };
}
