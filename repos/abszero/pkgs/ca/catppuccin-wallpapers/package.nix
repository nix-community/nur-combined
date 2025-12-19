{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writeShellScript,
  # Install all wallpapers by default
  wallpapers ? null,
}:

let
  # I hate bash I hate bash I hate bash
  # Have to do this or find can't find \)
  installScript = writeShellScript "catppuccin-wallpapers-install" ''
    find . -type f \( -name *.png -or -name *.jpg \) -print0 \
    | xargs -r0 -n1 \
      -- bash -c \
        '[[ " $1 " =~ " $(basename "''${2%.*}") " ]] \
           && cp $2 "$out/share/wallpapers/catppuccin" || true' \
      -- "$wallpapers"
  '';
in

stdenvNoCC.mkDerivation {
  pname = "catppuccin-wallpapers";
  version = "0-unstable-2022-08-23";

  src = fetchFromGitHub {
    owner = "zhichaoh";
    repo = "catppuccin-wallpapers";
    rev = "1023077979591cdeca76aae94e0359da1707a60e";
    hash = "sha256-h+cFlTXvUVJPRMpk32jYVDDhHu1daWSezFcvhJqDpmU=";
  };

  inherit wallpapers;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/wallpapers/catppuccin"
    if [ -z "$wallpapers" ]; then
      find . -mindepth 1 -maxdepth 1 -type d \
        -exec cp -r {} "$out/share/wallpapers/catppuccin" \;
    else
      bash ${installScript}
    fi

    runHook postInstall
  '';

  dontFixup = true;

  meta = with lib; {
    description = "Wallpapers to match your Catppuccin setups (zhichaoh's fork)";
    homepage = "https://github.com/zhichaoh/catppuccin-wallpapers";
    license = licenses.mit;
    maintainers = with maintainers; [ weathercold ];
    platforms = platforms.all;
  };
}
