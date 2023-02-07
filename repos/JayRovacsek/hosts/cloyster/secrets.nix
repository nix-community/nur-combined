{
  # G'day future self - move this file to default location:
  # /etc/ssh/ssh_host_ed25519_key
  # identityPaths = [ /Users/jrovacsek/.ssh/ssh_host_ed25519_key ];
  age.secrets = {
    jrovacsek-id-ed25519-sk-type-a-1 = {
      file = ../../secrets/ssh/jay-id-ed25519-sk-type-a-1.age;
      owner = "jrovacsek";
    };

    jrovacsek-id-ed25519-sk-type-a-2 = {
      file = ../../secrets/ssh/jay-id-ed25519-sk-type-a-2.age;
      owner = "jrovacsek";
    };

    jrovacsek-id-ed25519-sk-type-c-1 = {
      file = ../../secrets/ssh/jay-id-ed25519-sk-type-c-1.age;
      owner = "jrovacsek";
    };

    jrovacsek-id-ed25519-sk-type-c-2 = {
      file = ../../secrets/ssh/jay-id-ed25519-sk-type-c-2.age;
      owner = "jrovacsek";
    };
  };
}
