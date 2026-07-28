{
  deno,
  lib,
  nix,
  writeShellApplication,
}:

{
  config,
  name,
}:

writeShellApplication {
  name = "update-${name}";
  text = ''
    exec ${lib.getExe deno} run \
      --no-prompt \
      --allow-env=GH_TOKEN,GITHUB_TOKEN \
      --allow-net=api.github.com \
      --allow-read=.,${config} \
      --allow-run=${lib.getExe nix} \
      --allow-write=. \
      ${./main.ts} \
      ${config} \
      ${lib.getExe nix}
  '';
}
