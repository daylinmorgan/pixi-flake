#!/usr/bin/env python3

# fmt: off
# https://swydd.dayl.in/#automagic-snippet
if not((_i:=__import__)("importlib.util").util.find_spec("swydd")or
(_src:=_i("pathlib").Path(__file__).parent/"swydd/__init__.py").is_file()):
  _r=_i("urllib.request").request.urlopen("https://swydd.dayl.in/swydd.py")
  _src.parent.mkdir(exist_ok=True);_src.write_text(_r.read().decode())  # noqa
# fmt: on

from swydd import task, sub, cli


@task
def update():
    """run nix-update to fetch latest tag"""
    sub("nix run 'github:Mic92/nix-update' -- --flake pixi --commit")


cli()
