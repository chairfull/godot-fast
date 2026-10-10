# zlf-godot-editor

A custom Godot editor build for Linux, targeting **Godot 4.8-dev** (master) plus a
curated set of cherry-picked performance PRs — mostly editor import/filesystem
speed, the part of Godot that hurts most on huge projects.

Built automatically by GitHub Actions on every `v*` tag push. Grab the binary
from [Releases](../../releases).

## What's in it

Base: `godotengine/godot` master @ `232e6b14` (4.8-dev, 2026-10-09).
See [cherry-picks.txt](cherry-picks.txt) for the manifest and
[patches/](patches/) for the resolved patch series (two PRs needed manual
conflict resolution; details in cherry-picks.txt).

| PR | What | Why |
|----|------|-----|
| [#124138](https://github.com/godotengine/godot/pull/124138) | Filesystem dock + import performance (stuartcarnie) | Import 43s → 25s, main-thread CPU 1.24min → 2.5s, dock hangs → instant |
| [#121827](https://github.com/godotengine/godot/pull/121827) | Threaded scene imports + parallel glTF/mesh processing (knopkem) | Scene imports go multi-threaded; TSan-verified. Closed upstream over AI-policy, works fine here |
| [#122860](https://github.com/godotengine/godot/pull/122860) | Editor only refreshes changed project settings (adamscott) | Micro-opt (~200µs → ~45µs on settings change), harmless |

Deliberately **not** included (yet): #123844 (TAA fixes, in-review renderer
change), #115027 (motion blur, big in-review renderer feature), #122686
(physics BVH threads — GodotPhysics3D only, we use Jolt).

## Build it yourself

```bash
./build.sh
```

Needs: git, python3, scons, and Godot's Linux build deps
(`build-essential`, `libx11-dev`, `libxcursor-dev`, `libxinerama-dev`,
`libgl1-mesa-dev`, `libasound2-dev`, `libpulse-dev`, `libudev-dev`, …).
The script clones Godot at the pinned base SHA, cherry-picks the commits from
`cherry-picks.txt`, and runs scons. Takes ~30–60 min on a 4-core machine.

## Releasing a new build

1. Update `cherry-picks.txt` (and `BASE_SHA` in the workflow) as needed.
2. Commit, tag `vX.Y.Z`, push the tag.
3. Actions builds and attaches the binary to the release.
