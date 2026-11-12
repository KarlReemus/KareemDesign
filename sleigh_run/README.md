# Sleigh Run (Godot 4.5+)

Open this folder in Godot (Import > select project.godot) and press F5.

Controls: W / S or Up / Down to fly, Space to drop a present. On a phone or with the mouse, use the on-screen buttons.

Score: collect gift pickups, drop them down chimneys. Each landed present raises the multiplier by 0.5 (max x8).
A missed house, a present hitting the ground, or hitting an obstacle resets the multiplier. Crashing ends the run.

Swap art: replace the PNGs in assets/sprites/ (keep the same file names and sizes, or adjust scale in the scene).
  train/reindeer_run_sheet_cartoon.png  6 x 2 frames, row 0 = regular, row 1 = red-nose lead
  train/santa_sleigh.png                the sleigh with Santa
Music: put .ogg / .mp3 / .wav files in assets/audio/music/ (they are picked up automatically).
Loose files for desktop testing can also go in the user://music folder (Project > Open User Data Folder).
Sound effects: assets/audio/sfx/{pickup,drop,deliver,crash}.wav (or .ogg).

Tuning numbers: autoload/game.gd (speed, multiplier), scenes/train/train.gd (steering feel), the spawners.
tests/smoke.gd is an optional headless test: godot --headless --fixed-fps 60 --script res://tests/smoke.gd
