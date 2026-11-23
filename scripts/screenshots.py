#!/usr/bin/env python3
"""Save the README pictures from a guided brs-engine walk on a scratch Arc."""
import argparse
import subprocess
import tempfile
from pathlib import Path

import pexpect

REPO = Path(__file__).resolve().parents[1]
SCREENS = {
    "sign-in": "Connect to the scratch Arc and stop on the link code before approving it.",
    "profiles": "Approve the code on the scratch Arc. Wait for Who's watching?",
    "home": "Choose Jordan. Wait for Continue Watching and its artwork.",
    "movie": "Open Interstellar.",
    "show-episodes": "Open Severance and move down to its episodes.",
    "library-recommended": "Open Movies from the sidebar, on Recommended.",
    "library": "Move up to the library tabs and open Browse.",
    "collection": "Open the Dune Collection from the Movies library's Collections tab.",
    "settings": "Open Settings from the sidebar.",
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, default=REPO / "docs/screenshots")
    parser.add_argument("--only", nargs="+", choices=SCREENS, help="Capture just these screens.")
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="arc-roku-screenshots-") as directory:
        scratch = Path(directory)
        png = scratch / "frame.png"
        cli = REPO / "node_modules/.bin/brs-cli"
        package = REPO / "out/arc-roku.zip"
        if not cli.is_file() or not package.is_file():
            parser.error("Run npm ci and npm run build first.")
        # No --registry: every walk starts signed out and leaves saved device sign-in alone.
        with pexpect.spawn(str(cli), ["--unicode", "--ascii", "100", "--snapshot", str(png), str(package)],
                           cwd=scratch, timeout=15) as simulator:
            for name in args.only or SCREENS:
                print(f"\n{name}: {SCREENS[name]}\nPress Ctrl+] when the screen is ready.", flush=True)
                simulator.interact()
                png.unlink(missing_ok=True)
                simulator.sendcontrol("s")
                simulator.expect("saved", timeout=15)
                if not png.is_file():
                    raise RuntimeError(f"No snapshot saved for {name}")
                subprocess.run(["ffmpeg", "-nostdin", "-loglevel", "error", "-y", "-i",
                                str(png), "-frames:v", "1", "-q:v", "3",
                                str(out / f"{name}.jpg")], check=True)
                print(f"Saved {name}.jpg", flush=True)


if __name__ == "__main__":
    main()
