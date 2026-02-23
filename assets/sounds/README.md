# Sound Effects Directory

This directory should contain the following sound effect files in OGG or WAV format:

- `flipper_click.ogg` or `flipper_click.wav` - Sound when flipper activates
- `obstacle_hit.ogg` or `obstacle_hit.wav` - Sound when ball hits an obstacle
- `ball_launch.ogg` or `ball_launch.wav` - Sound when ball is launched
- `hold_entry.ogg` or `hold_entry.wav` - Sound when ball enters a hold
- `ball_lost.ogg` or `ball_lost.wav` - Sound when ball falls to bottom

## Current Status

Placeholder WAV sound files have been generated using `scripts/generate_sounds.py`. 
These are basic procedural sounds and can be replaced with higher quality sounds.

## Converting WAV to OGG (Recommended)

OGG format is preferred by Godot for better compression. To convert WAV files to OGG:

```bash
# Using ffmpeg (if installed):
cd assets/sounds
ffmpeg -i flipper_click.wav -c:a libvorbis flipper_click.ogg
ffmpeg -i obstacle_hit.wav -c:a libvorbis obstacle_hit.ogg
ffmpeg -i ball_launch.wav -c:a libvorbis ball_launch.ogg
ffmpeg -i hold_entry.wav -c:a libvorbis hold_entry.ogg
ffmpeg -i ball_lost.wav -c:a libvorbis ball_lost.ogg
```

Or use online converters or audio editing software like Audacity.

## Finding Better Quality Sounds

For commercial-quality sound effects (free for commercial use), check:

- **freesound.org** - Search for CC0 or CC-BY licensed sounds
  - Search terms: "pinball", "click", "bounce", "launch", "success"
  - Sound packs: https://freesound.org/people/GameBoy/packs/36080/
- **opengameart.org** - Free game art and sounds
- **kenney.nl/assets** - Free game assets
- **itch.io** - Free asset packs

**📖 For detailed download instructions and direct links, see: `docs/assets/ASSET_DOWNLOAD_GUIDE.md`.**

**💻 Use the download script:**
```bash
python3 scripts/download_assets.py
```

## Note
The SoundManager will gracefully handle missing sound files by not playing anything if the files don't exist. 
It supports both WAV and OGG formats, preferring OGG if both exist.

