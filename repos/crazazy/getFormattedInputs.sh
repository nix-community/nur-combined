# run this in nix-unstable
if nix --version | grep -F '2.3'; then
	nix eval -f dirtyFlake.nix inputs | sed 's/;/;\n/g' | nix run nixpkgs.nixpkgs-fmt -c nixpkgs-fmt
else
	nix --experimental-features nix-command eval -f dirtyFlake.nix inputs | sed 's/;/;\n/g' | nix --experimental-features "nix-command flakes" shell nixpkgs#nixpkgs-fmt -c nixpkgs-fmt
fi
