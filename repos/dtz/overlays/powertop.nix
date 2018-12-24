self: super: {
  powertop = super.powertop.overrideAttrs (o: rec {
    name = "powertop-2.9.0.1"; # not really
    nativeBuildInputs = (o.nativeBuildInputs or []) ++ [ self.autoreconfHook self.git ];
    src = super.fetchgit {
      url = "https://github.com/fenrus75/powertop";
      rev = "16b788f3329beba722d579ea5cc82848e07b48e2";
      sha256 = "1di2x724pkj5sjhhbjpzpvrg2dlfzlsgrz504kfg3ngmhlyb2qqs";
      leaveDotGit = true;
    };

    postPatch = (o.postPatch or "") + ''
      chmod +x scripts/version
      patchShebangs ./scripts/version

      ./scripts/version
    '';
  });
}
