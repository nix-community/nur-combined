{ inputs, overlays, mkNixos }:

let
  baseUsers = {
    system = [ "root" "bjorn" ];
    hm = [ "bjorn" ];
  };

in
{
  eyjafjallajokull = mkNixos {
    inherit inputs overlays;
    users = baseUsers.system;
    hostname = "eyjafjallajokull";
    enable-impermanence = true;
    enable-sops = true;
    enable-hm = true;
    hm-users = baseUsers.hm;
    enable-sops-hm = true;
  };

  holuhraun = mkNixos {
    inherit inputs overlays;
    users = baseUsers.system;
    hostname = "holuhraun";
    enable-impermanence = true;
    enable-sops = true;
    enable-hm = true;
    hm-users = baseUsers.hm;
    enable-impermanence-hm = true;
    enable-sops-hm = true;
  };

  torfajokull = mkNixos {
    inherit inputs overlays;
    users = baseUsers.system;
    hostname = "torfajokull";
    enable-impermanence = true;
    enable-sops = true;
    enable-hm = true;
    hm-users = baseUsers.hm;
    enable-sops-hm = true;
  };

  Katla =
    let
      users = [ "nixos" ];
    in mkNixos {
      inherit inputs overlays users;
      hostname = "katla";
      hm-users = users;
      extra-special-args = { inherit users; };
    };

  vm = mkNixos {
    inherit inputs overlays;
    users = [ "root" ];
    hostname = "raudholar";
  };
}
