{
  lib,
  fishPlugins,
  writeText,
  fetchFromGitHub,
  catppuccin-whiskers,
  nix-update-script,
}:
let
  fishTerra = writeText "fish.terra" ''
    ---
    whiskers:
      version: 2.1.0
      matrix:
        - flavor
      filename: "conf.d/catppuccin_{{ flavor.identifier }}.fish"
    ---

    {%- set palette = flavor.colors -%}

    # name: 'Catppuccin {{ flavor.name }}'
    # url: 'https://github.com/catppuccin/fish'
    # preferred_background: {{ palette.base.hex }}

    set -g fish_color_normal {{ palette.text.hex }}
    set -g fish_color_command {{ palette.blue.hex }}
    set -g fish_color_param {{ palette.flamingo.hex }}
    set -g fish_color_keyword {{ palette.red.hex }}
    set -g fish_color_quote {{ palette.green.hex }}
    set -g fish_color_redirection {{ palette.pink.hex }}
    set -g fish_color_end {{ palette.peach.hex }}
    set -g fish_color_comment {{ palette.overlay1.hex }}
    set -g fish_color_error {{ palette.red.hex }}
    set -g fish_color_gray {{ palette.overlay0.hex }}
    set -g fish_color_selection --background={{ palette.surface0.hex }}
    set -g fish_color_search_match --background={{ palette.surface0.hex }}
    set -g fish_color_option {{ palette.green.hex }}
    set -g fish_color_operator {{ palette.pink.hex }}
    set -g fish_color_escape {{ palette.maroon.hex }}
    set -g fish_color_autosuggestion {{ palette.overlay0.hex }}
    set -g fish_color_cancel {{ palette.red.hex }}
    set -g fish_color_cwd {{ palette.yellow.hex }}
    set -g fish_color_user {{ palette.teal.hex }}
    set -g fish_color_host {{ palette.blue.hex }}
    set -g fish_color_host_remote {{ palette.green.hex }}
    set -g fish_color_status {{ palette.red.hex }}
    set -g fish_pager_color_progress {{ palette.overlay0.hex }}
    set -g fish_pager_color_prefix {{ palette.pink.hex }}
    set -g fish_pager_color_completion {{ palette.text.hex }}
    set -g fish_pager_color_description {{ palette.overlay0.hex }}
  '';
in
fishPlugins.buildFishPlugin {
  pname = "fish-catppuccin";
  version = "0-unstable-2026-03-13";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "fish";
    rev = "5fc5ae9c2ec22eb376cb03ce76f0d262a38960f3";
    hash = "sha256-3KNWYXfOMzZovdjwjBpjSH8cVlD4CO2QmQcCyQE4Dac=";
  };

  preInstall = ''
    mkdir -p $out/share/fish/themes
    install -m644 themes/*.theme $out/share/fish/themes/

    ${catppuccin-whiskers}/bin/whiskers ${fishTerra}
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Soothing pastel theme for the Fish Shell";
    homepage = "https://github.com/catppuccin/fish";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
