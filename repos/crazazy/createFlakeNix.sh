# run this in nix-unstable
getInputs(){
	if nix --version | grep -F '2.3' > /dev/null; then
		nix eval -f dirtyFlake.nix inputs | sed 's/;/;\n/g' | nix run nixpkgs.nixpkgs-fmt -c nixpkgs-fmt
	else
		nix --experimental-features nix-command eval -f dirtyFlake.nix inputs | sed 's/;/;\n/g' | nix-shell -p nixpkgs-fmt --run nixpkgs-fmt
	fi
}

cat > ./flake.nix << EOF
{
description = "Port niv config to a flake file";
inputs = $(getInputs);
outputs = args: (import ./dirtyFlake.nix).outputs args;
}
EOF
