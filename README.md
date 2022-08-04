# midi2key
## midi2key - OBS studio scene switcher for Linux

### Simple bash script that converts MIDI signals to keypresses that can be used for scene switching in OBS.

Works in Ubuntu 18 and 20 but most likely any distro/version that can properly run xdotool.

**Requires xdotool to be installed (available via apt in Ubuntu)**

Supports two MIDI keyboards right now
* Akai MPK Mini
* Akai LPD8

For both pads, the keypresses are CTRL+ALT+X where X is a number
For the MPK mini, the keypresses are CTRL+SHIFT for key bank 2

### How to use
* Install xdotool
* Launch **midi2key.sh**, make sure that the MIDI keyboard is properly detected
* In OBS studio, choose to bind a hotkey for a particular scene switch and then press the desired key on the keypad
