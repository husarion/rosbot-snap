dev-build:
    #!/bin/bash
    export SNAPCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=1
    snapcraft

dev-clean:
    #!/bin/bash
    export SNAPCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=1
    snapcraft clean

_install-rsync:
    #!/bin/bash
    if ! command -v rsync &> /dev/null; then \
        if [ "$EUID" -ne 0 ]; then \
            echo "Please run as root to install dependencies"; \
            exit 1; \
        fi

        sudo apt update && sudo apt install -y rsync
    fi

dev-install:
    #!/bin/bash
    if ls rosbot_*.snap 1> /dev/null 2>&1; then
        sudo snap remove --purge rosbot
        sudo snap install ./rosbot_*.snap --dangerous; \
    else \
        echo "No snap found in current directory. Build it at first (run: just build)"; \
        exit 1; \
    fi

dev-launch:
    #!/bin/bash
    export SERIAL_PORT=/dev/ttyUSB0
    export SERIAL_PORT_SLOT=$(snap interface serial-port | yq .slots[0] | sed 's/^\([^ ]*\) .*/\1/')
    
    sudo snap set rosbot serial-port=$SERIAL_PORT 
    sudo snap connect rosbot:serial-port $SERIAL_PORT_SLOT
    sudo snap connect rosbot:ros-humble ros-humble-ros-base

stop:
    sudo snap disconnect rosbot:ros-humble

info:
    sudo snap get rosbot
    sudo snap connections rosbot

logs:
    sudo snap logs rosbot -n 20

# copy repo content to remote host with 'rsync' and watch for changes
sync hostname password="husarion": _install-rsync
    #!/bin/bash
    sshpass -p "husarion" rsync -vRr --delete ./ husarion@{{hostname}}:/home/husarion/${PWD##*/}
    while inotifywait -r -e modify,create,delete,move ./ ; do
        sshpass -p "{{password}}" rsync -vRr --delete ./ husarion@{{hostname}}:/home/husarion/${PWD##*/}
    done

install-snapcraft:
    sudo snap install lxd
    sudo lxd init --minimal
    sudo snap install snapcraft --classic
    # fixing issues with networking (https://documentation.ubuntu.com/lxd/en/latest/howto/network_bridge_firewalld/?_ga=2.178752743.25601779.1705486119-1059592906.1705486119#prevent-connectivity-issues-with-lxd-and-docker)
    sudo bash -c 'echo "net.ipv4.conf.all.forwarding=1" > /etc/sysctl.d/99-forwarding.conf'
    sudo systemctl stop docker.service
    sudo systemctl stop docker.socket
    sudo systemctl restart systemd-sysctl
    # now you may need to reboot (after reboot docker will not work until you run `sudo systemctl start docker.service`)

    # Enable the hotplug feature and restart the `snapd` daemon (for serial interface):
    sudo snap set core experimental.hotplug=true
    sudo systemctl restart snapd

# run teleop_twist_keybaord (host)
teleop:
    #!/bin/bash
    # export FASTRTPS_DEFAULT_PROFILES_FILE=$(pwd)/shm-only.xml
    ros2 run teleop_twist_keyboard teleop_twist_keyboard # --ros-args -r __ns:=/robot
