# cryptsetup

## How to cryptsetup a local drive
sudo cryptsetup luksOpen /dev/sdb1 manual-teracaddy
sudo mkdir /media/avar/teracaddy
sudo mount /dev/mapper/manual-teracaddy /media/avar/teracaddy

## Close it
sudo cryptsetup close manual-teracaddy

# rpm

## Building

The macros are in /usr/lib/rpm/macros, e.g. %configure etc.

Also available via: rpm --showrc
