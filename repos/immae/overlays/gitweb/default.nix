self: super: {
  gitweb = super.gitweb.overrideAttrs(old: {
    installPhase = old.installPhase + ''
      cp -r ${./theme} $out/gitweb-theme;
      '';
  });
}
