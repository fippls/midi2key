#!/bin/bash

# midi2key
# Transform MIDI inputs to keypresses in linux
# Author Fippls, 2019

# Note 48 = pad 5
# Note 49 = pad 6
# Note 44 = pad 1

VERSION="2.0.2"
#
# Changelog:
#   1.0 - 2019-05 - Initial version
#   1.1 - 2020-02 - Added support for all 8 pads on 2 banks
#   2.0   2021-02 - Support for auto-detection of multiple devices
#   2.0.1 2021-02 - Removed debug output
#   2.0.2 2021-03 - Added welcome message
#   2.1.0 2021-05 - Support for some keys on MPK mini

# Name of MIDI devices is listed by 'aseqdump -l'

echo "midi2key $VERSION by Fippls industries inc."
echo ""


if [[ $1 == "-h" ]]; then
   echo "Usage: $0 [-l]"
   echo "   -l List events only (no output)"
   exit 1
fi

# Detect which device to use, in order of priority
# -------------------
detect_midi_keyboard() {
  KEYBOARD=$1

  # Echo the number of keyboards found
  echo `aseqdump -l | grep "$KEYBOARD" | wc -l`
}

if [[ `detect_midi_keyboard "LPD8"` != 0 ]]; then
  echo "Found Akai LPD8"
  DEVICE="LPD8"
elif [[ `detect_midi_keyboard "MPK mini"` != 0 ]]; then
  echo "Found Akai MPK mini"
  DEVICE="MPK mini"
else
  echo "Found no supported MIDI devices!"
  exit 1
fi

# -------------------


if [[ $1 == "-l" ]]; then
   echo "Dumping events only, no keypresses will be reported"
   aseqdump -p "${DEVICE}"
   exit 0
fi

trigger_key() {
  echo "Triggering $1"
  xdotool key $1
}

# Translates a note into a keypress signal
translate_note() {
  if [[ $DEVICE == "MPK mini" ]]; then
    case $1 in
        # Keypad bank #1
        "48" ) trigger_key ctrl+alt+1 ;;
        "49" ) trigger_key ctrl+alt+2 ;;
        "50" ) trigger_key ctrl+alt+3 ;;
        "51" ) trigger_key ctrl+alt+4 ;;

        "44" ) trigger_key ctrl+alt+5 ;;
        "45" ) trigger_key ctrl+alt+6 ;;
        "46" ) trigger_key ctrl+alt+7 ;;
        "47" ) trigger_key ctrl+alt+8 ;;

        # Keypad bank #2
        "36" ) trigger_key ctrl+shift+1 ;;
        "37" ) trigger_key ctrl+shift+2 ;;
        "38" ) trigger_key ctrl+shift+3 ;;
        "39" ) trigger_key ctrl+shift+4 ;;

        "32" ) trigger_key ctrl+shift+5 ;;
        "33" ) trigger_key ctrl+shift+6 ;;
        "34" ) trigger_key ctrl+shift+7 ;;
        "35" ) trigger_key ctrl+shift+8 ;;

        # Regular keys
        "72" ) trigger_key ctrl+F1 ;;
        "71" ) trigger_key ctrl+F2 ;;
        "69" ) trigger_key ctrl+F3 ;;
    esac      
  elif [[ $DEVICE == "LPD8" ]]; then
     case $1 in
        # LPD8 only has a single set of pads
        "40" ) trigger_key ctrl+alt+1 ;;
        "41" ) trigger_key ctrl+alt+2 ;;
        "42" ) trigger_key ctrl+alt+3 ;;
        "43" ) trigger_key ctrl+alt+4 ;;

        "36" ) trigger_key ctrl+alt+5 ;;
        "37" ) trigger_key ctrl+alt+6 ;;
        "38" ) trigger_key ctrl+alt+7 ;;
        "39" ) trigger_key ctrl+alt+8 ;;
     esac
  fi
}


aseqdump -p "${DEVICE}" | \
while IFS=" ," read src ev1 ev2 ch label1 data1 label2 data2 rest; do
    # For "Note on" events, see if the actual note is relevant:
    case "$ev1 $ev2" in
        "Note on" ) translate_note $data1
    esac
done
