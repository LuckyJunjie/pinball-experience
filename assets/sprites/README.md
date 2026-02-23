# Graphics Assets Directory

This directory contains sprite assets for the pinball game.

## Current Assets

The following sprites are currently in use:
- `background.png` - Pinball table background (800x600)
- `ball.png` - Ball sprite (16x16)
- `flipper.png` - Flipper sprite (60x12)
- `bumper.png` - Bumper obstacle (60x60)
- `peg.png` - Peg obstacle (16x16)
- `wall_obstacle.png` - Wall obstacle (40x10)
- `wall.png` - Wall tile (20x20)
- `plunger.png` - Plunger sprite (10x30)
- `launcher_base.png` - Launcher base (60x10)

## Generating Sprites

Basic sprites can be generated using:
```bash
python3 scripts/generate_sprites.py
```

This creates simple procedural sprites suitable for prototyping.

## Commercial Quality Assets

For commercial-quality graphics, download from these free sources:

### Free Commercial Use Sources:
1. **OpenGameArt.org** - https://opengameart.org
   - Search: "pinball", "arcade", "game table"
   - License: Various (CC0, CC-BY, GPL)
   - Filter by "Commercial use" allowed

2. **Kenney.nl** - https://kenney.nl/assets
   - Free game assets (CC0)
   - Has arcade/pinball style assets
   - Commercial use allowed

3. **itch.io** - https://itch.io/game-assets/free
   - Many free asset packs
   - Check individual licenses
   - Search: "pinball", "arcade"

4. **FreePik** - https://www.freepik.com
   - Requires free account
   - Check license (many allow commercial use with attribution)
   - Search: "pinball", "arcade background"

5. **Pixabay** - https://pixabay.com
   - Free images (Pixabay License = commercial use allowed)
   - Search: "pinball", "arcade"

### Recommended Asset Specifications:

**Background:**
- Size: 800x600 or larger (can be scaled)
- Format: PNG with transparency support
- Style: Pinball table, arcade, retro

**Sprites:**
- Ball: 16x16 or larger (circle)
- Flipper: 60x12 or larger (bat-like shape)
- Obstacles: Various sizes
- Format: PNG with transparency

## Replacing Assets

To replace an asset:
1. Download the new asset (see `docs/assets/ASSET_DOWNLOAD_GUIDE.md` for sources)
2. Place it in `assets/sprites/` with the same filename
3. Godot will automatically reimport when you open the project
4. Or use "Reimport" in Godot editor for the file

**📖 For detailed download instructions and direct links, see: `docs/assets/ASSET_DOWNLOAD_GUIDE.md`.**

**💻 Use the download script:**
```bash
python3 scripts/download_assets.py
```

## Notes

- All sprites should use PNG format with transparency (alpha channel)
- Sprites should be sized appropriately for the game (see sizes above)
- Maintain aspect ratios when scaling
- Background should be 70% transparent (handled in scene, but can be pre-adjusted)
