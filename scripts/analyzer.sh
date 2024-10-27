#!/bin/bash
# Script to display a menu and check system information based on the user's choice

install_and_run_screenfetch() {
    if ! command -v screenfetch &> /dev/null; then
        echo "Installing screenfetch..."
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian)
                    sudo apt update
                    sudo apt install -y screenfetch
                    ;;
                fedora)
                    sudo dnf install -y screenfetch
                    ;;
                arch|manjaro)
                    sudo pacman -Syu --noconfirm screenfetch
                    ;;
                opensuse*)
                    sudo zypper install -y screenfetch
                    ;;
                *)
                    echo "Unsupported distribution for automatic installation."
                    return 1
                    ;;
            esac
        else
            echo "Unable to identify system distribution."
            return 1
        fi
    fi

    echo "Displaying system information:"
    screenfetch
}

while true; do
  echo "Select an option:"
  echo "  1 - Install and check system information (screenfetch)"
  echo "  2 - Check desktop processor"
  echo "  3 - Check system kernel"
  echo "  4 - Check installed software"
  echo "  5 - Operating system version"
  echo "  6 - Check system memory"
  echo "  7 - Check serial number"
  echo "  8 - Check system IP"
  echo "  0 - Exit menu"
  
  read -p "Enter your choice: " choice

  case $choice in
    1)
      install_and_run_screenfetch
      ;;
    2)
      echo "Processor information:"
      lscpu
      ;;
    3)
      echo "Kernel information:"
      uname -r
      ;;
    4)
      echo "Installed software:"
      if [ -f /etc/debian_version ]; then
        dpkg --list
      elif [ -f /etc/redhat-release ]; then
        rpm -qa
      else
        echo "Unsupported system for software check"
      fi
      ;;
    5)
      echo "Operating system version:"
      if [ -f /etc/os-release ]; then
        cat /etc/os-release
      else
        echo "OS information not available."
      fi
      ;;
    6)
      echo "Memory information:"
      free -h
      ;;
    7)
      echo "Serial number:"
      sudo dmidecode -s system-serial-number
      ;;
    8)
      echo "System IP address:"
      ip addr show | grep "inet " | grep -v 127.0.0.1
      ;;
    0)
      echo "Exiting the menu."
      break
      ;;
    *)
      echo "Invalid option. Please choose a number from 0 to 8."
      ;;
  esac
  echo ""
done
