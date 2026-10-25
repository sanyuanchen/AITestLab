"""Create a Windows desktop shortcut (.lnk) for the AITestLab launcher.

COM (WScript.Shell) is blocked by this machine's security policy, so the .lnk
is built with pylnk3 instead. Run it with the project venv:

    .venv\\Scripts\\python.exe scripts\\make_desktop_shortcut.py
"""
import os
import sys

import pylnk3

PROJ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BAT = os.path.join(PROJ, "start_qualitypilot.bat")
ICO = os.path.join(PROJ, "aitestlab.ico")

NAME = "AITestLab"
desktop = os.path.join(os.path.expanduser("~"), "Desktop")
lnk_path = os.path.join(desktop, f"{NAME}.lnk")

for p in (BAT, ICO, desktop):
    if not os.path.exists(p):
        sys.exit(f"missing: {p}")

entry = pylnk3.for_file(
    BAT,
    lnk_name=NAME,
    description="AITestLab 智能测试自动化平台 - 一键启动并打开",
    icon_file=ICO,
    work_dir=PROJ,
    window_mode=pylnk3.WINDOW_NORMAL,
)
entry.save(lnk_path)

# pylnk3.for_file() also drops a stray extensionless file named after lnk_name
# in the working directory -- remove it so it never ends up in git.
stray = os.path.join(PROJ, NAME)
if os.path.isfile(stray):
    os.remove(stray)

print("created:", lnk_path)
