# Copilot Instructions for lamu-kernel

This repository contains the GitHub Actions–based build system for the **Lamu** custom Android kernel. It targets the Motorola Moto G14 (codename `lamu`) running a Mediatek MT6768 SoC with Linux 6.6 (GKI/Bazel/Kleaf build system).

## Repository Structure

- `.github/workflows/` — CI/CD workflows for building the kernel
  - `build-kernel.yml` — Main build workflow with KernelSU-Next support
  - `build-kernel-nethunter.yml` — Nethunter variant build workflow
  - `copilot-setup-steps.yml` — Copilot agent setup steps
- `.github/ISSUE_TEMPLATE/` — Issue templates
- `patches/` — Kernel patches applied during the build:
  - `fix-headers-unifdef.patch` — Fixes unifdef header issues
  - `nethunter-modules-bazel.patch` — Adds Kali Nethunter module support to Bazel
  - `optimize-kernel-performance.patch` — Performance tuning patches
- `AnyKernel3/` — AnyKernel3 flashable zip skeleton (standard build)
- `AnyKernel3-Nethunter/` — AnyKernel3 flashable zip skeleton (Nethunter build)
- `manifest.xml` — Repo manifest defining the full kernel workspace (44 projects, 2 remotes: aosp + moto)
- `README.md` — Manual build instructions

## Build System

- **Build engine**: Bazel (Kleaf/MGK) — do **not** use plain `make`
- **Kernel source**: Motorola MTK (`MotorolaMobilityLLC/kernel-mtk`, branch `android-15-release-vvta35`) — Linux 6.6.82, cloned at build time via `repo sync`
- **Target product**: `lamu`; defconfig: `mgk_64_k66_defconfig`; overlays: `mt6768_overlay.config lamu_overlay.config`
- **Defconfig location** (in kernel source): `arch/arm64/configs/gki_defconfig`
- Patches are applied with `patch -p1` inside `kernel_platform/${GKI_KERNEL_SRC}` (i.e., `kernel_platform/kernel/kernel-6.6`)
- Kernel config changes use `scripts/config --file arch/arm64/configs/gki_defconfig`

## Workflow Inputs (`build-kernel.yml`)

| Input | Default | Description |
|---|---|---|
| `SUSFS` | On | Enable SUSFS (hide KernelSU from detection) |
| `bbg` | On | Enable Baseband Guard (BBG) LSM |
| `bbr` | Off | Enable BBR network congestion algorithm |
| `proxy` | Off | Enable proxy performance optimization (off for MTK) |
| `UNICODE_BYPASS` | Off | Enable Unicode zero-width bypass fix |
| `optimize` | On | Apply performance optimization patch |
| `nethunter` | Off | Apply Nethunter modules patch |

## Key Conventions

1. **Patches go in `patches/`** — apply via `patch -p1` in the GKI kernel source root
2. **BBG `setup.sh` must run from `kernel_platform/${GKI_KERNEL_SRC}`** — it uses `$(pwd)` as `GKI_ROOT` and expects `security/` and `include/` subdirectories there
3. **KernelSU-Next version info must be pre-injected** into `KernelSU-Next/kernel/Kbuild` before the Bazel build; the Bazel sandbox strips `.git` directories so git commands fail at build time
4. **CAN/USB serial configs** in Nethunter must use `--module` (not `--enable`) — GKI `BUILD.bazel` expects `.ko` files
5. **`CONFIG_KUNIT`** and kunit test configs must **not** be removed — they are required by GKI `module_outs`
6. **CAN_ESD_USB2 does not exist** in kernel 6.6 — the correct symbol is `CAN_ESD_USB`; `CAN_LED` also does not exist
7. **Defconfig edits** use `scripts/config`, not manual sed/echo where possible
8. **YAML validation**: `python3 -c 'import yaml; yaml.safe_load(open("file.yml"))'`
9. **Workspace setup**: `repo init -m manifest.xml` then `repo sync` — do not manually clone the 44 projects defined in `manifest.xml`

## What Copilot Should and Shouldn't Change

- ✅ Workflow YAML files in `.github/workflows/`
- ✅ Patch files in `patches/`
- ✅ `manifest.xml` (repo manifest)
- ✅ `AnyKernel3/` and `AnyKernel3-Nethunter/` skeleton files
- ❌ Do **not** commit actual kernel source code — it is cloned at build time
- ❌ Do **not** add new build dependencies without verifying they are available on the `aapt2` self-hosted runner
- ❌ Do **not** disable or remove GKI-required configs (`CONFIG_KUNIT`, `module_outs` entries)
