#!/bin/bash
# Script to save energy or restore performance

echo "Choose an option:"
echo "1 - Save energy"
echo "2 - Restore performance"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    echo "Applying power saving settings."

    # 1. Reducing screen brighness by 50%
    echo "Reducing screen brightness by 50%..."
    current_brightness=$(cat /sys/class/backlight/*/brightness)
    max_brightness=$(cat /sys/class/backlight/*/max_brightness)
    new_brightness=$((current_brightness / 2))
    sudo tee /sys/class/backlight/*/brightness <<< "$new_brightness"

    # 2. Disable Bluetooth
    echo "Disabling Bluetooth..."
    sudo rfkill block bluetooth

    # 3. Disable Wi-Fi if not connected to any network
    wifi_status=$(nmcli networking connectivity check)
    if [ "$wifi_status" != "full" ]; then
      echo "No network connected... disabling Wi-Fi..."
      sudo nmcli radio wifi off
    else
      echo "Wi-Fi is connected, skip this step!"
    fi

    # 4. Disable CPU turbo mode
    echo "Disabling CPU turbo mode..."
    if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
      sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo <<< "1"
    else
      echo "Turbo mode not supported or already disabled"
    fi

    echo "Power-saving settings successfully applied!"

elif [ "$choice" == "2" ]; then
    echo "Restoring system settings."

    # 1. Restore screen brightness
    echo "Restoring screen brightness..."
    max_brightness=$(cat /sys/class/backlight/*/max_brightness)
    sudo tee /sys/class/backlight/*/brightness <<< "$max_brightness"

    # 2. Re-enable Bluetooth
    echo "Re-enabling Bluetooth..."
    sudo rfkill unblock bluetooth

    # 3. Re-enabling Wi-Fi
    echo "Re-enabling Wi-Fi..."
    sudo nmcli radio wifi on

    # 4. Re-enable CPU turbo mode
    echo "Re-enabling CPU turbo mode..."
    if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
      sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo <<< "0"
    else
      echo "Turbo mode not supported or already enable."
    fi

    echo "System setting successfully restored!"

else
    echo "Invalid option. Choose 1 or 2."
fi
