#!/bin/bash

# midi2key
# Transform MIDI inputs to keypresses in linux, plus sending CC to other devices
# Author Fippls, 2019

# Note 48 = pad 5
# Note 49 = pad 6
# Note 44 = pad 1

VERSION="3.0"

# Print value changes to console
DEBUG=1

# Which Control Change number should be used to control the mixer?
# For Behringer XR16, midi channel 1 fader control:
#    0  - 15 = Input channels 1-16
#    21 - 26 = FX send / Subgroups
#    31 - Main L/R
CC_TARGET=25


# Changelog:
#   1.0 - 2019-05 - Initial version
#   1.1 - 2020-02 - Added support for all 8 pads on 2 banks
#   2.0   2021-02 - Support for auto-detection of multiple devices
#   2.0.1 2021-02 - Removed debug output
#   2.0.2 2021-03 - Added welcome message
#   2.1.0 2021-05 - Support for some keys on MPK mini
#   2.1.1 2026-02 - Added --install option
#   3.0   2026-05 - Added support for sending CC to other MIDI devices, debug on/off

# Name of MIDI devices is listed by 'aseqdump -l'

echo "midi2key $VERSION by Fippls industries inc."
echo ""


if [[ $1 == "-h" ]]; then
   echo "Usage: $0 [-l]"
   echo "   -l        List events only (no output)"
   echo "   --install Install required programs"
   exit 1
fi

# Detect which input device to use, in order of priority
# -------------------
detect_midi_keyboard() {
  local KEYBOARD=$1

  # Echo the number of keyboards found
  echo `aseqdump -l | grep "$KEYBOARD" | wc -l`
}

# Detect which output device to use, in order of priority
# -------------------
detect_midi_out() {
  local DEVICE=$1

  # Echo the number of devices found
  echo `aseqdump -l | grep "$DEVICE" | wc -l`
}

# Detect which input device to use (uses hw:xx:xx notation)
detect_midi_in() {
   local DEVICE=$1

   # Search for given device and print hardware address
   echo `amidi -l | grep $DEVICE | awk '{ print $2 }'`
}

log() {
   if [[ $DEBUG == 1 ]]; then
      echo $1
   fi
}

# Detect output (read) device
if [[ `detect_midi_keyboard "LPD8"` != 0 ]]; then
  echo "Found Akai LPD8"
  INPUT="LPD8"
elif [[ `detect_midi_keyboard "MPK mini"` != 0 ]]; then
  echo "Found Akai MPK mini"
  INPUT="MPK mini"
else
  echo "Found no supported MIDI devices for input!"
  exit 1
fi

# Detect input (write) device
OUTPUT=`detect_midi_in "CH345"`
if [[ $OUTPUT != "" ]]; then
   echo "Found CH345 MIDI output device on $OUTPUT"
else
   echo "Found no supported MIDI output device."
fi


# -------------------


if [[ $1 == "-l" ]]; then
   echo "Dumping events only, no keypresses will be reported"
   aseqdump -p "${INPUT}"
   exit 0
fi

if [[ $1 == "--install" ]]; then
   echo "Installing required programs..."
   sudo apt install xdotool alsa-utils
   exit 0
fi


trigger_key() {
  log "Triggering $1"
  xdotool key $1
}

# Send a Control Change message on channel using amidi
# Arguments:  $1 = CC number
#             $2 = Value
send_cc() {
    local cc_num=$1
    local cc_val=$2

    # Build the three-byte message in hex and pipe it to amidi.
    # amidi expects a list of hex numbers separated by spaces.
    # B0 = MIDI channel 1 (fader control)
    local hex=`printf 'B0%02X%02X' "$cc_num" "$cc_val"`
    amidi -p "$OUTPUT" --send-hex="$hex"
}


# Translates a control change
translate_control() {
   log "Control update knob $1: $2"

   # Use control knob #1 for volume
   if [[ $1 == 1 ]]; then
   	log "CC number $CC_TARGET control set to $2"
        send_cc $CC_TARGET $2
   fi
}


# Translates a note into a keypress signal
translate_note() {
  if [[ $INPUT == "MPK mini" ]]; then
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
  elif [[ $INPUT == "LPD8" ]]; then
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


aseqdump -p "${INPUT}" | \
while IFS=" ," read src ev1 ev2 ch label1 data1 label2 data2 rest; do
    # For "Note on" events, see if the actual note is relevant:
    case "$ev1 $ev2" in
        "Note on" ) translate_note $data1 ;;
	"Control change" ) translate_control $data1 $data2 ;;
    esac
done
