#!/usr/bin/env python3
"""Fail CI if any committed STL is not watertight (manifold).

A preview/CSG export that isn't watertight will slice wrong or fail to
print. This walks every *.stl in the repo and loads it with trimesh;
any mesh with is_watertight == False fails the run.

Intentional non-printables (reference geometry, boolean cutters,
superseded iterations) go in .manifoldignore at the repo root —
one gitignore-style glob per line, # comments allowed.
"""
import fnmatch
import pathlib
import sys

import trimesh

ROOT = pathlib.Path(__file__).resolve().parent.parent


def load_ignore_patterns():
    pats = []
    ignore_file = ROOT / ".manifoldignore"
    if ignore_file.exists():
        for line in ignore_file.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#"):
                pats.append(line)
    return pats


def is_ignored(rel_path, patterns):
    return any(fnmatch.fnmatch(rel_path, pat) for pat in patterns)


def main():
    patterns = load_ignore_patterns()
    failures = []
    checked = skipped = 0

    for path in sorted(ROOT.rglob("*.stl")):
        rel = path.relative_to(ROOT).as_posix()
        if is_ignored(rel, patterns):
            skipped += 1
            print(f"SKIP {rel} (.manifoldignore)")
            continue
        mesh = trimesh.load(path, force="mesh")
        checked += 1
        bodies = mesh.body_count
        if mesh.is_watertight:
            print(f"PASS {rel}: watertight, {bodies} body(ies), "
                  f"{mesh.volume / 1000.0:.1f} cm3")
        else:
            print(f"FAIL {rel}: NOT WATERTIGHT, {bodies} body(ies)")
            failures.append(rel)

    print(f"\n{checked} checked, {skipped} ignored, {len(failures)} failed")
    if failures:
        print("Non-manifold STLs:")
        for rel in failures:
            print(f"  - {rel}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
