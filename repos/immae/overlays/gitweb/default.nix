self: super: {
  gitweb = super.gitweb.overrideAttrs(old: {
    postBuild = old.postBuild or "" + ''
      cp -r ${./theme} $out/gitweb-theme;
      '';
  });
}
