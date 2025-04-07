{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:

buildGoModule {
  pname = "fabric-cli";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric-cli";
    rev = "ed7da8aeed726abb9cb0603efa83b693b91d3159";
    hash = "sha256-NatSzI0vbUxwvrUQnTwKUan0mZYJpH6oyCRaEr0JCB0=";
  };

  vendorHash = "sha256-3ToIL4MmpMBbN8wTaV3UxMbOAcZY8odqJyWpQ7jkXOc="; # Update this after the first build

  meta = {
    description = "An alternative super-charged CLI for Fabric ";
    longDescription = ''
      Fabric CLI is a tool to interface with running fabric instances.
      This enables e.g. invoking actions or executing python code within a running instance.
    '';
    homepage = "https://github.com/Fabric-Development/fabric-cli";
    license = lib.licenses.agpl3Only;
    mainProgram = "fabric-cli";
    maintainers = [
      {
        email = "heyimkyu@mailbox.org";
        github = "HeyImKyu";
        githubId = 43815343;
        name = "Kyu";
      }
    ];
  };
}
