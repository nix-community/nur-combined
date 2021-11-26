{ pkgs, name ? "world" }:
{
  description = "Hello";
  path = pkgs.writeTextFile {
    name = "scratch";
    text = "Hello, ${name}";
  };
}
