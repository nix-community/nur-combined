{ config, pkgs, lib, ... }: {

  programs.taskwarrior = let keys = "${config.programs.taskwarrior.dataLocation}/keys"; in {
      enable = true;
      config = {
          taskd = {
              certificate = "${keys}/public.cert";
              key = "${keys}/private.key";
              ca = "${keys}/ca.cert";
              server = "samhatfield.me:53589";
              credentials = "personal/sam/2b6c0e0b-c371-4dbb-8169-718c806fe34b";
          };
      };
  };
}
