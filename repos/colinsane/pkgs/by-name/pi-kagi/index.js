import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { Type } from 'typebox';
import { Text } from '@earendil-works/pi-tui';

const execFileAsync = promisify(execFile);

async function runKagi(args, signal) {
  try {
    const { stdout, stderr } = await execFileAsync('kagi-ken-cli', args, {
      encoding: 'utf8',
      maxBuffer: 10 * 1024 * 1024,
      signal,
    });
    return { stdout: stdout.trim(), stderr: stderr.trim() };
  } catch (error) {
    const stderr = typeof error?.stderr === 'string' ? error.stderr.trim() : '';
    const stdout = typeof error?.stdout === 'string' ? error.stdout.trim() : '';
    const message = stderr || stdout || error?.message || String(error);
    throw new Error(`kagi-ken-cli failed: ${message}`);
  }
}

function prettyJson(text) {
  if (!text) return '';
  try {
    return JSON.stringify(JSON.parse(text), null, 2);
  } catch {
    return text;
  }
}

// function clampLimit(limit) {
//   if (limit === undefined) return undefined;
//   if (!Number.isFinite(limit)) return undefined;
//   return String(Math.max(1, Math.min(50, Math.trunc(limit))));
// }

function content(text) {
  return { content: [{ type: 'text', text }], details: {} };
}

export default function piKagi(pi) {
  pi.registerTool({
    name: 'web_search',
    label: 'Kagi Web Search',
    description:
      'Search the web with Kagi. Use for current information, documentation, external facts, and source discovery.',
    promptSnippet: 'Search the web for external information and documentation',
    promptGuidelines: [
      'Use web_search proactively when you encounter an unfamiliar library or a cryptic error message that cannot be resolved by reading local resources.',
      'Use web_search to discovery primary sources before responding to the user with uncertain claims',
    ],
    parameters: Type.Object({
      query: Type.String({ description: 'Search query' }),
      // TODO(2026-06-18): `kagi-ken-cli search --limit N PHRASE` doesn't honor the limit
      // limit: Type.Optional(
      //   Type.Number({
      //     description: 'Maximum number of results to return, default 10, maximum 50',
      //     minimum: 1,
      //     maximum: 50,
      //   }),
      // ),
    }),
    renderCall(args, theme) {
      let text = theme.fg('toolTitle', theme.bold('web_search '));
      text += theme.fg('dim', `"${args.query}"`);
      // if (args.limit) {
      //   text += theme.fg('muted', ` (limit ${args.limit})`);
      // }
      return new Text(text, 0, 0);
    },
    async execute(_toolCallId, params, signal) {
      const args = ['search', params.query];
      // const limit = clampLimit(params.limit);
      // if (limit) args.push('--limit', limit);
      const { stdout, stderr } = await runKagi(args, signal);
      const body = prettyJson(stdout);
      const note = stderr ? `\n\nstderr:\n${stderr}` : '';
      return content(`Kagi search results for: ${params.query}\n\n${body}${note}`);
    },
  });

  // TODO(2026-06-18): `kagi-ken-cli summarize --url $URL` -> "Failed to parse summary JSON response"
  // pi.registerTool({
  //   name: 'summarize',
  //   label: 'Kagi Summarize',
  //   description:
  //     'Summarize a URL or text with Kagi Summarizer.',
  //   promptSnippet: 'Summarize a URL or text',
  //   promptGuidelines: [
  //     'Use summarize for long web pages or pasted text when a concise summary or takeaway list is useful.',
  //     'Provide either url or text, not both.',
  //   ],
  //   parameters: Type.Object({
  //     url: Type.Optional(Type.String({ description: 'URL to summarize' })),
  //     text: Type.Optional(Type.String({ description: 'Text content to summarize' })),
  //     language: Type.Optional(
  //       Type.String({ description: 'Two-character target language code, default EN' }),
  //     ),
  //     type: Type.Optional(
  //       Type.Union([
  //         Type.Literal('summary'),
  //         Type.Literal('takeaway'),
  //       ], { description: 'Summary type, default summary' }),
  //     ),
  //   }),
  //   async execute(_toolCallId, params, signal) {
  //     if (Boolean(params.url) === Boolean(params.text)) {
  //       throw new Error('Provide exactly one of url or text');
  //     }

  //     const args = ['summarize'];
  //     if (params.url) args.push('--url', params.url);
  //     if (params.text) args.push('--text', params.text);
  //     if (params.language) args.push('--language', params.language);
  //     if (params.type) args.push('--type', params.type);

  //     const { stdout, stderr } = await runKagi(args, signal);
  //     const body = prettyJson(stdout);
  //     const source = params.url ? `URL: ${params.url}` : 'provided text';
  //     const note = stderr ? `\n\nstderr:\n${stderr}` : '';
  //     return content(`Kagi summary for ${source}\n\n${body}${note}`);
  //   },
  // });
}
