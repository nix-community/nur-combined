{ self }: let inherit (self.inputs) agenix; in agenix.nixosModules.default
