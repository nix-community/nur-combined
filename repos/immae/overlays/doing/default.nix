self: super: {
  defaultGemConfig = super.defaultGemConfig // {
    doing = attrs: {
      postInstall = ''
        installPath=$(cat $out/nix-support/gem-meta/install-path)
        sed -i $installPath/lib/doing/wwid.rb -e "/Create a backup copy for the undo command/ {n;d}"
      '';
    };
  };
}
