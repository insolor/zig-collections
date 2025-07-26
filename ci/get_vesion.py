from pathlib import Path
import re

project_root_dir = Path(__file__).parent.parent
build_zig_zon = project_root_dir / "build.zig.zon"

build_zig_zon_content = build_zig_zon.read_text()
match = re.search(r"\.version\s*=\s*\"([\d\.]+)\"", build_zig_zon_content)
print(match.group(1))
