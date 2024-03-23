final: prev: {
  aria2 = prev.aria2.overrideAttrs (self:
    {
      patches = self.patches or [ ] ++ [
        ./ban.patch
      ];
    });
}
