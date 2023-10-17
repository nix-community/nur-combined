{
  age.secrets = {

    openai-api-key = {
      file = ../secrets/openai-api-key.age;
      path = "/tmp/openaiapikey";
      owner = "pim";
      group = "users";
      mode = "600";
    };
  };
}
