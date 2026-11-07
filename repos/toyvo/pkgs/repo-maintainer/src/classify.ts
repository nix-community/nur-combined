export type FailureKind = "infra-cancel" | "eval-break" | "unknown";

const INFRA_PATTERNS = [
  /context canceled/i,
  /signal:\s*terminated/i,
  /timed out/i,
  /cancelled/i,
];

const EVAL_PATTERNS = [
  /failed assertions/i,
  /no longer supported/i,
  /please use .* instead/i,
  /while evaluating/i,
];

export function classifyFailure(logTail: string): FailureKind {
  if (!logTail || logTail.trim() === "") return "unknown";
  for (const re of INFRA_PATTERNS) {
    if (re.test(logTail)) return "infra-cancel";
  }
  for (const re of EVAL_PATTERNS) {
    if (re.test(logTail)) return "eval-break";
  }
  return "unknown";
}
