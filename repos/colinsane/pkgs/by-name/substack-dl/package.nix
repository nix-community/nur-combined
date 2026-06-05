# XXX(2026-01-01): this script *works*, and is very fast,
# but it seems to only download the 20 most recent posts.
# it only captures markdown versions of each post.
{
  fetchFromGitHub,
  lib,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "substack-dl";
  version = "0-unstable-2022-08-08";

  src = fetchFromGitHub {
    owner = "nosajio";
    repo = "substack-dl";
    rev = "866b2566f9244374e7df5f0f404098c5f81e7b06";
    hash = "sha256-F8497VhGZXCyYd2pHaJKr1WXWKEbUSSQ+3LaA1cnZXs=";
  };

  cargoHash = "sha256-qrhGpYT7dRgs/Isfb1mWceFoN93fuhH7l0i08wm4ZCw=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Download all public posts from any Substack newsletter";
    longDescription = ''
      A small cli tool that downloads the public posts from a substack newsletter and saves them locally.

      ## How to use
      ```sh
      substack-dl url save-dir [--overwrite] [--fmt-html] [--fmt-all]
      ```

      ## Example
      ```sh
      substack-dl nosaj.substack.com ~/save_posts_location --overwrite --fmt-all
      ```

      ## Todo:
      - [x] Download and parse posts.
      - [x] Save posts to disk as markdown files.
      - [ ] Unit tests for fs operations.
      - [ ] Implement non-tmp functionality.
      - [ ] Implement overwrite flags.
      - [ ] Implement HTML save.
      - [ ] Implement format flags.
    '';
    homepage = "https://github.com/nosajio/substack-dl";
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
