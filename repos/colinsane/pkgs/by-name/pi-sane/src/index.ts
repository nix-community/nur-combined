import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("reset", {
    description: "Start a new session but preserve the selected model",
    handler: async (_args, ctx) => {
      const firstEntry = ctx.sessionManager.getEntries()[0];
      if (!firstEntry) {
        return;
      }

      // ctx.newSession() would reset the selected model;
      // rewinding to the earliest entry preserves the model, but resets the context of the session instead.
      // N.B.: this still leaves the other conversation entries reachable via `/tree`.
      // TODO: delete any other entries, so that `/tree` is clean.
      await ctx.navigateTree(firstEntry.id);
      ctx.ui.setEditorText("");
    },
  });

  pi.registerCommand("prev", {
    description: "Rewind one step in the conversation",
    handler: async (_args, ctx) => {
      // A null leaf is already an empty conversation. In particular, this
      // makes repeated /prev commands stop cleanly at the beginning.
      if (!ctx.sessionManager.getLeafId()) {
        return;
      }

      const branch = ctx.sessionManager.getBranch();
      const userIndexes = branch.flatMap((entry, index) =>
        entry.type === "message" && entry.message.role === "user" ? [index] : [],
      );
      if (userIndexes.length === 0) {
        return
      } else if (userIndexes.length === 1) {
        // The first turn is the only turn, so rewinding it produces an empty
        // context. Use reset's root entry without creating a new session.
        const firstEntry = ctx.sessionManager.getEntries()[0];
        if (firstEntry) {
          await ctx.navigateTree(firstEntry.id);
        }
      } else if (userIndexes.length !== 0) {
        const latestUserIndex = userIndexes[userIndexes.length - 1];
        const previousUserIndex = userIndexes[userIndexes.length - 2];

        // Keep the preceding turn by navigating to its assistant response.
        const assistantIndex = branch.findIndex(
          (entry, index) => index > previousUserIndex &&
            index < latestUserIndex &&
            entry.type === "message" && entry.message.role === "assistant",
        );
        if (assistantIndex === -1) {
          await ctx.navigateTree(branch[previousUserIndex].id);
        } else {
          await ctx.navigateTree(branch[assistantIndex].id);
        }
      }
      ctx.ui.setEditorText("");
    },
  });
}
