{ config, lib, ... }:

with lib;

{
  options = {
    home.wallpapers = mkOption
      {
        type = with types; listOf path;
        default = [ ];
        example = literalExpression "./wallpaper/wall.heif";
      };
  };
  config = {
    home.activation.wallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] (mkIf (config.home.wallpapers != null)
      (
        let
          set_osa = ''
            tell application "System Events"
                set wallpapers to { ${(concatStringsSep "," (map1 (x: ''"${x}"'') config.home.wallpapers))} }
            	set n_desktop to count of desktop
            	set n to 0
            	repeat with wallpaper in wallpapers
            		set n to n + 1
            		if n > n_desktop then exit repeat
            		log "setting " & n & " " & wallpaper
            		tell desktop n to set picture to wallpaper as POSIX file
            	end repeat
            end tell
          '';
        in
        ''
          # Set wallpaper.
          echo "setting wallpaper..." >&2

          $DRY_RUN_CMD osascript -e '${script}'
        ''
      ));
  };
}
