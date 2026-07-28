self: super: {
  bitwarden-desktop = super.bitwarden-desktop.override { electron_39 = self.electron_42; };
}
