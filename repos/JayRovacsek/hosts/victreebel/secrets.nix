{
  age.secrets = {
    "git-signing-key" = rec {
      file = ../../secrets/ssh/git-signing-key.age;
      owner = "j.rovacsek";
      path = "/Users/${owner}/.ssh/git-signing-key";
    };

    "git-signing-key.pub" = rec {
      file = ../../secrets/ssh/git-signing-key.pub.age;
      owner = "j.rovacsek";
      path = "/Users/${owner}/.ssh/git-signing-key.pub";
    };

    "j.rovacsek-id-ed25519-sk-type-a-1" = {
      file = ../../secrets/ssh/jay-id-ed25519-sk-type-a-1.age;
      owner = "j.rovacsek";
    };

    "j.rovacsek-id-ed25519-sk-type-a-2" = {
      file = ../../secrets/ssh/jay-id-ed25519-sk-type-a-2.age;
      owner = "j.rovacsek";
    };

    "j.rovacsek-id-ed25519-sk-type-c-1" = {
      file = ../../secrets/ssh/jay-id-ed25519-sk-type-c-1.age;
      owner = "j.rovacsek";
    };

    "j.rovacsek-id-ed25519-sk-type-c-2" = {
      file = ../../secrets/ssh/jay-id-ed25519-sk-type-c-2.age;
      owner = "j.rovacsek";
    };
  };
}
