# midi2key
## midi2key - OBS studio scene switcher for Linux

### Simple bash script that converts MIDI signals to keypresses that can be used for scene switching in OBS.

Works in Ubuntu 18 and 20 but most likely any distro/version that can properly run xdotool.

**Requires xdotool and aseqdump to be installed (available via apt, or install automatically with the --install flag)**

Supports two MIDI keyboards and one USB to MIDI device right now:
* Akai MPK Mini
* Akai LPD8
* Plexgear CH345 USB to MIDI device

For both keyboard pads, the keypresses are CTRL+ALT+X where X is a number
For the MPK mini, the keypresses are CTRL+SHIFT for key bank 2

### Additional control for version 3 and above
I wanted to use the control knobs on the Akai MPK Mini to control the volume of the monitor channel on my Behringer XR16
digital mixer, so version 3 has support for reading the position of knob #1 and sending that value via the Plexgear USB to
MIDI device into the XR16 mixer, which will then change the volume of the channel I'm using for booth monitoring.

### How to use
* Either just run **./midi2key.sh --install**, or manually install xdotool and alsa-utils
* Launch **midi2key.sh**, make sure that the MIDI keyboard is properly detected
* In OBS studio, choose to bind a hotkey for a particular scene switch and then press the desired key on the keypad
