# Opuntia Build System — AI Agent Guide

This is an **OpenWrt-based embedded firmware build system** (Opuntia by ImageStream Internet Solutions). The root `/opuntia` Makefile is a meta-build that clones a pinned OpenWrt source, applies patches, installs feeds, and then drives the OpenWrt `make world` build.

## Quick Reference

```bash
# Build a specific target (e.g. x86-64):
cd /opuntia && make x86-64

# Build a different target (e.g. ap2100):
cd /opuntia && make ap2100

# Clean build state (keep source tree):
cd /opuntia && make clean

# Full clean (remove build_dir):
cd /opuntia && make distclean
```

## Directory Layout

```
/opuntia/
├── Makefile                 # Meta-build driver — the entry point for all builds
├── version                  # Current version string (e.g. "5.0.0")
├── feeds.conf               # Feed definitions (packages, luci, routing, imagestream)
├── configs/                 # Per-target config files
│   ├── base                 # Common base config applied to ALL targets
│   └── <target>             # Target-specific config (appended after base)
├── patches/                 # Quilt-managed patches (series file at patches/series)
│   ├── series               # Quilt patch stack order
│   └── <patches>            # Individual patch files
├── patches.luci/            # Quilt patches applied to luci feed
├── overlay/                 # Package overlays (base-files, dnsmasq, firewall, etc.)
├── opuntia_imagestream/     # Custom ImageStream packages feed (src-cpy)
├── qca/                     # QCA (Qualcomm Atheros) sources and feeds
│   ├── src/                 # Local source overrides (via local-development.mk)
│   └── feeds/               # QCA-specific feed configs
├── installation/            # Firmware installation scripts (create_ap3350.sh, etc.)
├── build_dir/               # Pinned OpenWrt clone + build state (not committed)
├── dl.cache/                # Downloaded source tarballs cache
├── docker/                  # Dockerfile for build container
└── 5_Updates/               # Migration / tracking docs for updates
```

## Build Process (make <target>)

Running `make <target>` from `/opuntia` executes the following pipeline:

1. **`setup_cache`** — Creates `dl.cache/` directory and copies downloaded sources.
2. **`checkout_openwrt`** — Clones OpenWrt from `github.com/openwrt/openwrt` at the pinned commit (`OPENWRT_COMMIT` in Makefile). Copies `dl.cache` and `overlay` into the build dir.
3. **Writes config** — Appends `configs/base` + `configs/<target>` into `build_dir/.config`, injecting the version number from `version`.
4. **`prepare`** (runs `pre_patches` and `feeds`):
   - **`pre_patches`** — Applies patches from `patches.pre_feed/` (if any).
   - **`feeds`** — Copies `feeds.conf`, runs `scripts/feeds update -a`, runs `make configure`, applies `patches/` via quilt, copies `patches.luci/` to luci feed and applies via quilt, then `scripts/feeds install -a`.
5. **`build`** — Runs `make defconfig world` inside `build_dir/`.
6. **`install`** — Copies the resulting firmware images to `images/` directory with a naming convention: `opuntia-<TARGET>-v<HWVER>-<VER>-<REL>-factory.img`.

## Key Variables in Makefile

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENWRT_GIT` | `https://github.com/openwrt/openwrt.git` | OpenWrt source URL |
| `OPENWRT_COMMIT` | `9a02069365c88a5973858da6777d0682a2dd4550` | Pinned OpenWrt commit |
| `BUILD_DIR` | `build_dir` | Directory where OpenWrt is cloned and built |
| `DESTDIR` | `images` | Output directory for firmware images |
| `CACHE_DIR` | `$(pwd)/ccache` | CCACHE directory (auto-created) |
| `PARALLEL_MAKE` | `-j $(cpus * 2)` | Parallel build flag |
| `BUILD_OPTS` | (empty) | Extra options to pass to OpenWrt make |

## Working with Patches

### OpenWrt core patches (`patches/`)
- Managed via **quilt** with `patches/series` as the stack order.
- Applied during the `feeds` target after feeds are installed.
- To add a new patch: create the `.patch` file, add it to `patches/series` in the desired position.

### LuCI patches (`patches.luci/`)
- Managed via quilt within the luci feed.
- Applied after core patches are applied.

