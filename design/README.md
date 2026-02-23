# Pinball Game – Design Documentation

**Document ID:** 3_01

## Overview

This directory contains design documentation for the Pinball game, aligned with **requirements v2.0** ([Requirements.md](../requirements/Requirements.md)). The game replicates the core **I/O Pinball** design (Flutter + Forge2D, Google I/O 2022) in **Godot 4.x**, and extends it with **Store** (coins, upgradable items), **Score Range Board**, and **Level Mode**. Player assets (coins, upgrades) are persisted and shared across Classic and Level modes. Leaderboard and share use local or optional backend.

## Folder structure

- **requirements/** – Functional and non-functional requirements  
  - 2_01 [Requirements.md](../requirements/Requirements.md)

- **design/** – High-level design (this folder)  
  - 3_02 [GDD.md](GDD.md) – Game Design Document  
  - 3_03 [Technical-Design.md](Technical-Design.md) – System architecture for Godot  
  - 3_04 [Game-Flow.md](Game-Flow.md) – State diagrams and flows  
  - 3_05 [Implementation-Summary.md](Implementation-Summary.md) – How to run and what’s implemented  

- **design/details/** – Detailed specifications  
  - 4_01 [Component-Specifications.md](details/Component-Specifications.md) – Zone and component specs  
  - 4_02 [Asset-Requirements.md](details/Asset-Requirements.md) – Art and sounds  
  - 4_03 [Physics-Specifications.md](details/Physics-Specifications.md) – Physics engine and collision  
  - 4_04 [UI-Design.md](details/UI-Design.md) – UI/UX specification  

- **design/flutter-reference/** – Flutter I/O Pinball reference (centralized)  
  - 4_05 [FLUTTER-PINBALL-PARSING.md](flutter-reference/FLUTTER-PINBALL-PARSING.md) – Parsing summary  
  - 4_06 [FLUTTER-LAYOUT-AND-ASSETS.md](flutter-reference/FLUTTER-LAYOUT-AND-ASSETS.md) – Layout and asset mapping  
  - 4_07 [REFACTOR-FLUTTER-PARITY.md](flutter-reference/REFACTOR-FLUTTER-PARITY.md) – Refactor notes for Flutter parity  

## Related

- **Implementation:** Godot project under `scripts/`, `scenes/`, `assets/`.
- **Source:** Flutter I/O Pinball (e.g. [LuckyJunjie/pin-ball](https://github.com/LuckyJunjie/pin-ball)); requirements and plan in `requirements/`, `plan/`.
