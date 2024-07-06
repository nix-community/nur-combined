# Hatsu {#module-services-hatsu}

[Hatsu](https://github.com/importantimport/hatsu) is an fully-automated ActivityPub bridge for static sites.

## Service configuration {#modules-services-hatsu-service-configuration}

TODO

```nix
{
  services.hatsu = {
    enable = true;
    host = "127.0.0.1";
    port = 3939;
    settings = {
      HATSU_NODE_NAME = "My Hatsu Instance";
    };
  };
}
```

Please refer to the [Hatsu Documentation](https://hatsu.cli.rs/admins/environments.html)
for additional configuration options.
