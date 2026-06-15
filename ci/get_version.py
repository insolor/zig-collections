# /// script
# dependencies = [
#     "natizon==0.2.0",
# ]
# requires-python = ">=3.12"
# ///

from pathlib import Path
import natizon

project_root_dir = Path(__file__).parent.parent
build_zig_zon_file = project_root_dir / "build.zig.zon"

build_zig_zon = natizon.loads(build_zig_zon_file.read_text())
version = build_zig_zon.get("version")
if not version:
    raise ValueError("Failed to get version from build.zig.zon")

print(version)
