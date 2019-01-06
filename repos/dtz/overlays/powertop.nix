self: super: {
  /*
  powertop = super.powertop.overrideAttrs (o: rec {
    name = "${pname}-${version}";
    pname = "powertop";
    version = "2.10";

    nativeBuildInputs = (o.nativeBuildInputs or []) ++ [ self.autoreconfHook self.git ];
    src = super.fetchgit {
      url = "https://github.com/fenrus75/powertop";
      #rev = "16b788f3329beba722d579ea5cc82848e07b48e2";
      rev = "v${version}";
      sha256 = "0nvfjx6w4vx7d2k7s082hmdadm1x0y44639wp47vprjbnki7qs6r";
      leaveDotGit = true;
    };

    postPatch = (o.postPatch or "") + ''
      chmod +x scripts/version
      patchShebangs ./scripts/version

      ./scripts/version
    '';
  });
  */
}
