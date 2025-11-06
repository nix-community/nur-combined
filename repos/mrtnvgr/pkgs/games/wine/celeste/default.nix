{ lib, fetchzip, wrapWine, requireFile, everestSupport ? false, everestMods ? [ ], ... } @ args:
let
  inherit (lib) optionalString;
  inherit (builtins) hasAttr;

  name = "celeste";

  src = if hasAttr "src" args then
    args.src
  else
    requireFile {
      inherit name;
      sha256 = "";
      message = "Please provide Celeste game files for this package";
    };

  everestSrc = fetchzip {
    url = "https://github.com/EverestAPI/Everest/releases/download/stable-1.4351.0/main.zip";
    hash = "sha256-Zfz1NXg4BYJ82vLg7E/EOFOGvJBeQBu3TpiL572CB1Y=";
  };

  isEverestEnabled = if everestMods != [ ] then true else everestSupport;

  everestSetup = optionalString isEverestEnabled /* bash */ ''
    cp -rv ${everestSrc}/* .
    chmod -R +w .
    wine MiniInstaller.exe
    wineserver -w
  '';
in wrapWine {
  inherit name;

  workdir = "$WINEPREFIX/drive_c/celeste";
  executable = "./Celeste.exe";

  setupScript = /* bash */ ''
    pushd "$WINEPREFIX/drive_c"
      mkdir celeste
      cd celeste

      cp -rv ${optionalString (!isEverestEnabled) "-s"} ${src}/* .

      ${everestSetup}
    popd
  '';

  preScript = optionalString isEverestEnabled /* bash */ ''
    # Checks if mods directory either doesn't exist or is empty
    if [ -z "$(ls -A Mods)" ]; then
      mkdir Mods
      ${lib.concatMapStringsSep "\n" (mod: "cp -rlv ${mod} Mods/") everestMods}
    fi
  '';

  tricks = [ "dotnet48" "dxvk" "d3dcompiler_47" ];

  meta = with lib; {
    description = "Help Madeline survive her inner demons on her journey to the top of Celeste Mountain";
    homepage = "https://www.celestegame.com";
    license = licenses.unfree;
    mainProgram = name;
  };
}
