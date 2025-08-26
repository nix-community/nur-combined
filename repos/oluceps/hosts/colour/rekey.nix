{ data, ... }:
{
  vaultix = {
    settings.hostPubkey = data.keys.colourHostPubKey;

    secrets = {
      prom = {
        file = ../../sec/prom.age;
        mode = "640";
        owner = "prometheus";
        group = "users";
      };
    };
  };
}
