{
  callPackages,

  beamPackages,

  bun,
  bun2nix,

  runCommandLocal,
  tailwindcss_4,
  ...
}:
beamPackages.mixRelease {
  pname = "bun2nix_phoenix";
  version = "0.1.0";

  src = ./.;

  mixNixDeps = callPackages ./deps.nix { };

  nativeBuildInputs = [
    bun2nix.hook
  ];

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./assets/bun.nix;
    overrides = {
      "@tailwindcss/cli@4.1.17" =
        pkg:
        runCommandLocal "tailwind-cli" { } ''
          mkdir "$out"
          cp -r ${pkg}/. "$out"

          chmod -R u+w $out

          cp "${tailwindcss_4}/bin/tailwindcss" "$out/dist/index.mjs"
        '';
    };
  };

  bunRoot = "assets";

  DATABASE_URL = "";
  SECRET_KEY_BASE = "";

  removeCookie = false;

  postBuild = ''
    bun_path="$(mix do \
      app.config --no-deps-check --no-compile, \
      eval 'Bun.bin_path() |> IO.puts()')"

    ln -sfv ${bun}/bin/bun "$bun_path"

    mix do \
      app.config --no-deps-check --no-compile, \
      assets.deploy --no-deps-check
  '';
}
