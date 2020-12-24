self: super: let
	# Index of all scraped extensions (with supported versions)
	extensionsIndex = builtins.fromJSON (builtins.readFile ./../lib/extensions.json);
	# Filter the extensions index to the matching Gnome shell version.
	filterShellVersion = shell-version: extensions-index:
		(builtins.map
			(e: {
				inherit (e) uuid name description link pname;
				inherit (e.shell_version_map.${shell-version}) version sha256;
			})
			(builtins.filter
				(e: (builtins.hasAttr shell-version e."shell_version_map"))
				extensions-index
			));
	# Map a list of derivations to an attribute set with their pname as key
	derivationsToAttrset = derivations: (builtins.listToAttrs (builtins.map (e: {name = e.pname; value = e;}) derivations));
in rec {
	buildShellExtension = self.callPackage ../pkgs/buildGnomeExtension2.nix {};

	gnome36Extensions = derivationsToAttrset (builtins.map buildShellExtension (filterShellVersion "36" extensionsIndex));
	gnome38Extensions = derivationsToAttrset (builtins.map buildShellExtension (filterShellVersion "38" extensionsIndex));

	gnomeExtensions = super.gnomeExtensions // {
		buildShellExtension = self.callPackage ../pkgs/buildGnomeExtension.nix {};

		# #### LEGACY ####

		dash-to-panel = super.gnomeExtensions.dash-to-panel.overrideAttrs (old: {
			version = "40";

			src = self.fetchFromGitHub {
				owner = "home-sweet-gnome";
				repo = "dash-to-panel";
				rev = "v40";
				sha256 = "07jq8d16nn62ikis896nyfn3q02f5srj754fmiblhz472q4ljc3p";
			};
		});
		custom-hot-corners = self.gnomeExtensions.buildShellExtension {
			pname = "gnome-shell-extension-custom-hot-corners";
			uuid = "custom-hot-corners@janrunx.gmail.com";
			version = 7;
			sha256 = "1azcs4c44v4vrnzr81q5zfsx8hjch8rm0f3axwxd46yg142kli3z";
		};
		emoji-selector = self.gnomeExtensions.buildShellExtension {
			pname = "gnome-shell-extension-emoji-selector";
			uuid = "emoji-selector@maestroschan.fr";
			version = 20;
			sha256 = "1i6py149m46xig5a0ry7y5v887nlzw644mw72gcr2hkfsn8b0gnd";
		};
		cpu-power-manager = self.gnomeExtensions.buildShellExtension {
			pname = "gnome-shell-extension-cpu-power-manager";
			uuid = "cpupower@mko-sl.de";
			version = 21;
			sha256 = "1p7ffcl1dzr84f7nhaaqi4kyzm7ywf0wdfz7lrvrmhlnqmmhq3f5";
		};
		lock-screen-blur = self.gnomeExtensions.buildShellExtension {
			pname = "gnome-shell-extension-lock-sceen-blur";
			uuid = "ControlBlurEffectOnLockScreen@pratap.fastmail.fm";
			version = 4;
			sha256 = "00fbw5mp8hr3myyan81f2kh7ihs1q1cr6p60dgyi2r0xw5d8yqhf";
		};
		extension-reloader = self.gnomeExtensions.buildShellExtension {
			pname = "gnome-shell-extension-reloader";
			uuid = "extension-reloader@nls1729";
			version = 12;
			sha256 = "0l1dgkr2k40vy0a3c35s3xr99ff48n1wwc6x4rxg4zdwlbmarrsy";
		};
		tray-icons = self.gnomeExtensions.buildShellExtension {
			pname = "gnome-shell-extension-tray-icons";
			uuid = "tray-icons@zhangkaizhao.com";
			version = 4;
			sha256 = "0viq0wwhhcszsybk2jxhla1chinj552xcc5pbyn55j061aql514r";
		};
	};
}
