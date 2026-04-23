"""Utilities for resolving AOC feature CSV file paths."""

from __future__ import annotations

import os


def feature_file(base_dir: str, filename: str) -> str:
    """Return an existing feature-file path with backwards-compatible naming."""
    feature_dir = os.path.join(base_dir, "data", "features")
    candidates = []

    # Preferred: exact name as requested.
    candidates.append(os.path.join(feature_dir, filename))

    # Backwards compatibility: handle optional "AOC_" prefix.
    if filename.startswith("AOC_"):
        candidates.append(os.path.join(feature_dir, filename.removeprefix("AOC_")))
    else:
        candidates.append(os.path.join(feature_dir, f"AOC_{filename}"))

    # Last-resort: direct path under base_dir.
    candidates.append(os.path.join(base_dir, filename))

    for path in candidates:
        if os.path.exists(path):
            return path

    raise FileNotFoundError(
        f"Could not find feature file '{filename}'. Checked: {candidates}"
    )
