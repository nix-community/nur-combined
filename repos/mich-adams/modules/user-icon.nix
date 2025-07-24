{ pkgs, lib, username, icon, colors, ... }:
{
    systemd.tmpfiles.rules =
	let
	    username = "michael";
	    icon = pkgs.runCommand "${username}-icon.png" { } ''
		${pkgs.lutgen}/bin/lutgen apply ${./michael.png} -o $out -- ${lib.strings.concatStringsSep " " config.scheme.toList}
		'';
	in
	    [
	    "f+ /var/lib/AccountsService/users/${username}  0600 root root - [User]\\nIcon=/var/lib/AccountsService/icons/${username}\\n" # notice the "\\n" we don't want nix to insert a new line in our string, just pass it as \n to systemd
	    "L+ /var/lib/AccountsService/icons/${username}  - - - - ${icon}" # you can replace the ${....} with absolute path to face icon
	];

}
