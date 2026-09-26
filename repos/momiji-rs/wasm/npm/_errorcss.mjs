/**
 * The stylesheet dart writes when a compile fails, so the browser shows
 * the error instead of the last CSS that worked.
 *
 * The native binary already produces this byte for byte; this CLI
 * accepted `--error-css` and did nothing with it, so the two front ends
 * disagreed about the same flag on the same input — and in a `--watch`
 * loop, which is where error CSS earns its keep, the page simply kept
 * showing stale styling.
 *
 * Two renderings go in. The comment carries the ASCII form, the
 * `content:` the Unicode one — that is dart's shape, not a choice here:
 *
 *     /* Error: Undefined operation "1px + red".
 *      *   ,
 *      * 1 | .a { width: 1px + red; }
 *      ...
 *       content: "Error: ...\a   \2577 \a 1 \2502  ...";
 *
 * The binary has the structured error and renders it twice. This CLI is
 * given one string, so the ASCII form is derived from it — see
 * [`asciiGutter`] for why that is a narrower operation than it sounds.
 */

/**
 * The Unicode box drawing in a diagnostic's gutter, swapped for dart's
 * ASCII equivalents.
 *
 * Anchored to the gutter rather than applied to the whole message. A
 * blanket replace would also rewrite those characters where they appear
 * in the SOURCE LINE the diagnostic is quoting — a stylesheet with
 * `content: "│"` in it would have its own text altered on the way into
 * an error report, which dart does not do.
 *
 * The gutter is the first such character on a line, after optional
 * leading spaces and a line number.
 */
export function asciiGutter(message) {
  const swap = { "╷": ",", "│": "|", "╵": "'" };
  return message
    .split("\n")
    .map((line) => line.replace(/^(\s*\d*\s*)([╷│╵])/, (_, pad, box) => pad + swap[box]))
    .join("\n");
}

/**
 * dart escapes a `*​/` inside the message so it cannot close the comment,
 * using U+2215 DIVISION SLASH rather than dropping or spacing it.
 */
function commentBody(ascii) {
  return ascii.replace(/\*\//g, "*∕").replace(/\n/g, "\n * ");
}

/** The `content:` string: CSS string escapes, non-ASCII as `\hex `. */
function contentBody(rendered) {
  let out = "";
  for (const ch of rendered) {
    if (ch === '"') out += '\\"';
    else if (ch === "\\") out += "\\\\";
    else if (ch === "\n") out += "\\a ";
    else if (ch.codePointAt(0) > 0x7f) out += `\\${ch.codePointAt(0).toString(16)} `;
    else out += ch;
  }
  return out;
}

/**
 * The stylesheet for `message`, which is the diagnostic as rendered with
 * Unicode box drawing.
 */
export function errorCss(message) {
  const rendered = message.replace(/\n+$/, "");
  const ascii = asciiGutter(rendered);
  return (
    `/* ${commentBody(ascii)} */\n\n` +
    "body::before {\n" +
    '  font-family: "Source Code Pro", "SF Mono", Monaco, Inconsolata, "Fira Mono",\n' +
    '      "Droid Sans Mono", monospace, monospace;\n' +
    "  white-space: pre;\n" +
    "  display: block;\n" +
    "  padding: 1em;\n" +
    "  margin-bottom: 1em;\n" +
    "  border-bottom: 2px solid black;\n" +
    `  content: "${contentBody(rendered)}";\n` +
    "}\n"
  );
}
