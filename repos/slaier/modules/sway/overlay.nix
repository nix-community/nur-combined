final: prev: {
  sway-unwrapped = prev.sway-unwrapped.overrideAttrs (self:
    {
      patches = self.patches or [ ] ++ [
        ./0001-text_input-Implement-input-method-popups.patch
      ];
    });
}
