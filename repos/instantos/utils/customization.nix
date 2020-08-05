# Examle for customizing instantwm packages

(import ./.. { pkgs=import <nixpkgs> {}; }).extend (self: super: {
  instantwm = (super.instantwm.override {
    defaultTerminal = self.pkgs.kitty;
    
    wmconfig = ./customconfig.h;
    # or just patch the original:
    #extraPatches = [ ./some/patch.diff ./an/other/patch.diff ]
  });
})
