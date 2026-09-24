---
name: dependabot-review
description: open な dependabot の PR を一覧し、ユーザーが選んだ対象がマージ可能かをレビューする(デフォルトは check-only)。このリポジトリの dependabot は github-actions のみ。CI・コンフリクト・SHA pin と # vN コメントの整合・semver 区分を確認して ✅/⚠️/❌ を出す。ユーザーが明示的にマージを指示した場合のみ、1 件ずつマージして残りを rebase する。
allowed-tools: Bash(gh pr list:*), Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(gh pr merge:*), Bash(gh pr comment:*), Bash(gh run list:*), Read, Grep, Glob, AskUserQuestion
---

# dependabot-review — dependabot PR マージ可否レビュー(デフォルト check-only)

`.github/dependabot.yml` の ecosystem は `github-actions` だけ。対象ファイルは `.github/workflows/*.y*ml` の `uses:` 行(コミット SHA pin と横の `# vN` コメント)。

`flake.lock` と `pkgs/*/default.nix` の更新は dependabot ではなく GitHub App が作る PR(`update-locks` / `update-<pkg>` ブランチ)で、この skill の対象外。

**デフォルトはチェックと報告のみ。`gh pr merge` / `gh pr close` はユーザーが明示的に指示するまで行わない。**

## 手順

### 1. open な dependabot PR の一覧取得

```
gh pr list --author "app/dependabot" --state open --json number,title,headRefName,createdAt,url
```

0 件なら「open な dependabot PR はありません」と報告して終了する。

### 2. 対象 PR の確認

`$ARGUMENTS` に PR 番号があればそれを対象にする。なければ AskUserQuestion で一覧を提示し、選んでもらう(「すべてレビューする」を選択肢に含める)。

### 3. PR ごとの確認

**基本情報とマージ可否**
```
gh pr view <番号> --json number,title,body,mergeable,mergeStateStatus,changedFiles,url
```
- `mergeable` が `CONFLICTING` ならコンフリクトありと明記する
- `mergeStateStatus` が `BLOCKED` なら理由(CI 未完了等)を推測して記載する

**CI 状態**
```
gh pr checks <番号>
```
- ruleset の必須チェックは `check` 1 本(`build.yml` の `tests` を集約したもの)。`tests` の matrix レグが落ちていればどのチャネルかを記載する
- pending 中なら「CI 実行中のため判定保留」と明記する

**バージョン差分**

- 単独 PR: `title` の `bump X from A to B` から A→B を読む
- group PR(`bump the <group> group ...`): `body` の「Updates `X` from A to B」の列挙から各 action の A→B を読み、最も大きい区分を代表種別にする
- major / minor / patch を判定する。semver として読めなければ「種別不明」

**変更内容**
```
gh pr diff <番号>
```
- 各 `uses:` 行で 40 桁の SHA と横の `# vN` コメントが両方更新されているか確認する。片方だけなら ⚠️
- `.github/workflows/` 以外に差分があれば ⚠️
- major bump なら、body の release notes リンクから `with:` の入力名・出力名・必須入力の追加・Node ランタイム変更(`node20` → `node24` 等)の有無を確認する

### 4. 判定基準

| 判定 | 条件 |
|---|---|
| ✅ マージ推奨 | CI 全て成功 かつ コンフリクトなし かつ minor/patch かつ SHA と `# vN` が揃っている かつ workflows 以外に差分なし |
| ⚠️ 要確認 | major / 種別不明 / CI pending / SHA と `# vN` の不一致 / workflows 以外に差分 / body に breaking changes の言及、のいずれか |
| ❌ マージ非推奨 | CI 失敗 または コンフリクトあり |

⚠️ には **具体的に何を確認すべきか** を必ず書く。release notes の URL(body のリンク、なければ `https://github.com/<owner>/<repo>/releases`)と、このリポジトリで使っている `with:` の入力を挙げて影響を絞る。

### 5. レポート

```
## dependabot PR レビューレポート

| PR | action | バージョン | 種別 | CI | コンフリクト | 判定 | 備考 |
|---|---|---|---|---|---|---|---|
| #12 | actions/checkout | v5→v6 | major | ✅ | なし | ⚠️ 要確認 | persist-credentials の既定値変更を確認 |

### 詳細(⚠️ / ❌ のみ)
- PR 番号ごとに判定理由と確認事項

### 対象外(レビュー未実施)
- 一覧にあったがユーザーが選ばなかった PR
```

末尾に「マージを進める場合は対象 PR 番号を指定してください」と付記し、マージは指示を待つ。

## マージ手順(ユーザー指示があった場合のみ)

- 1 件のみ: `gh pr merge <番号> --squash --delete-branch`
- 2 件以上: 同じ workflow ファイルを触る PR を連続 squash すると、後続 PR の差分が古い main 基準のまま適用されて `uses:` 行が壊れることがある。1 件ずつ進める
  1. `gh pr merge <番号1> --squash --delete-branch`
  2. 残りの各 PR に `gh pr comment <番号2> --body "@dependabot rebase"`
  3. `gh pr checks <番号2> --watch` で CI 完了を待ち、pass なら次をマージする。失敗はユーザーに提示して指示を仰ぐ
  4. 残りがなくなるまで繰り返す
  5. `gh run list --branch main --limit 1` で main の CI 成功を確認する
- rebase でコンフリクトを解消できなかった場合は dependabot が PR にコメントする。自動解決せずユーザーに提示する
- dependabot PR に手動コミットがあると `@dependabot rebase` は拒否される。その場合はユーザーに知らせる
