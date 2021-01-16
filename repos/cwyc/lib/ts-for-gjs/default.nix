{stdenv, nodejs, python3, automake, fetchFromGitHub, callPackage, lib}:
{
	name ? "ts-for-gjs", #name of the derivation
	sources, #derivations containing /share/gir-1.0/ files, usually the .dev output of most gobject libraries
	names ? null, #names of the modules (i.e. Gtk-3.0 for Gtk-3.0.gir) to generate definitions for, or null to generate definitions for all available libraries
	ignore ? [], #names of the modules not to generate
	prettify ? true, #whether to prettify the output typescript files
	type ? "gjs" #"gjs" for gjs runtime, "node" for node-gtk runtime, or "gjs,node" for both
}:
let
	nodeDependencies = (callPackage ./package/default.nix {}).shell.nodeDependencies;
	librariesString = 
		builtins.concatStringsSep 
			" "
			(map 
				(path: "-g " + path + "/share/gir-1.0/") 
				sources);
	namesString = 
		if (names == null)
			then "\"*\""
			else builtins.concatStringsSep " " names;
in 
lib.makeOverridable stdenv.mkDerivation {
	name = name;
	src = fetchFromGitHub {
		owner="sammydre";
		repo="ts-for-gjs";
		rev="e1fdadbe3a4de45ce812ba07382c17efa839b702";
		sha256="0fqdd1r5b0arhiy1af673pp6imgm4016x97jgkib7ndndg03a9r6";
		fetchSubmodules=true;
	};
	buildInputs = [nodejs python3 automake];
	buildPhase = ''
		ln -s ${nodeDependencies}/lib/node_modules ./node_modules
		export PATH="${nodeDependencies}/bin:$PATH"

		mkdir -p $out
		npm run start -- generate ${namesString} ${librariesString} -o $out
	'';
	dontInstall = true;
	dontFixup = true;
	dontCopyDist = true;
}