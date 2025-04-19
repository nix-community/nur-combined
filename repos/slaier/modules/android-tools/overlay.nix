final: prev: {
  android-tools = prev.android-tools.overrideAttrs (self:
    {
      patches = self.patches or [ ] ++ [
        ./user_home.patch
      ];
    });
}
