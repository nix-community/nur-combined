# Spotlight extensions · API v1

Keep legacy executable scripts in `$XDG_DATA_HOME/spotlight/scripts` (normally `~/.local/share/spotlight/scripts`). They continue to run as before. A manifest extension lives in a subdirectory with a `manifest.json`, or uses a `.json` manifest directly in the scripts directory.

Native script extensions (`runtime: "process"`, the default) have your normal user privileges. Install scripts you trust. For sandboxed plugins, use `runtime: "wasm"` and a `module` instead of `command`: see [WASM plugins and SDKs](WASM.md). WASM plugins live under `$XDG_DATA_HOME/spotlight/plugins`; this directory rejects native process manifests. Opening Script Commands only discovers manifests; it does not run them.

```json
{
  "schema_version": 1,
  "id": "greet",
  "name": "Greeting",
  "description": "Create a greeting",
  "icon": "utilities-terminal-symbolic",
  "command": ["python3", "main.py"],
  "mode": "command",
  "args": [
    {"name": "name", "placeholder": "Your name", "required": true, "default": ""}
  ],
  "timeout_ms": 5000
}
```

The [manifest schema](extension.schema.json) describes the format. For process extensions, `command` is an argument vector, never a shell command string. Relative executable paths resolve from the manifest directory, which is also the process working directory. Literal argument values are appended to `command`; there is no shell interpolation. Interpreter-based extensions can use any installed runtime. The core launcher needs no Python runtime.

`icon` can be a theme icon name, a short emoji, or a relative image file inside the extension directory (at most 256 KiB). Result icons use the same rules. Paths that resolve outside the directory are ignored.

`mode: "command"` runs only after Enter or Run Extension. Choosing it from Script Commands or main search opens an argument form when arguments are declared. You can also type `ext greet "two words"` and press Enter on Run. Quotes and backslashes group literal arguments; `$()` and variables are not expanded. `default` fills the form, and `required` rejects empty values.

`mode: "search"` runs after a 350 ms typing delay when you explicitly type `ext <id> <query>` or `plugin <id> <query>`. The whole query is passed as one argument and in `SPOTLIGHT_QUERY`. Every extension receives `SPOTLIGHT_EXTENSION_API=1`. Search-mode manifests normally omit `args`. Selecting a search extension puts its `ext <id>` prefix in the search field.

Write one UTF-8 JSON object per line to stdout, flushing each update. Results appear while the process is still running:

```jsonl
{"type":"status","text":"Searching…"}
{"type":"result","id":"first","title":"First result","subtitle":"Ready immediately","action":{"type":"copy","text":"hello"}}
{"type":"result","id":"second","title":"Second result","icon":"face-smile-symbolic","action":{"type":"open","url":"https://example.com"}}
{"type":"done"}
```

A `result` with the same `id` updates the existing row. `{"type":"results","items":[...]}` replaces the entire result set; array items have the result fields without `type`. `status` updates the footer row. `done` finishes the stream and terminates the extension's process group; alternatively, exit successfully after the last result. A nonzero exit reports a bounded stderr excerpt. Invalid output reports an error while retaining results already received.

Result actions:

- `{"type":"copy","text":"..."}` copies text when selected.
- `{"type":"open","url":"..."}` opens an HTTP, HTTPS, or file URL when selected.
- `{"type":"run","args":["literal","arguments"]}` runs the same declared command again with those arguments when selected.
- Omitting `action` creates an informational row.

Receiving results never triggers their actions. Changing the query, hiding Spotlight, or pressing Escape cancels a running extension and its process group. Ctrl+R reruns a search extension; command extensions still require Enter to execute. Extension result contents and arguments are not saved in usage history.

Limits: 64 manifests, 32 KiB per manifest, 16 user arguments of 4 KiB each, timeout 100–30,000 ms (default 5,000), stdout 1 MiB, one JSON line 64 KiB, 50 visible results, and 100 individual result updates. Result IDs are at most 128 bytes, titles 1 KiB, subtitles 8 KiB, copy text 64 KiB, and status messages 1 KiB. Manifest validation rejects unsupported versions and unknown fields. Limits apply to UTF-8 bytes at runtime.

Try the examples by copying `examples/extensions/greet` or `examples/extensions/live-demo` into your Spotlight scripts folder, then reopen Script Commands. They use Python 3's standard library only.
