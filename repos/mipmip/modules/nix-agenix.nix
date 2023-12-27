{
  age.secrets = {

    openai-api-key = {
      file = ../secrets/openai-api-key.age;
      path = "/tmp/openaiapikey";
      owner = "pim";
      group = "users";
      mode = "600";
    };
    openai-api-key-plan = {
      file = ../secrets/openai-api-key-plain.age;
      path = "/tmp/openaiapikey-plain";
      owner = "pim";
      group = "users";
      mode = "600";
    };
  };
}
