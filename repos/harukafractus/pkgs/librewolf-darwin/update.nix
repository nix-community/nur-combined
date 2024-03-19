{ pkgs, writeShellApplication }:

writeShellApplication {
  name = "librewolf-update-source";

  runtimeInputs = with pkgs; [ curl sd jq ];

  text = ''
function generate_json_librewolf(){
	base_json_librewolf="$(curl -s https://gitlab.com/api/v4/projects/44042130/releases/)"
	url="$(echo "$base_json_librewolf" | jq -r '.[0].assets.links[].direct_asset_url' | grep .macos-"$1"-package.dmg$)"

  sd "version = (.*?);" "version = \"$(echo "$base_json_librewolf" | jq -r '.[0].tag_name')\";" default.nix
  sd "$1_url = (.*?);" "$1_url = \"$url\";" default.nix
  sd "$1_sha256 = (.*?);" "$1_sha256 = \"$(curl -sL "$url".sha256sum)\";" default.nix;
}

generate_json_librewolf arm64
generate_json_librewolf x86_64
'';
}