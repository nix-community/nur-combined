# version の自動更新 — セットアップ手順

`Hol1kgmg/claude-temp` の `update-locks` と同じ構成。

毎週土曜、2つの workflow が走る。

| workflow            | 時刻 (JST) | 更新対象                                    | auto-merge |
| ------------------- | ---------- | ------------------------------------------- | ---------- |
| `update-locks`      | 09:00      | `flake.lock`                                | あり       |
| `update-packages`   | 09:30      | `pkgs/*/default.nix` の version と hash     | あり（openscreen-for-mac を除く） |

どちらも `workflow_dispatch` で手動実行できる。`update-packages` は入力で対象パッケージを1つに絞れる。固定ブランチ (`update-locks` / `update-<pkg>`) を使うため、マージされずに残っても PR の本数は増えない。

Dependabot に Nix の ecosystem は無いため、`.github/dependabot.yml` が見るのは workflow の SHA pin だけ。

## 更新の流れ

`update-packages` はパッケージごとに独立したジョブで動く。

1. 公開から2日以上経った最新の安定版を調べる（`MIN_AGE_DAYS`）。`update.sh` を持つパッケージはそれを実行し、他は GitHub Releases を見る。prerelease と draft は除外する
2. `just bump <pkg> <version>` で version / rev / src hash を書き換える
3. `just fix-hashes <pkg>` が `nix build` を回し、失敗が報告する `got:` から残りの hash（`cargoHash`、`npmDepsHash`）を解決する
4. PR を作り、`build.yml` が通れば auto-merge

`update.sh` を持つのは、`just bump` の前提（`fetchFromGitHub` の owner/repo と tag）を満たさないパッケージ。

- `openscreen-for-mac` — GitHub Releases の .dmg を2つ pin している
- `markserv` — upstream に git tag が無く、npm の tarball が source。`package-lock.json` も vendor している
- `herdr` — version 自体は `just bump` で上がるが、vendor した `build.zig.zon.nix` を取り直す必要がある

## herdr の build.zig.zon.nix

upstream の `vendor/libghostty-vt/build.zig.zon.nix` をこのリポジトリに取り込んである。`callPackage "${src}/vendor/..."` と書くと IFD になり、`build.yml` の `nix-env -qa`（読み取り専用の評価ストア）が src の `.drv` を書けずに落ちる。NUR の評価器も IFD を通さない。

取り込んだファイルは version と対で意味を持つので、`update.sh` が `just bump` の後に同じ tag から取り直し、zon2nix の生成物であることを確認している。

同じ理由で `cargoLock.lockFile = "${src}/Cargo.lock"` も使えない（評価時に src を読むため IFD になる）。`cargoHash` を置いてあり、version を上げた後は `just fix-hashes herdr` が解決する。

IFD が残っていないかは、評価チェックを `--option allow-import-from-derivation false` で回せば確認できる。ストアに実体化済みの derivation があると `true` のままでは見逃すことがある。

## 1. GitHub App

権限は `Contents: Read and write` と `Pull requests: Read and write` のみ。このリポジトリにインストールし、`APP_ID` と `APP_PRIVATE_KEY` を Secrets に登録する。

`GITHUB_TOKEN` では成立しない。それが作成した PR は workflow を発火させないため、必須チェックが付かず auto-merge が永久に止まる。

## 2. ブランチ保護

main を保護し、必須チェックに `build.yml` の `check` ジョブを指定する。リポジトリ設定で auto-merge を有効化する。

設定しないと `--auto` は待つ相手が無く即マージになり、更新が検証を経ずに通る。`tests` は matrix でチェック名が変わるため直接指定しない。matrix から要素を外すと、その名前の必須チェックが永久に pending になり auto-merge が止まる。

## 既知の弱点

**openscreen-for-mac は CI で検証されない。** darwin 専用の .dmg を pin しているため、ubuntu の runner ではビルドできない。version と hash を更新した PR は作るが、auto-merge の対象からは外してある。手元で `just build openscreen-for-mac` を通してからマージする。`build.yml` に macos-latest のジョブを足せば自動化できる。

**`flake.lock` の更新も同じ穴を持つ。** nixpkgs の更新は全パッケージに影響するが、ubuntu の CI が見られるのは darwin 以外だけ。

**スケジュール実行はリポジトリが60日間無活動になると自動停止する。** 静かに止まるため気づきにくい。

**`update-packages` は書き込み権限を持つジョブの中で upstream のソースをビルドする。** トークンの発行をビルドより後の step に置いて窓を狭めてはいるが、同じ runner である以上は分離しきれていない。権限を Contents / Pull requests に絞り、ブランチ保護を迂回しないことで影響を抑えている。
