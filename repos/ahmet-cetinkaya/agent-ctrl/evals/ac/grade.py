"""Grade ac command eval runs: hidden tests, pristine visible tests, diff size, cost, delegation, and run state."""

import json
import shutil
import subprocess
import sys
import tempfile
from collections import Counter
from pathlib import Path

EVAL_DIR = Path(__file__).resolve().parent
DELEGATION_TOOLS = {"Agent", "Task"}


def tests_pass(repo, pattern, hidden_test=None):
    """Run pristine project tests (plus an optional hidden test) against the run's shop/ sources."""
    with tempfile.TemporaryDirectory() as scratch:
        work = Path(scratch)
        shutil.copytree(EVAL_DIR / "project", work, dirs_exist_ok=True)
        shutil.copytree(repo / "shop", work / "shop", dirs_exist_ok=True)
        if hidden_test:
            shutil.copy(hidden_test, work / "tests" / pattern)
        completed = subprocess.run(
            [sys.executable, "-I", "-m", "unittest", "discover", "-t", ".", "-s", "tests", "-p", pattern],
            cwd=work, capture_output=True, text=True,
        )
        return completed.returncode == 0


def changed_source_lines(repo):
    numstat = subprocess.run(["git", "diff", "--numstat", "HEAD", "--", "shop"], cwd=repo, capture_output=True, text=True).stdout
    return sum(int(added) + int(removed) for added, removed, _ in (line.split("\t") for line in numstat.splitlines()))


def run_state_metrics(repo):
    """Report the final plan status (when the case has a plan) and the ledger event count."""
    work_items = list((repo / ".agents" / "work").glob("*"))
    plan_statuses = [
        line.split(":", 1)[1].strip()
        for plan in (item / "plan.md" for item in work_items) if plan.is_file()
        for line in plan.read_text().splitlines() if line.startswith("status:")
    ]
    ledgers = [item / "ledger.jsonl" for item in work_items if (item / "ledger.jsonl").is_file()]
    return {
        "plan_status": plan_statuses[0] if plan_statuses else None,
        "run_state_files": sorted({path.name for item in work_items for path in item.iterdir()}),
        "ledger_events": sum(len(ledger.read_text().splitlines()) for ledger in ledgers),
    }


def transcript_metrics(transcript):
    tool_counts, subagent_types, result = Counter(), Counter(), {}
    for line in transcript.read_text().splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") == "result":
            result = event
        message = event.get("message")
        content = message.get("content") if isinstance(message, dict) else None
        for block in content if isinstance(content, list) else []:
            if isinstance(block, dict) and block.get("type") == "tool_use":
                tool_counts[block.get("name")] += 1
                if block.get("name") in DELEGATION_TOOLS:
                    subagent_types[(block.get("input") or {}).get("subagent_type")] += 1
    usage = result.get("usage") or {}
    return {

        "turns": result.get("num_turns"),
        "cost_usd": round(result.get("total_cost_usd") or 0, 3),
        "output_tokens": usage.get("output_tokens"),
        "delegations": dict(subagent_types),
        "models": sorted((result.get("modelUsage") or {}).keys()),
        "tool_calls": sum(tool_counts.values()),
        "finished": result.get("subtype") == "success",
    }


def run_stage_metrics(transcript):
    """Metrics of the /ac:run stage that follows a planning case, prefixed to keep them apart."""
    if not transcript.is_file():
        return {}
    return {f"run_{key}": value for key, value in transcript_metrics(transcript).items()}


def grade_run(run_dir):
    case_name = run_dir.name.rsplit("-", 1)[0]
    repo = run_dir / "repo"
    return {
        "run": run_dir.name,
        "hidden_pass": tests_pass(repo, "test_hidden.py", EVAL_DIR / "cases" / case_name / "hidden_test.py"),
        "visible_pass": tests_pass(repo, "test_shop.py"),
        "src_lines_changed": changed_source_lines(repo),
        **run_state_metrics(repo),
        **transcript_metrics(run_dir / "transcript.jsonl"),
        **run_stage_metrics(run_dir / "transcript-run.jsonl"),
        # result.duration_ms misses background subagents, so wall time comes from the runner.
        "seconds": int((run_dir / "wall-seconds").read_text()) if (run_dir / "wall-seconds").is_file() else None,
    }


def main(out_dirs):
    for out_dir in map(Path, out_dirs):
        rows = [grade_run(run_dir) for run_dir in sorted(out_dir.iterdir()) if (run_dir / "repo").is_dir()]
        print(f"## {out_dir.name}")
        for row in rows:
            print(json.dumps(row))
        if rows:
            passed = sum(row["hidden_pass"] and row["visible_pass"] for row in rows)
            print(f"pass {passed}/{len(rows)} · cost ${sum(r['cost_usd'] for r in rows):.2f} · "
                  f"seconds {sum(r['seconds'] or 0 for r in rows)} · delegations {sum(sum(r['delegations'].values()) for r in rows)}")


if __name__ == "__main__":
    main(sys.argv[1:])
