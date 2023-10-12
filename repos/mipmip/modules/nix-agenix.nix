{
  age.secrets = {

    pim-desktop-password.file = ../secrets/pim-desktop-password.age;

    openai-api-key = {
      file = ../secrets/openai-api-key.age;
      path = "/tmp/openaiapikey";
      owner = "pim";
      group = "users";
      mode = "600";
    };
  };
}
