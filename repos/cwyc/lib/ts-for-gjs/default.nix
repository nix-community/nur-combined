{stdenv, nodejs, python3, automake, fetchFromGitHub, callPackage, lib}:
{
	name ? "ts-for-gjs", #name of the derivation
	sources, #derivations containing gir files
	modules ? null, #names of the modules (i.e. Gtk-3.0 for Gtk-3.0.gir) to generate definitions for, or null to generate definitions for all available libraries
	ignore ? [], #names of the modules not to generate
	prettify ? true, #whether to prettify the output typescript files
	environment ? "both" #"gjs" for gjs runtime, "node" for node-gtk runtime, or "both" for both
}:
let
	nodeDependencies = (callPackage ./package/default.nix {}).shell.nodeDependencies;
	librariesString = 
		builtins.concatStringsSep 
			" " 
			(map 
				(path: "-g " + path) 
				sources);
	namesString = 
		if (modules == null)
			then "\"*\""
			else builtins.concatStringsSep " " modules;
	ignoreString =
		builtins.concatStringsSep 
			" " 
			(map 
				(name: "-i " + name) 
				ignore);
	environmentString =
		if environment == "gjs" then "-e gjs"
		else if environment == "node" then "-e node"
		else if environment == "both" then ""
		else throw environment + '' must be "gjs", "node", or "both"'';
in 
lib.makeOverridable stdenv.mkDerivation {
	name = name;
	src = fetchFromGitHub {
		owner="sammydre";
		repo="ts-for-gjs";
		rev="e1fdadbe3a4de45ce812ba07382c17efa839b702";
		sha256="0fqdd1r5b0arhiy1af673pp6imgm4016x97jgkib7ndndg03a9r6";
		fetchSubmodules=false;
	};
	buildInputs = [nodejs python3 automake];
	buildPhase = ''

		ln -s ${nodeDependencies}/lib/node_modules ./node_modules
		export PATH="${nodeDependencies}/bin:$PATH"

		mkdir -p $out
		npm run start -- generate ${namesString} ${librariesString} -o $out ${if prettify then "--pretty" else ""} ${environmentString}
	'';
	dontInstall = true;
	dontFixup = true;
	dontCopyDist = true;
}