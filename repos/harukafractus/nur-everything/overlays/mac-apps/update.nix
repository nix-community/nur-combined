{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellApplication {
  name = "update-mac-apps";

  runtimeInputs = with pkgs; [ curl sd gawk ];

  text = ''
    function urldecode() { : "''${*//+/ }"; echo -e "''${_//%/\\x}"; }

    function get_github(){
    	repo_owner=$1
    	repo_name=$2
    	match_case=''${3:-'.dmg'}

    	dl_url=$(curl "https://api.github.com/repos/$repo_owner/$repo_name/releases?per_page=4" |  sd "\"" "\n" | grep -E "https.*\\$match_case$" | head -n 1)
    	ver=$(urldecode "$(echo "$dl_url" | sd '/' '\n' | tail -2 | head -1)")
    	sha256=$(curl -sL "$dl_url" | sha256sum | awk '{print $1}')

    	echo "{
    		\"version\": \"$ver\",
    		\"url\": \"$dl_url\",
    		\"sha256\": \"$sha256\"
    	}"
    }

    function get_gitlab(){
    	namespace=$1
    	match_case=''${2:-'.dmg'}

    	dl_url=$(curl "https://gitlab.com/api/v4/projects/$namespace/releases?per_page=4" |  sd "\"" "\n" | grep -E "https.*\\$match_case$" | head -n 1)
    	ver=$(urldecode "$(echo "$dl_url" | sd '/' '\n' | tail -2 | head -1)")
    	sha256=$(curl -sL "$dl_url" | sha256sum | awk '{print $1}')

    	echo "{
    		\"version\": \"$ver\",
    		\"url\": \"$dl_url\",
    		\"sha256\": \"$sha256\"
    	}"
    }

    echo "{
    	\"standardnotes-x64\": $(get_github "standardnotes" "app" "x64.dmg"),
    	\"standardnotes-arm64\": $(get_github "standardnotes" "app" "arm64.dmg"),
    	\"whisky\": $(get_github "Whisky-App" "whisky" "hisky.zip"),
    	\"librewolf-x64\": $(get_gitlab "librewolf-community%2Fbrowser%2Fbsys6" "x86_64-package.dmg"),
    	\"librewolf-arm64\": $(get_gitlab "librewolf-community%2Fbrowser%2Fbsys6" "arm64-package.dmg"),
    	\"floorp\": $(get_github "Floorp-Projects" "Floorp" "floorp-macOS-universal.dmg"),
    	\"lunarfyi\": $(get_github "alin23" "Lunar" ".dmg"),
    	\"sol\": $(get_github "ospfranco" "sol" ".zip"),
    	\"telegram-desktop\": $(get_github "telegramdesktop" "tdesktop" ".dmg"),
			\"ungoogled-chromium-x64\": $(get_github "ungoogled-software" "ungoogled-chromium-macos" "x86_64-macos.dmg"),
			\"ungoogled-chromium-arm64\": $(get_github "ungoogled-software" "ungoogled-chromium-macos" "arm64-macos.dmg"),
			\"bambu-studio\": $(get_github "bambulab" "BambuStudio" ".dmg")

    }" > src.json
  '';
}