### Target patches
- Patches are applied inside `build_dir/` which is the OpenWrt tree.

## Adding a New Target

1. Create `configs/<target>` — start from `configs/base` plus target-specific settings (target architecture, packages).
2. The target name is passed as a Make target: `make <target>`.
3. The version number from `version` is injected into `CONFIG_VERSION_NUMBER`.

## Adding a Custom Package

### Option A: Overlay packages (`overlay/`)
- Create a directory under `overlay/<package-name>/` with a `<package-name>.mk` Makefile and a `files/` directory for data files.
- The `overlay/` directory is copied into `build_dir/` during checkout.

### Option B: ImageStream feed (`opuntia_imagestream/`)
- Add a new package directory under `opuntia_imagestream/package/<package-name>/`.
- This is referenced as `src-cpy imagestream ../opuntia_imagestream` in `feeds.conf`.
- After adding, rebuild feeds: re-run the target build.

### Option C: QCA local source (`qca/src/`)
- For packages with local source overrides, place the source in `qca/src/<pkg-name>/`.
- The `local-development.mk` in `include/` (copied to build_dir) provides the `LOCAL_SRC` override mechanism.

## Build Environment

### Docker
The build runs inside a Docker container based on Ubuntu Focal. The Dockerfile is at `docker/Dockerfile`.

```bash
# Build and run the container:
make docker_run

# Attach to running container:
docker exec -it opuntia /bin/bash
```

### Prerequisites (installed in Docker image)
- `build-essential`, `g++`, `git`, `subversion`, `python3`
- `quilt` (patch management)
- `ccache` (build caching)
- `libssl-dev`, `libelf-dev`, `libncurses5-dev`, `zlib1g-dev`
- `protobuf-c-compiler`, `xsltproc`, `intltool`

### Running from within the container (current session)
You are already inside the Docker build container. The working directory is `/opuntia`. Use the standard `make <target>` workflow directly.

## Common Build Issues

- **iputils / meson fails with ccache**: The Makefile has a retry without ccache built in. If the build fails on iputils, it will retry with `CONFIG_CCACHE=n` for that package.
- **Patch conflicts**: Patches are applied via quilt in `build_dir/`. If a patch fails, the build aborts with the failing patch name. Fix the patch or adjust `patches/series` ordering.
- **Stale build state**: Use `make clean` to reset the build marker (keeps source) or `make distclean` to remove the entire `build_dir/` and start fresh.

## Versioning

- Version string lives in `/opuntia/version` (current: `5.0.0`).
- The version is injected into `CONFIG_VERSION_NUMBER` during the configure step.
- Firmware images are named: `opuntia-<TARGET>-v<HWVER>-<VER>-<REL>-factory.img`.

## Target List

Available targets are in `configs/`. Some key ones:
- `x86-64` — Generic x86_64 (most feature-complete)
- `ap2100` — AP2100 (ImageStream hardware)
- `ap2000` — AP2000 (ImageStream hardware)
- `ap3000` / `ap3350` / `ap3500` / `ap3600` / `ap4500` / `ap5000` — Various AP models
- `ev1000` — EV1000
- `rpi` — Raspberry Pi
- `apcloud` — APCloud

See `configs/README.md` for hardware model mappings.

## Modifying the Base Config

`configs/base` contains the common configuration shared by all targets. It includes:
- OpenWrt build options (ccache, devel flags)
- Base system packages (busybox, base-files, etc.)
- Kernel modules (crypto, netfilter, networking)
- LuCI web interface configuration
- ImageStream-specific packages

Always consider whether a change should go in `base` (affects all targets) or in a specific target config (affects only that target).

## Useful OpenWrt Commands (inside build_dir)

Once the build is prepared, you can run OpenWrt commands directly:

```bash
# Menuconfig (interactive config)
cd build_dir && make menuconfig

# Search for a package
cd build_dir && make menuconfig  # then /search

# Rebuild a specific package
cd build_dir && make package/<pkgname>/clean && make package/<pkgname>/compile

# See what's configured
grep 'CONFIG_PACKAGE_' build_dir/.config
```

## Changes to the repo

Changes must be saved either as patches or updates to build system that will get checked in with the Repo. DO NOT make changes that are in the build dir. If needed, apply changes to makefiles or patches and then do a "make clean" to validate your changes are saved correctly
