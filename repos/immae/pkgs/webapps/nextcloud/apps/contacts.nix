{ buildApp }:
buildApp rec {
  appName = "contacts";
  version = "3.1.1";
  url = "https://github.com/nextcloud/${appName}/releases/download/v${version}/${appName}.tar.gz";
  sha256 = "1qfn532p1pb4m6q2jzyzlyw4c5qccmq6vj0h2zv9xfkajfvz7i7v";
}
