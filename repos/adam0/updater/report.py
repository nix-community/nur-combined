from __future__ import annotations

import json

from .models import UpdateResult


def print_report(results: list[UpdateResult], report_format: str) -> None:
    if report_format == "json":
        print(
            json.dumps(
                [
                    {
                        "package": result.name,
                        "status": result.status,
                        "reason": result.reason,
                        "changedFiles": [str(path) for path in result.changed_files],
                    }
                    for result in results
                ],
                indent=2,
            )
        )
        return

    rows = [("Package", "Result", "Reason")]
    rows.extend((result.name, result.status, result.reason) for result in results)
    widths = [max(len(row[index]) for row in rows) for index in range(3)]
    for index, row in enumerate(rows):
        print("  ".join(value.ljust(widths[column]) for column, value in enumerate(row)))
        if index == 0:
            print("  ".join("-" * width for width in widths))
