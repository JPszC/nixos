#!/usr/bin/env bash

init() {
    # Vars
    CURRENT_USERNAME='jpszc'

    # Colors
    NORMAL=$(tput sgr0)
    WHITE=$(tput setaf 7)
    BLACK=$(tput setaf 0)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    BRIGHT=$(tput bold)
    UNDERLINE=$(tput smul)
}

comfirm() {
    echo -en "[${GREEN}y${NORMAL}/${RED}n${NORMAL}]: "
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]
    then
        exit 0
    fi
}


get_disk() {
    lsblk
    echo -en "Enter your$GREEN disk$NORMAL : $YELLOW"
    read disk
    echo -en "$NORMAL"
    echo -en "Use$YELLOW "$disk"$NORMAL as ${GREEN}disk${NORMAL} ? "
    comfirm
}

get_lukspassword() {
    echo -en "Enter your$GREEN Luks Password$NORMAL : $YELLOW"
    read lkpass
    echo -en "$NORMAL"
    echo -en "Use$YELLOW "$lkpass"$NORMAL as ${GREEN}Luks Password${NORMAL} ? "
    comfirm
}

set_disk() {
    sed -i -e "s/\/dev\/sda/\/dev\/${disk}/g" ./disko.nix
}

set_lukspassword() {
    echo -n "${lkpass}" > /etc/lk.key
}

install() {
    echo -e "\n${RED}START INSTALL PHASE${NORMAL}\n"
    sleep 0.2
    
	# Format Disk
	echo -e "\nFormating disk...\n"
	nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko.nix
	sleep 0.2
	lsblk
	echo -en "\nIs the format correct...?"
	comfirm
	
	# Generate hardware-configuration
    nixos-generate-config --no-filesystems --root /mnt
	sleep 0.2
	# copy nix files
	cp -r * /mnt/etc/nixos
	sleep 0.2
	cp -r /mnt/etc/nixos /mnt/persist
	
	# creae dirs
	mkdir /mnt/persist/home
	mkdir /mnt/persist/system
	sleep 0.2
	
	# make it easy TODO FIX
	chmod 777 /mnt/persist/system
	chmod 777 /mnt/persist/home
	
    # Last Confirmation
    echo -en "You are about to start the system build, do you want to process ? "
    comfirm
	
	# install nix
	echo -e "\nBuilding the system...\n"
	nixos-install --root /mnt --flake /mnt/etc/nixos#default
	cp -r /etc/lk.key /mnt/persist/system/etc
}
main() {
    init

    get_disk
    get_lukspassword
	
	set_disk
	set_lukspassword
    install
}

main && exit 0