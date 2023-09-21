{ stdenv
, lib
, fetchFromGitHub

, alacritty

, fontconfig
, freetype
, libglvnd
, libxcb
}:

alacritty.overrideAttrs (oldAttrs: rec {
  pname = "${oldAttrs.pname}-ligatures";
  version = "0.7.2.20210209.g3ed0430";

  src = fetchFromGitHub {
    owner = "zenixls2";
    repo = "alacritty";
    fetchSubmodules = true;
    rev = "3ed043046fc74f288d4c8fa7e4463dc201213500";
    sha256 = "1dGk4ORzMSUQhuKSt5Yo7rOJCJ5/folwPX2tLiu0suA=";
  };

  cargoDeps = oldAttrs.cargoDeps.overrideAttrs (lib.const {
    name = "${pname}-${version}-vendor.tar.gz";
    inherit src;
    outputSha256 = "pONu6caJmEKnbr7j+o9AyrYNpS4Q8OEjNZOhGTalncc=";
  });

  ligatureInputs = [
    fontconfig
    freetype
    libglvnd
    stdenv.cc.cc.lib
    libxcb
  ];

  preferLocalBuild = true;

  buildInputs = (oldAttrs.buildInputs or [ ]) ++ ligatureInputs;

  # HACK: One of the ligature libraries required the C++ stdlib at runtime,
  # and I can't work out a better way to push it to the RPATH.
  postInstall = lib.optional (!stdenv.isDarwin) ''
    patchelf \
      --set-rpath ${lib.makeLibraryPath ligatureInputs}:"$(patchelf --print-rpath $out/bin/alacritty)" \
      $out/bin/alacritty
  '';

  meta = oldAttrs.meta // {
    description = "Alacritty with ligature patch applied";
    homepage = "https://github.com/zenixls2/alacritty/tree/ligature";
  };
})
