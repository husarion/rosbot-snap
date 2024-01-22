#!/usr/bin/bash

# Iterate over the snap parameters and retrieve their value.
# If a value is set, it is forwarded to the launch file.
OPTIONS="mecanum serial-port serial-baudrate namespace flash"
unset LAUNCH_OPTIONS
FLASH_OPTION_SET=false
SERIAL_PORT_VALUE=""

for OPTION in ${OPTIONS}; do
  VALUE="$(snapctl get ${OPTION})"
  if [ -n "${VALUE}" ]; then
    if [ "${OPTION}" == "flash" ] && [ "${VALUE}" == "True" ]; then
      FLASH_OPTION_SET=true
    elif [ "${OPTION}" == "serial-port" ]; then
      SERIAL_PORT_VALUE=${VALUE}
      LAUNCH_OPTIONS+="${OPTION}:=${VALUE} "
    else
      LAUNCH_OPTIONS+="${OPTION}:=${VALUE} "
    fi
  fi
done

echo "launch options: ${LAUNCH_OPTIONS}"

# Process command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
  serial-port=*)
    # Extract the value and update it in LAUNCH_OPTIONS
    SERIAL_PORT="${1#*=}"
    LAUNCH_OPTIONS=$(echo ${LAUNCH_OPTIONS} | sed "s|serial-port:=\S*|serial-port:=${SERIAL_PORT}|")
    ;;
  *)
    echo "Unknown parameter passed: $1"
    exit 1
    ;;
  esac
  shift
done

# Replace '-' with '_'
LAUNCH_OPTIONS=$(echo ${LAUNCH_OPTIONS} | tr - _)

echo "launch options: ${LAUNCH_OPTIONS}"

# Check if flash option is set and is True
if [ "$FLASH_OPTION_SET" = true ]; then
  echo "Flashing firmware..."
  ros2 run rosbot_utils flash_firmware --usb --port ${SERIAL_PORT_VALUE}
fi

echo "Running combined.launch.py with options: ${LAUNCH_OPTIONS}"
ros2 launch rosbot_bringup combined.launch.py ${LAUNCH_OPTIONS}
