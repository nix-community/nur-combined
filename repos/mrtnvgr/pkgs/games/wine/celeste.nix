{ lib, fetchzip, wrapWine, unzip, stdenvNoCC, ... }:
let 
  name = "celeste";

  # TODO: https://github.com/nix-community/NUR/issues/627
  # src = fetchtorrent {
  #   url = "magnet:?xt=urn:btih:4A9EBBC92B836D331DE38EB3E62FDD4384E35C16&tr=http%3A%2F%2Fbt.t-ru.org%2Fann%3Fmagnet&dn=Celeste%20%5BL%5D%20%5BRUS%20%2B%20ENG%20%2B%207%5D%20(2019)%20(1.4.0.0)%20%5BEGS-Rip%5D";
  #   hash = "";
  # };

  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/530nycntxcab1sx21ti02/celeste-1.4.0.0-win.zip?rlkey=mmlag4tmne5vxv58biz4v3sxt&dl=1";
    hash = "sha256-MMPcilJW8HCFg/X7OJpZzN/F8R8NxZssK9flC2sJGH4=";
    extension = "zip";
    stripRoot = false;
  };

  pkg = wrapWine {
    inherit name;

    chdir = "$WINEPREFIX/drive_c/celeste";
    executable = "./Celeste.exe";

    firstrunScript = ''
      pushd "$WINEPREFIX/drive_c"
        mkdir celeste
        cd celeste

        ln -s ${src}/* .
      popd
    '';

    tricks = [ "dotnet48" "dxvk" "d3dcompiler_47" ];

    is64bits = true;
  };
in stdenvNoCC.mkDerivation {
  inherit name;

  phases = "installPhase";
  installPhase = ''
    install -D ${pkg}/bin/${name} $out/bin/${name}
  '';

  meta = with lib; {
    description = "Help Madeline survive her inner demons on her journey to the top of Celeste Mountain";
    homepage = "https://www.celestegame.com";
    license = licenses.unfree;
    mainProgram = name;
  };

  preferLocalBuild = true;
}
