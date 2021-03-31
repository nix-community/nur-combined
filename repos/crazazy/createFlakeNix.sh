# run this in nix-unstable
evalNix(){
	if nix --version | grep -F '2.3' > /dev/null; then
		nix eval $*
	else
		nix --experimental-features nix-command eval $*
	fi
}
inputs=$(evalNix -f dirtyFlake.nix inputs | sed 's/;/;\n/g' | nix-shell -p nixpkgs-fmt --run nixpkgs-fmt)
description=$(evalNix -f dirtyFlake.nix description)
getInputs(){
	if nix --version | grep -F '2.3' > /dev/null; then
		nix eval -f dirtyFlake.nix inputs | sed 's/;/;\n/g' | nix run nixpkgs.nixpkgs-fmt -c nixpkgs-fmt
	else
		nix --experimental-features nix-command eval -f dirtyFlake.nix inputs | sed 's/;/;\n/g' | nix-shell -p nixpkgs-fmt --run nixpkgs-fmt
	fi
}

cat > ./flake.nix << EOF
{
description = $description;
inputs = $inputs;
outputs = args: (import ./dirtyFlake.nix).outputs args;
}
EOF
