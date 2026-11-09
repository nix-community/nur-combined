# DSH plugins

Add plugins to your [Home Manager configuration](../deepseek-harness/README.md).

| Plugin | Purpose |
| --- | --- |
| `npm:dsh-chat-import` | Import and export conversations |
| `npm:dsh-context` | Inspect and manage context |
| `github:kingcharleslzy-ai/dsh-purge` | Customize prompts and run red-team evaluations |
| `npm:@anionex/dsh-turn-rewind` | Rewind conversations and workspace changes |
| `npm:@ychris12138/dsh-usage-stats` | Track usage, costs and budgets |

Official bundles use the same format, such as `npm:@deepseek-ai/dsh-base`
and `npm:@deepseek-ai/dsh-web-app`.

## Purge

Enabling purge changes prompts, approvals and sandbox behavior for **all
profiles** using the same dsh installation. Remove it from every profile to
undo these changes. Manage its installation through Nix; prompt editing still works.

Purge uses the [`kingcharleslzy-ai/dsh-purge`](https://github.com/kingcharleslzy-ai/dsh-purge)
community edition, packaged as `dsh-purge-community`. Replace
`github:YuJunZhiXue/dsh-purge` in existing profiles with
`github:kingcharleslzy-ai/dsh-purge` when updating.

## Updating

Update your NUR or flake input to update dsh and its plugins.
