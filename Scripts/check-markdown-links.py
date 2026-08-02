#!/usr/bin/env python3
"""Check local Markdown links used by repository documentation."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LINK = re.compile(r"(?<!!)\[[^]]+\]\(([^)]+)\)")
IGNORED_PREFIXES = ("http://", "https://", "mailto:", "#")


def check_file(markdown: Path) -> list[str]:
    failures: list[str] = []
    for target in LINK.findall(markdown.read_text(encoding="utf-8")):
        target = target.strip().strip("<>")
        if not target or target.startswith(IGNORED_PREFIXES):
            continue
        path_part = target.split("#", 1)[0]
        if not path_part:
            continue
        destination = (markdown.parent / path_part).resolve()
        if not destination.is_relative_to(ROOT) or not destination.exists():
            failures.append(f"{markdown.relative_to(ROOT)}: {target}")
    return failures


def main() -> int:
    markdown_files = [*ROOT.glob("*.md"), *ROOT.glob("Docs/*.md"), *ROOT.glob("Examples/**/*.md")]
    failures = [failure for file in markdown_files for failure in check_file(file)]
    if failures:
        print("Broken local Markdown links:", *failures, sep="\n- ", file=sys.stderr)
        return 1
    print(f"Checked {len(markdown_files)} Markdown files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
