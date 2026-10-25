{
  pkgs,
  lib,
  config,
  ...
}:
let
  st = pkgs.st.overrideAttrs (oldAttrs: rec {
    patches = [
      # Fetch them directly from `st.suckless.org`
      (pkgs.fetchpatch {
        url = "https://st.suckless.org/patches/kitty-graphics-protocol/st-kitty-graphics-20251230-0.9.3.diff";
        sha256 = "sha256-+b0LySNZlrjjLzXq7XU7lPQhBnQs91sJjD30tAbXKRA=";
      })
      (pkgs.fetchpatch {
        url = "https://st.suckless.org/patches/drag-n-drop/st-drag-n-drop-0.9.2.diff";
        hash = "sha256-sqlZUjZheykBdfXwhIURp95aEiyiZUp6My7gnWrd3qY=";
      })
      (pkgs.fetchpatch {
        url = "https://st.suckless.org/patches/clickurl/st-clickurl-0.8.5.diff";
        hash = "sha256-2/pEVF6GUJKKaOAbi4Rlgu5GJh0zHKMOzo4bv8TacIo=";
      })
    ];
    configFile = pkgs.writeText "config.h" (builtins.readFile ./config.h);
    postPatch = "${oldAttrs.postPatch}\n cp ${configFile} config.def.h";
  });
in
{
  options.dots.terminal.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the terminal dotfiles module.";
  };
  options.dots.terminal.st.enable = lib.mkEnableOption "St lightweight Terminal";
  options.dots.terminal.ghostty.enable = lib.mkEnableOption "Ghostty Terminal";

  config = lib.mkIf config.dots.terminal.enable {
    home.packages =
      lib.optionals
        (config.dots.terminal.st.enable && lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.st)
        [
          st
          (pkgs.writeShellApplication {
            name = "fzfmenu";
            runtimeInputs = [ pkgs.coreutils ];
            text = ''
              # Stream input through a FIFO so fzf can start before stdin finishes.
              tmp_dir=$(mktemp -d)
              chmod 700 "$tmp_dir"
              trap 'kill "''${st_pid:-}" "''${writer_pid:-}" 2>/dev/null || true; rm -rf "$tmp_dir"' EXIT
              mkfifo "$tmp_dir/input"

              exec 3<&0
              ${lib.getExe st} -c fzfmenu -n fzfmenu -e ${lib.getExe pkgs.bash} -c '
                input=$1
                output=$2
                shift 2
                ${lib.getExe pkgs.fzf} "$@" < "$input" > "$output"
              ' fzfmenu "$tmp_dir/input" "$tmp_dir/output" "$@" &
              st_pid=$!
              cat <&3 > "$tmp_dir/input" &
              writer_pid=$!

              wait "$st_pid" || exit $?
              cat "$tmp_dir/output"
            '';
          })
        ];
    programs.ghostty = {
      enable = config.dots.terminal.ghostty.enable;
      package = pkgs.ghostty-bin; # macos be funky
      settings = {
        font-size = 16;
        font-family = "Comic Code Ligatures";
        adjust-cell-height = "50%";
        font-thicken = true;
        font-thicken-strength = 120;
        keybind = "global:cmd+grave_accent=toggle_quick_terminal";

      };
      installVimSyntax = true;
      installBatSyntax = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };
  };
}
