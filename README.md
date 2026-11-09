# ECE 5745 — Sorting Accelerator

Sorting accelerator RTL, functional model, TinyRV2 integration, and software workloads from ECE5745 group 11. `sim/lab2_xcel/` is the accelerator; `sim/proc/`, `sim/pmx/`, and `sim/vc/` supply integration support.

Requires the course-compatible PyMTL3 environment (`cornell-brg/pymtl3`, branch `ece4750-2022`), its Python dependencies, and compatible Verilator. The original course automation used Python 3.7 and Verilator 4.036; a current-toolchain port has not been validated. Create an isolated compatible environment before running:

```sh
mkdir -p sim/build
cd sim/build
pytest ../lab2_xcel/test -v
python ../lab2_xcel/sort-xcel-sim --impl rtl --input random --stats
```

The saved lab snapshot omitted the test packages and PyMTL configuration imported by its simulator. This source edition restores those supporting files from the locally preserved ECE5745 final-project tree, retaining their original attribution. The lab's accelerator implementation remains unchanged. These restored tests have not been rerun in the historical course environment. ASIC flows additionally require the course mflowgen/ADK/tool setup.

Source comments retain course, instructor, library, and collaborator attribution. This repository does not grant a new license over third-party material. Generated logs, waveforms, debugging captures, and result directories are omitted from this public source edition.
