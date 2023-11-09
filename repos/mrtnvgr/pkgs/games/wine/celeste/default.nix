{ lib, fetchtorrent, fetchzip, wrapWine, unzip, stdenvNoCC, everestSupport ? false, everestMods ? [ ], ... }:
let 
  name = "celeste";

  src = fetchtorrent {
    url = "magnet:?xt=urn:btih:4A9EBBC92B836D331DE38EB3E62FDD4384E35C16&tr=http%3A%2F%2Fbt.t-ru.org%2Fann%3Fmagnet&dn=Celeste%20%5BL%5D%20%5BRUS%20%2B%20ENG%20%2B%207%5D%20(2019)%20(1.4.0.0)%20%5BEGS-Rip%5D";
    hash = "sha256-MMPcilJW8HCFg/X7OJpZzN/F8R8NxZssK9flC2sJGH4=";
  };

  everestSrc = fetchzip {
    url = "https://github.com/EverestAPI/Everest/releases/download/stable-1.4351.0/main.zip";
    hash = "sha256-Zfz1NXg4BYJ82vLg7E/EOFOGvJBeQBu3TpiL572CB1Y=";
  };

  isEverestEnabled = if everestMods != [ ] then true else everestSupport;

  everestSetup = if isEverestEnabled then ''
    cp -r ${everestSrc}/* .
    chmod -R +w .
    wine MiniInstaller.exe
    wineserver -w
  '' else "";

  pkg = wrapWine {
    inherit name;

    chdir = "$WINEPREFIX/drive_c/celeste";
    executable = "./Celeste.exe";

    setupScript = ''
      pushd "$WINEPREFIX/drive_c"
        mkdir celeste
        cd celeste

        cp -r ${src}/* .

        ${everestSetup}
      popd
    '';

    preScript = if isEverestEnabled then ''
      # Checks if mods directory either doesn't exist or is empty
      if [ -z "$(ls -A Mods)" ]; then
        mkdir Mods
        ${lib.concatMapStringsSep "\n" (mod: "cp -r ${mod} Mods/") everestMods}
      fi
    '' else "";

    tricks = [ "dotnet48" "dxvk" "d3dcompiler_47" ];
  };
in stdenvNoCC.mkDerivation {
  inherit name;
  version = "1.4.0.0";

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
