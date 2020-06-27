{pkgs, lib, stdenv, fetchzip, gnome3, ...}:

{
	# Should start with 'gnome-shell-extension-'
	pname,
	version,
	# Every gnome extension has a UUID. It's the name of the extension folder once unpacked
	# and can always be found in the metadata.json of every extension.
	uuid,
	sha256,
	# Additional meta attributes, the most imporant ones are generated from the metadata.json
	meta ? {}
}:

let
	versionStr = builtins.toString version;
	src = fetchzip {
		url = "https://extensions.gnome.org/extension-data/${builtins.replaceStrings ["@"] [""] uuid}.v${versionStr}.shell-extension.zip";
		inherit sha256;
		stripRoot = false;
	};
	metadata_json = builtins.fromJSON (builtins.readFile "${src}/metadata.json");
in
	# Assert the manually specified values are the same as in the metadata.json
	assert versionStr == builtins.toString metadata_json.version;
	assert uuid == metadata_json.uuid;
	stdenv.mkDerivation {
		inherit pname;
		version = versionStr;
		inherit src;
		builder = builtins.toFile "build-gnome-shell-extension" ''
			source $stdenv/setup
			mkdir -p $out/share/gnome-shell/extensions/
			cp -r $src $out/share/gnome-shell/extensions/${uuid}
		'';
		meta = {
			description = metadata_json.name;
			longDescription = metadata_json.description;
			homepage = metadata_json.url;
			broken = let
				matchesGnomeShellVersion = version: (builtins.compareVersions version (lib.versions.majorMinor gnome3.gnome-shell.version)) == 0;
			in
				!(builtins.any matchesGnomeShellVersion metadata_json.shell-version);
		} // meta;
	}
