import importlib.machinery
import importlib.util
import os
import re
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
loader = importlib.machinery.SourceFileLoader("restore", os.path.join(ROOT, "restore"))
spec = importlib.util.spec_from_loader("restore", loader)
restore = importlib.util.module_from_spec(spec)
loader.exec_module(restore)


class CatalogTests(unittest.TestCase):
    def setUp(self):
        self.items, self.manual = restore.load_catalog()

    def test_ids_unique(self):
        ids = [i["id"] for i in self.items]
        self.assertEqual(len(ids), len(set(ids)))

    def test_order_respects_requires(self):
        pos = {i["id"]: n for n, i in enumerate(restore.order(self.items))}
        for i in self.items:
            for r in i.get("requires", []):
                self.assertLess(pos[r], pos[i["id"]], i["id"])

    def test_cycle_detected(self):
        bad = [{"id": "a", "requires": ["b"]}, {"id": "b", "requires": ["a"]}]
        with self.assertRaises(ValueError):
            restore.order(bad)

    def test_every_item_has_command(self):
        for i in self.items:
            self.assertTrue(restore.command_for(i), i["id"])

    def test_stow_packages_exist_with_files(self):
        for i in self.items:
            if i["kind"] == "stow":
                self.assertTrue(list(restore.stow_files(i["name"])), i["name"])

    def test_brewfile_matches_catalog(self):
        names = {(i["kind"], i["name"]) for i in self.items if i["kind"] in ("brew", "cask", "tap")}
        shell_text = " ".join(i.get("cmd", "") for i in self.items)
        skip = {"corepack"}
        for line in open(os.path.join(ROOT, "Brewfile")):
            m = re.match(r'(brew|cask|tap|vscode|uv|npm) "([^"]+)"', line)
            if not m or m.group(2) in skip:
                continue
            kind, name = m.groups()
            if kind in ("brew", "cask", "tap"):
                self.assertIn((kind, name), names, line)
            else:
                self.assertIn(name.split("[")[0], shell_text, line)

    def test_no_third_party_imports(self):
        src = open(os.path.join(ROOT, "restore")).read()
        mods = set(re.findall(r"^(?:import|from) (\w+)", src, re.M))
        stdlib = {"argparse", "concurrent", "curses", "json", "os", "queue", "shlex", "subprocess", "sys", "threading", "time"}
        self.assertLessEqual(mods, stdlib)


class StowTests(unittest.TestCase):
    def test_conflict_backup_and_link(self):
        with tempfile.TemporaryDirectory() as home:
            restore.HOME = home
            open(os.path.join(home, ".tmux.conf"), "w").write("old")
            self.assertEqual(restore.stow_conflicts("tmux"), [".tmux.conf"])
            self.assertFalse(restore.stow_installed("tmux"))
            os.remove(os.path.join(home, ".tmux.conf"))
            for rel, src in restore.stow_files("tmux"):
                os.symlink(src, os.path.join(home, rel))
            self.assertEqual(restore.stow_conflicts("tmux"), [])
            self.assertTrue(restore.stow_installed("tmux"))


class RunTests(unittest.TestCase):
    def test_dry_run_item_ok(self):
        lines = []
        item = {"id": "x", "kind": "shell", "cmd": "echo hi"}
        import threading
        self.assertEqual(restore.run_item(item, True, lines.append, threading.Event()), restore.OK)
        self.assertEqual(lines[0], "$ echo hi")

    def test_real_item_output_and_failure(self):
        import threading
        lines = []
        ok = restore.run_item({"id": "x", "kind": "shell", "cmd": "echo hello"}, False, lines.append, threading.Event())
        self.assertEqual((ok, "hello" in lines), (restore.OK, True))
        bad = restore.run_item({"id": "y", "kind": "shell", "cmd": "exit 3"}, False, lambda l: None, threading.Event())
        self.assertEqual(bad, restore.FAIL)


if __name__ == "__main__":
    unittest.main()
