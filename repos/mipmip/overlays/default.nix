final: prev: {


  sc-im = prev.sc-im.overrideAttrs (old: {
    hardeningDisable = [ "fortify" ];
    src = prev.fetchFromGitHub {
      version = "0.8.5";
      owner = "mipmip";
      repo = "sc-im";
      rev = "pimsMain";
      hash = "sha256-8KwGDEmr182ippdoeNVvNMFN6+iJu83xkX7xMbI5/No=";
    };
  });

  quarto = prev.quarto.override {
    extraPythonPackages = ps: with ps; [
      plotly
      numpy
      pandas
      matplotlib
      tabulate
    ];
  };

  nnn = (prev.nnn.override {
    withNerdIcons = true;
  }).overrideAttrs
    (oldAttrs: {
      # Required for O_PCRE=1
      buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ final.pcre ];
      # Custom compile options
      makeFlags = (oldAttrs.makeFlags or [ ]) ++ [
        "O_PCRE=1" # Enable PCRE regex support
        "O_NOBATCH=1" # Disable built-in batch renamed in favor of .nmv plugin
        "O_NOUG=1" # Don't display user or group info in status bar to save memory
        "O_QSORT=1" # Use Alexey Tourbin's QSORT
        #"O_CTX8=1" # Use 8 contexts instead of 4
        # Patches
        "O_GITSTATUS=1" # Show git status in detail mode (and normal mode with -G)
        "O_NAMEFIRST=1" # Print filenames first in detail mode
      ];
      postInstall = (oldAttrs.postInstall or "") + ''
        # Install plugins
        mkdir -p $out/share/plugins
        install -D -m755 plugins/* $out/share/plugins
        # Install quitcd
        mkdir -p $out/share/quitcd
        install -D -m644 misc/quitcd/* $out/share/quitcd
      '';
    });
}
