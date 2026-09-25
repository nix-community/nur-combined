{ pkgs ? import <nixpkgs> {} }:

{
	lib = import ./lib { inherit pkgs; };

	# WAF compatible with ModSecurity SecLang and Core Rule Set
	wge = pkgs.callPackage ./pkgs/wge {};

	# C API to WGE, needed for nginx module
	wge-apic = pkgs.callPackage ./pkgs/wge-apic;

	# to use the nginx module, add it to the upstream nginx derivation's modules attribute:
	# pkgs.nginx.override { modules = [ nur.repos.epicrazzmatazz.nurpkgs.wge-nginx-module ]; }
	wge-nginx-module = pkgs.callPackage ./pkgs/wge-nginx-module;
}
