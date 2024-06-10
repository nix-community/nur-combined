final: prev: {
  installApplication = {
    pname,
    src-name,
    description,
    homepage,
    current ? builtins.fromJSON (builtins.readFile ./src.json),
    buildInputs ? [ prev.pkgs.undmg prev.pkgs.unzip ],
    ...
  }: with prev; stdenvNoCC.mkDerivation {
    inherit pname;
    inherit (current."${src-name}") version;
    src = prev.fetchurl {
      inherit (current."${src-name}") url sha256;
    };
    inherit buildInputs;
    sourceRoot = ".";
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p "$out/Applications"
      for i in *.app; do cp -r "$i" "$out/Applications/"; done
      runHook postInstall
    '';
    meta = with lib; {
      description = description;
      homepage = homepage;
      maintainers = with maintainers; [ harukafractus ];
      platforms = platforms.darwin;
    };
  };
  
  librewolf = final.installApplication rec {
    pname = "librewolf";
    src-name = if prev.pkgs.system == "x86_64-darwin" then "librewolf-x64" else "librewolf-arm64";
    description = "A custom version of Firefox, focused on privacy, security and freedom.";
    homepage = "https://librewolf.net/";
  };

  whisky = final.installApplication rec {
    pname = "whisky";
    src-name = "whisky";
    description = "A modern Wine wrapper for macOS built with SwiftUI.";
    homepage = "https://getwhisky.app/";
  };

  standardnotes = final.installApplication rec {
    pname = "standardnotes";
    src-name = if prev.pkgs.system == "x86_64-darwin" then "standardnotes-x64" else "standardnotes-arm64";
    description = "A simple and private notes app.";
    homepage = "https://standardnotes.org/";
  };

  floorp = final.installApplication rec {
    pname = "floorp";
    src-name = "floorp";
    buildInputs = [ prev.pkgs._7zz ]; # Undmg error: only HFS file systems are supported.
    description = "A fork of Firefox, focused on keeping the Open, Private and Sustainable Web alive, built in Japan";
    homepage = "https://floorp.app/";
  };
}