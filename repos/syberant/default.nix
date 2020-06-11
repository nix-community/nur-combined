{ pkgs }:

rec {
	rofi-unwrapped-git = pkgs.callPackage ./pkgs/rofi-unwrapped-git {};
        source-rofi = pkgs.callPackage ./pkgs/adi1090x/source-rofi {};
        powermenu = pkgs.callPackage ./pkgs/adi1090x/powermenu {
          inherit rofi-unwrapped-git;
          inherit source-rofi;
        };
        launchers-git = pkgs.callPackage ./pkgs/adi1090x/launchers-git {
          inherit rofi-unwrapped-git;
          inherit source-rofi;
        };
}
