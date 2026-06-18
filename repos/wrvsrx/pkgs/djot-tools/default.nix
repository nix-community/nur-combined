{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-7pNIQ7YJmC09fqYqWe8A0hUHIp9xTPxI53pM6elcsv4=";
  };

  cargoHash = "sha256-6xzl9oEqcqXtjPwQpX1jT1hxicGvyE4J5fM+FG2JmQE=";
})
