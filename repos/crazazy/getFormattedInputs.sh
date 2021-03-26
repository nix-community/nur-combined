# run this in nix-unstable
nix --experimental-features nix-command eval -f dirtyFlake.nix inputs | sed 's/;/;\n/g' | nix --experimental-features "nix-command flakes" shell nixpkgs#nixpkgs-fmt -c nixpkgs-fmt
