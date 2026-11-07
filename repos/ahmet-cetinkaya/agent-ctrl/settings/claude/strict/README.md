# claude-strict

`claude-strict` starts Claude Code with the Bash sandbox on, on top of auto mode. Use it for code you do not trust, such as a downloaded repository or a pull request from outside, or when you want an operating-system guard under the classifier. `claude` starts without the sandbox.

| File | Purpose |
| --- | --- |
| `launcher.sh` | The `claude-strict` function in `zsh/common.zshrc` calls it. It reads `settings.json` here, adds what depends on the working directory, and starts `claude` with the result in `--settings`. |
| `settings.json` | The sandbox policy: what a command may read, write, and reach, and which commands run outside the sandbox. |
| `sandbox-no-sockets.props` | MSBuild import that builds projects one after another inside the sandbox. |

`--settings` outranks the user settings, so the sandbox is on while the other settings, such as the model, the hooks, auto mode, and the secret read denies, come from `~/.claude/settings.json`.

## What the sandbox does

- **Reads.** A directory in `denyRead`, such as `~/.ssh`, appears empty to a command. A file such as `.env` is denied, and `~/.nuget/NuGet/NuGet.Config` is opened with `allowRead`, because NuGet reads it on every restore.
- **Writes.** A command writes the working directory, every worktree of the repository, `/tmp`, the temp directory, `~/.npm`, and the .NET, NuGet, and Aspire state directories. Shell startup files, `~/Configs/zsh`, `~/Configs/nixos`, the Claude settings, `~/.aspire/bin`, and the user `bin` directories are write-denied. The `.git` file and `.claude` directory of every worktree, and the `hooks` and `config` of the shared git directory, are write-denied too, because unsandboxed commands run what they hold.
- **Network.** `allowedDomains` lists the hosts every session needs. Any other host asks once.
- **Secrets.** `credentials.envVars` removes the gateway and API tokens from the environment of a command.
- **Outside the sandbox.** `excludedCommands` runs `gh`, `git commit`, `git push`, `git fetch`, `git pull`, `git branch`, `podman`, `docker`, `aspire`, `agent-browser`, and the Playwright runners with full access, because they need credentials or Unix sockets. With auto mode on, the classifier reviews each of them. The unsandboxed retry is closed (`allowUnsandboxedCommands: false`), so a command that fails in the sandbox does not leave it.

## Known limits

- **A command matches only when it runs on its own.** `cmd && git commit`, `git -C <path> push`, a pipe after `gh`, and a `NAME=value` in front all stay in the sandbox and fail there.
- **No Unix sockets.** A browser started another way, `nix-shell`, `nix develop`, and D-Bus fail in the sandbox. Start the session from a shell that already has the environment.
- **Builds run one after another.** Inside the sandbox, MSBuild cannot start worker nodes. `sandbox-no-sockets.props` turns the parallelism off where `SANDBOX_RUNTIME` is set, and a solution file also needs `-m:1`.
- **Excluded commands run with full access.** Each of them can run code, for example a hook in a nested repository, or a compose file that mounts a host path.
- **Do not deny a glob over `/proc`.** The sandbox expands every glob into mount arguments, and a `/proc` glob exceeds the limit so no command starts.
- **Do not mask `GH_TOKEN`, and do not set `network.tlsTerminate`.** The sandbox then fails to start without an error, and commands run unsandboxed.
