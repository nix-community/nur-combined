{pkgs, lib, stdenv, fetchurl, gnome3, unzip, ...}:

{
	# Every gnome extension has a UUID. It's the name of the extension folder once unpacked
	# and can always be found in the metadata.json of every extension.
	uuid,
	name,
	pname,
	description,
	# extensions.gnome.org extension URL
	link,
	version,
	sha256,
	shell-versions
}:

stdenv.mkDerivation {
	inherit pname;
	version = builtins.toString version;
	src = fetchurl {
		url = "https://extensions.gnome.org/extension-data/${builtins.replaceStrings ["@"] [""] uuid}.v${builtins.toString version}.shell-extension.zip";
		inherit sha256;
	};
	nativeBuildInputs = [ unzip ];
	buildCommand = ''
		mkdir -p $out/share/gnome-shell/extensions/
		unzip $src -d $out/share/gnome-shell/extensions/${uuid}
	'';
	meta = {
		description = builtins.head (lib.splitString "\n" description);
		longDescription = description;
		homepage = link;
			# Mark as broken if not compatible with current Gnome installation
			broken = let
				matchesGnomeShellVersion = version: (builtins.compareVersions (lib.versions.majorMinor version) (lib.versions.majorMinor gnome3.gnome-shell.version)) == 0;
			in
				!(builtins.any matchesGnomeShellVersion shell-versions);
	};
	# You don't need a remote machine for unzipping a bit of JavaScript
	preferLocalBuild = true;
}
