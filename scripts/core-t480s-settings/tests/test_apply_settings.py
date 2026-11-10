import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "apply-settings.sh"


class ApplySettingsTest(unittest.TestCase):
    def test_replaces_thresholds_and_preserves_other_settings(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            config = root / "tlp.conf"
            config.write_text("CPU_BOOST_ON_AC=0\nSTART_CHARGE_THRESH_BAT0=30\n"
                              "STOP_CHARGE_THRESH_BAT0=100\n")
            script = root / "apply.sh"
            script.write_text(SCRIPT.read_text().replace("/etc/tlp.conf", str(config)))
            log = root / "calls"
            sudo = root / "sudo"
            sudo.write_text('#!/bin/bash\nprintf "%s\\n" "$*" >> "$CALLS"\n'
                            'if [[ "$1" == systemctl || "$1" == tlp ]]; then exit 0; fi\n'
                            'exec "$@"\n')
            sudo.chmod(0o755)
            tlp = root / "tlp"
            tlp.write_text("#!/bin/bash\nexit 0\n")
            tlp.chmod(0o755)
            env = {**os.environ, "PATH": f"{root}:{os.environ['PATH']}", "CALLS": str(log)}
            for _ in range(2):
                subprocess.run(["bash", str(script)], check=True, env=env)
            self.assertEqual(config.read_text(), "CPU_BOOST_ON_AC=0\n"
                             "START_CHARGE_THRESH_BAT0=70\nSTOP_CHARGE_THRESH_BAT0=85\n")
            self.assertIn("systemctl enable --now tlp\ntlp start\n", log.read_text())


if __name__ == "__main__":
    unittest.main()
