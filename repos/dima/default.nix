{ pkgs ? import <nixpkgs> }:

rec {
	codemaxxing = pkgs.callPackage ./pkgs/codemaxxing { };
	imohash = pkgs.callPackage ./pkgs/imohash { };
	hashdir = pkgs.callPackage ./pkgs/hashdir { inherit imohash; };
	jdnbtexplorer = pkgs.callPackage ./pkgs/jdnbtexplorer { inherit nbt; };
	playit-agent = pkgs.callPackage ./pkgs/playit-agent { };
	mdremotifier = pkgs.callPackage ./pkgs/mdremotifier { inherit rich-13-9-4 rich-argparse-rich-13-9-4; };
	nbt = pkgs.callPackage ./pkgs/nbt { };
	obsidian-better-markdown-links = pkgs.callPackage ./pkgs/obsidian-better-markdown-links { };
	obsidian-filename-heading-sync = pkgs.callPackage ./pkgs/obsidian-filename-heading-sync { };
	obsidian-folder-notes = pkgs.callPackage ./pkgs/obsidian-folder-notes { };
	obsidian-privacy-screen = pkgs.callPackage ./pkgs/obsidian-privacy-screen { };
	obsidian-show-whitespace = pkgs.callPackage ./pkgs/obsidian-show-whitespace { };
	obsidian-smart-typography = pkgs.callPackage ./pkgs/obsidian-smart-typography { };
	vtt = pkgs.callPackage ./pkgs/vtt { };
	stripzip = pkgs.callPackage ./pkgs/stripzip { };

	rich-argparse-rich-13-9-4 = pkgs.callPackage ./pkgs/rich-argparse-rich-13-9-4 { inherit rich-13-9-4; };
	rich-13-9-4 = pkgs.callPackage ./pkgs/rich-13-9-4 { };
}
