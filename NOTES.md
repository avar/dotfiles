# cryptsetup

## How to cryptsetup create a local drive

sudo cryptsetup --debug luksFormat --verify-passphrase /dev/sdc
sudo cryptsetup luksOpen /dev/sdc manual-teracaddy
sudo cfdisk /dev/mapper/manual-teracaddy
# gpt -> new partition etc.
sudo mkfs -v -t ext4 -L teracaddy -T big /dev/mapper/manual-teracaddy1

## How to cryptsetup "mount" a local drive
sudo cryptsetup luksOpen /dev/sdb1 manual-teracaddy
sudo mkdir /media/avar/teracaddy
sudo mount /dev/mapper/manual-teracaddy /media/avar/teracaddy

## Close it
sudo cryptsetup close manual-teracaddy

# rpm

## Building

The macros are in /usr/lib/rpm/macros, e.g. %configure etc.

Also available via: rpm --showrc
