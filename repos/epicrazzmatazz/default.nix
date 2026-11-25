{pkgs ? import <nixpkgs> {}}: 
  let
  	callPackage = pkgs.newScope self;
	self = {
		  nixosModules = import ./nixos-modules;

		  # Web application firewall
		  # TODO hyperscan -> vectorscan
		  #wge = callPackage ./pkgs/wge {};

		  # C API to WGE, needed for nginx module
		  #wge-apic = callPackage ./pkgs/wge-apic {};

		  # to use the nginx module, add it to the upstream nginx derivation's modules attribute:
		  # pkgs.nginx.override { modules = [ nur.repos.epicrazzmatazz.nurpkgs.wge-nginx-module ]; }
		  # TODO mkNginxPlugin is not exported in pkgs attrset
		  #wge-nginx-module = callPackage ./pkgs/wge-nginx-module { inherit mkNginxPlugin; };

		  # TOML schema validator, rust implementation
		  toml-schema-rust = callPackage ./pkgs/toml-schema-rust {};

		  # "run remote command" listener daemon and client
		  ruroco = callPackage ./pkgs/ruroco {};

		  # "color-icon-matrix barcode" implementation
		  libcimbar = callPackage ./pkgs/libcimbar {};
	  };
  in self
