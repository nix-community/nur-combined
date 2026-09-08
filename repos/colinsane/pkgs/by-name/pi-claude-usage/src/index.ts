/**
 * /claude-usage -- show Claude subscription usage inside pi.
 *
 * Shells out to `claude -p "/usage"` (Claude Code's built-in usage report)
 * and renders the output as a chat entry that is not sent to the LLM.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Box, Text } from "@earendil-works/pi-tui";

interface UsageData {
  output: string;
  timestamp: number;
}

// strip ANSI escapes, in case claude ever emits them in print mode
const ANSI_RE = /\x1b\[[0-9;]*m/g;

export default function (pi: ExtensionAPI) {
  pi.registerEntryRenderer<UsageData>("claude-usage", (entry, { expanded }, theme) => {
    const data = entry.data ?? { output: "(no output)", timestamp: Date.now() };
    const box = new Box(1, 1, (text) => theme.bg("customMessageBg", text));
    box.addChild(new Text(theme.fg("accent", "[claude usage]"), 0, 0));
    for (const line of data.output.replace(ANSI_RE, "").split("\n")) {
      box.addChild(new Text(line, 0, 0));
    }
    if (expanded) {
      box.addChild(new Text(theme.fg("dim", new Date(data.timestamp).toLocaleString()), 0, 0));
    }
    return box;
  });

  pi.registerCommand("claude-usage", {
    description: 'Show Claude subscription usage (via `claude -p "/usage"`)',
    handler: async (_args, ctx) => {
      ctx.ui.notify("Fetching Claude usage…", "info");

      let result;
      try {
        result = await pi.exec("claude", ["-p", "/usage"], { timeout: 60_000 });
      } catch (err) {
        ctx.ui.notify("claude-usage: failed to run claude: " + String(err), "error");
        return;
      }

      if (result.killed) {
        ctx.ui.notify('claude-usage: `claude -p "/usage"` timed out after 60s', "error");
        return;
      }

      const output = result.stdout.trim() || result.stderr.trim();
      if (result.code !== 0) {
        ctx.ui.notify("claude-usage: claude exited " + result.code + ": " + output, "error");
        return;
      }

      // print mode has no entry rendering: emit to stdout instead
      if (!ctx.hasUI) {
        process.stdout.write(output + "\n");
      }
      pi.appendEntry<UsageData>("claude-usage", { output, timestamp: Date.now() });
    },
  });
}

