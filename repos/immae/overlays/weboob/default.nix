self: super: {
  weboob = (self.pythonPackages.weboob.overridePythonAttrs {
    setupPyBuildFlags = [ "--no-qt" "--xdg" ];
  }).overrideAttrs (old: rec {
    version = "1.5";
    src = self.fetchurl {
      url = "https://git.weboob.org/weboob/weboob/-/archive/${version}/${old.pname}-${version}.tar.gz";
      sha256 = "0l6q5nm5g0zn6gmf809059kddrbds27wgygxsfkqja9blks5vq7z";
    };
    postInstall = ''${old.postInstall or ""}
      mkdir -p $out/share/bash-completion/completions/
      cp tools/weboob_bash_completion $out/share/bash-completion/completions/weboob
    '';
  });
}
