"""One-shot identity finalization for the AITestLab portfolio repo.

Usage (run from the project root, with the project venv):

    .venv\\Scripts\\python.exe scripts\\finalize_identity.py <github-username>

What it does:
  1. Replaces the YOUR_GITHUB_USERNAME placeholder in LICENSE / NOTICE /
     README.md / pyproject.toml
  2. Sets the local git identity (name + GitHub noreply email) for this repo
  3. Renames the `origin` remote (which points at the upstream project) to
     `upstream`, so `origin` is free for your own repository
  4. Prints the exact commands to create the GitHub repo and push

It is idempotent: running it twice with the same username is harmless.
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
PLACEHOLDER = "YOUR_GITHUB_USERNAME"
GIT_NAME = "Yolanda Chen"
TARGETS = ["LICENSE", "NOTICE", "README.md", "pyproject.toml"]
USERNAME_RE = re.compile(r"^[A-Za-z0-9](?:[A-Za-z0-9-]{0,37}[A-Za-z0-9])?$")


def run(cmd: list[str]) -> tuple[int, str]:
    proc = subprocess.run(cmd, cwd=PROJECT_ROOT, capture_output=True, text=True)
    return proc.returncode, (proc.stdout + proc.stderr).strip()


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2

    username = sys.argv[1].strip().lstrip("@")
    if not USERNAME_RE.match(username):
        print(f"[ERROR] '{username}' does not look like a GitHub username.")
        return 2

    # 1. replace placeholder
    touched = []
    for name in TARGETS:
        path = PROJECT_ROOT / name
        if not path.exists():
            print(f"[skip] {name} not found")
            continue
        text = path.read_text(encoding="utf-8")
        if PLACEHOLDER not in text:
            print(f"[skip] {name} has no placeholder left")
            continue
        path.write_text(text.replace(PLACEHOLDER, username), encoding="utf-8")
        touched.append(name)
    print(f"[1/4] placeholder replaced in: {', '.join(touched) if touched else 'nothing'}")

    # 2. git identity (repo-local, does not touch global config)
    run(["git", "config", "--local", "user.name", GIT_NAME])
    run(["git", "config", "--local", "user.email", f"{username}@users.noreply.github.com"])
    print(f"[2/4] git identity set to {GIT_NAME} <{username}@users.noreply.github.com>")

    # 3. origin -> upstream
    code, out = run(["git", "remote", "get-url", "origin"])
    if code != 0:
        code_up, out_up = run(["git", "remote", "get-url", "upstream"])
        if code_up == 0:
            print(f"[3/4] origin already absent; upstream = {out_up}")
        else:
            print("[3/4] no remote configured -- add one manually")
    elif "AI-driven-test-automation-platform" in out:
        run(["git", "remote", "rename", "origin", "upstream"])
        print(f"[3/4] origin renamed to upstream ({out})")
    else:
        print(f"[3/4] origin already points elsewhere ({out}), left untouched")

    # 4. next steps
    print(
        "\n[4/4] Next: create an empty repo on GitHub (no README, no .gitignore),\n"
        "      then run:\n"
        f"        git remote add origin https://github.com/{username}/AITestLab.git\n"
        "        git add -A\n"
        '        git commit -m "chore: rebrand as AITestLab, add LICENSE/NOTICE and launcher"\n'
        "        git branch -M main\n"
        "        git push -u origin main\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
