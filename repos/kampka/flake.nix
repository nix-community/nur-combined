{
  description = "kampka's NUR repository";

  outputs = { self }: {
    nixosModules = import ./modules;
  };
}
