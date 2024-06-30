# Changelog

All notable changes to this project will be documented in this file.

Updates follow a [conventional commit][commits] style and the project is
versioned with [calendar versioning][calver]. Breaking changes sometimes happen
and are noted with a `!` in the message.

## Changes

- docs: note the required steps for calling whole package derivations 2024-06-29
- feat(pkgs/proximity-nvim): help find the nearest matching file fast 2024-06-29
- ci(fix): build darwin programs on darwin runners to avoid breakings 2024-06-28
- docs: remember flake changes needed to use local package definition 2024-06-28
- ci(fix): attempt to build packages on all systems in spite of fails 2024-06-28
- feat(pkgs/gon): package the program that signs and notarizes darwin 2024-06-28
- build(macos): perform cache builds on both macos and ubuntu runners 2024-06-27
- build(cachix): compile and cache built binaries for faster installs 2024-06-27
- docs: instruct installation of private packages into project flakes 2024-06-27
- feat(pkgs/etime): package an energy aware time command for measures 2024-06-27
- ci(feat): use the determinate systems installer for some flaked nix 2024-06-01
- ci(fix): set the github access token as input to the cachix install 2024-06-01
- build(ci): remove support of deprecated releases and track unstable 2024-06-01
- docs: direct link to the action job that builds and populates cache 2024-06-01
- docs: write references from recent learnings for future maintenance 2024-05-29
- fix(pkgs/zsh-wd): remove some unknown maintainers to pass ci checks 2024-05-26
- feat(pkgs/zsh-wd): initialize the zsh-wd package at a version 0.7.0 2024-05-26
- feat(build): target build support for aarch64 darwin flaked systems 2024-05-26
- feat: configure the nur packages template with replaced boilerplate 2024-05-26

[calver]: https://calver.org
[commits]: https://www.conventionalcommits.org/en/v1.0.0/
