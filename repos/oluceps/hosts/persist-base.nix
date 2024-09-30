{ inputs, ... }:
{
  imports = [ inputs.preservation.nixosModules.default ];
  preservation = {
    enable = true;
    preserveAt."/persist" = {
      files = [ ];
      directories = [
        # no /var since regular mount
      ];

      users = {
        root = {
          home = "/root";
          directories = [
            {
              directory = ".ssh";
              mode = "0700";
            }
          ];
          files = [
            ".bash_history"
          ];
        };
      };
    };
  };
}
