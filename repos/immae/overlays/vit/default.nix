self: super:
{
  vit = (super.vit.override { inherit (self) taskwarrior; }).overrideAttrs (old:
    self.mylibs.fetchedGithub ./vit.json // {
      buildInputs = old.buildInputs ++ (with self.perlPackages; [ TryTiny TextCharWidth ]);
    }
  );
}
