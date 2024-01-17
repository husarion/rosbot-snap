# rosbot-xl-snap

This snap packages the [`rosbot_ros`](https://github.com/husarion/rosbot_ros) package.
It thus conveniently offers all the ROS 2 stack necessary to bring up the [ROSbo](https://husarion.com/manuals/rosbot/) robot,
including IMU driver, robot state publisher, joint state publisher, controllers and more.

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/rosbot)

## Installation

Install the snap as follows,

```bash
snap install rosbot
```

## Setup

Upon installation, depending on your operating system,
you may have to manually connect the snap interface.
You can verify that with the following command,

```bash
$ snap connections rosbot
Interface            Plug                 Slot                            Notes
content[ros-humble]  rosbot:ros-humble    ros-humble-ros-base:ros-humble  manual
network              rosbot:network       :network                        -
network-bind         rosbot:network-bind  :network-bind                   -
serial-port          rosbot:serial-port   :ft230xbasicuart                manual                -
```

The interface `ros-humble` must be connected.

If it isn't, you can issue the following command,

```bash
snap connect rosbot-xl:ros-humble ros-humble-ros-base
```

To connect a serial port run:

```bash
$ snap interface serial-port
name:    serial-port
summary: allows accessing a specific serial port
plugs:
  - rosbot
slots:
  - snapd:ft230xbasicuar
```

And connect the interface:

```bash
export SERIAL_PORT_SLOT=$(snap interface serial-port | yq .slots[0] | sed 's/^\([^ ]*\) .*/\1/')
sudo snap connect rosbot:serial-port $SERIAL_PORT_SLOT
```

### Parameters

Depending on your robot hardware,
the snap can be configured through the following parameters:

- mecanum
- serial-port
- serial-baudrate
- namespace

which can be set as follows, e.g.,

```bash
snap set rosbot mecanum=True
snap set rosbot serial-port=/dev/ttyUSB0
```

## Use

The snap ships a daemon which is automatically started once the snap is installed and configured.
Therefore, there is nothing else to do than to start using your rosbot-xl.

<!-- > **Note**
> This snap is part of an integrated snaps deployment.
> 
> Other recommended snaps to be installed are,
> 
> - [micro-xrce-dds-agent](LINK)
> - [sllidar-ros2](https://snapcraft.io/sllidar-ros2)
> - [rosbot-xl-teleop](https://snapcraft.io/rosbot-xl-teleop)
> - [rosbot-xl-nav](https://snapcraft.io/rosbot-xl-nav) -->
