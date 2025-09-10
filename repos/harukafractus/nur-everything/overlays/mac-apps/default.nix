final: prev: {
  extraApplications = { pname, upstream-name ? pname, sourceRoot
    , nativeBuildInputs ? [ prev.pkgs._7zz prev.pkgs.unzip ], installFin ? ""
    , upstream ? builtins.fromJSON (builtins.readFile ./src.json), ... }:
    with prev;
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit pname;
      version = upstream."${upstream-name}".version;

      src = fetchurl {
        url = upstream."${upstream-name}".url;
        sha256 = upstream."${upstream-name}".sha256;
      };

      inherit nativeBuildInputs;
      inherit sourceRoot;

      installPhase = ''
        mkdir -p $out/{bin,Applications/${sourceRoot}}
        cp -R . "$out/Applications/${sourceRoot}"
        ${installFin}
      '';

      passthru.updateScript = nix-update-script { };
    });

  # 
  librewolf = final.extraApplications rec {
    pname = "librewolf";
    sourceRoot = "LibreWolf.app";
    nativeBuildInputs = [ prev.pkgs.undmg ];
    installFin = ''
      ln -s "$out/Applications/LibreWolf.app/Contents/MacOS/librewolf" "$out/bin/librewolf"
    '';
    upstream-name = if prev.pkgs.system == "x86_64-darwin" then
      "librewolf-x64"
    else
      "librewolf-arm64";
  };

  whisky = final.extraApplications rec {
    pname = "whisky";
    sourceRoot = "Whisky.app";
  };

  standardnotes = final.extraApplications rec {
    pname = "standardnotes";
    sourceRoot = "Standard Notes.app";
    upstream-name = if prev.pkgs.system == "x86_64-darwin" then
      "standardnotes-x64"
    else
      "standardnotes-arm64";
  };

  lunarfyi = final.extraApplications rec {
    pname = "lunarfyi";
    sourceRoot = "Lunar.app";
  };

  sol = final.extraApplications rec {
    pname = "sol";
    sourceRoot = "Sol.app";
  };

  telegram-desktop = final.extraApplications rec {
    pname = "telegram-desktop";
    sourceRoot = "Telegram.app";
    nativeBuildInputs = [ prev.pkgs.undmg ];
  };

  ungoogled-chromium = final.extraApplications rec {
    pname = "ungoogled-chromium";
    sourceRoot = "Chromium.app";
    upstream-name = if prev.pkgs.system == "x86_64-darwin" then
      "ungoogled-chromium-x64"
    else
      "ungoogled-chromium-arm64";
    nativeBuildInputs = [ prev.pkgs.undmg ];
  };

  bambu-studio = final.extraApplications rec {
    pname = "bambu-studio";
    sourceRoot = "BambuStudio.app";
    nativeBuildInputs = [ prev.pkgs.undmg ];
  };
}
