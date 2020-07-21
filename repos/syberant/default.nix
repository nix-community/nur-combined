{ pkgs }:

rec {
	rofi-unwrapped-git = pkgs.callPackage ./pkgs/rofi-unwrapped-git {};
        emojipicker = pkgs.callPackage ./pkgs/emojipicker {};
        powermenu = pkgs.callPackage ./pkgs/adi1090x/powermenu {
          inherit rofi-unwrapped-git;
        };
        launchers-git = pkgs.callPackage ./pkgs/adi1090x/launchers-git {
          inherit rofi-unwrapped-git;
        };
        polybar-1 = pkgs.callPackage ./pkgs/adi1090x/polybar-themes/polybar-1 {};
        polybar-3 = pkgs.callPackage ./pkgs/adi1090x/polybar-themes/polybar-3 {};

        dwm-patches = pkgs.callPackage ./pkgs/dwm/patches.nix {};
        dwm = pkgs.callPackage ./pkgs/dwm/dwm.nix {};
}
