#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

installApps()
{
    clear
    OS="$REPLY" ## <-- This $REPLY is about OS Selection
    echo -e "${NC}You can Install ${GREEN}Docker ${NC}and ${GREEN}Docker-Compose${NC} ${NC}with this script!${NC}"
    echo -e "Please select ${GREEN}'y'${NC} for each item you would like to install."
    echo -e "${RED}NOTE:${NC} Without Docker you cannot use Docker-Compose.${NC}"
    echo -e ""
    echo -e ""
    echo -e "      ${CYAN}Provided to you by ${YELLOW}Mohammad Mohammadpour${NC}"
    echo -e "          ${YELLOW}https://github.com/shawshanck${NC}"
    echo -e ""
    
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Try to check whether docker is installed and running - don't prompt if it is
    if [[ "$ISACT" != "active" ]]; then
        read -rp "Docker-CE (y/n): " DOCK
    else
        echo -e "${GREEN}Docker appears to be installed and running.${NC}"
        echo -e ""
        echo -e ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        read -rp "Docker-Compose (y/n): " DCOMP
    else
        echo -e "${GREEN}Docker-compose appears to be installed.${NC}"
        echo -e ""
        echo -e ""
    fi
    
    startInstall
}

startInstall() 
{
    clear
    echo "#######################################################"
    echo "###         Preparing for Installation              ###"
    echo "#######################################################"
    echo ""
    sleep 3s

#######################################################
###           Install for Debian / Ubuntu           ###
#######################################################

    if [[ "$OS" == [234] ]]; then
        echo -e "${BLUE}    1. Installing System Updates... This may take a while... ${GREEN}Please be patient! ${BLUE}If it is being done on a Digial Ocean VPS, you should run updates before running this script.${NC}"
        (sudo apt update && sudo apt upgrade -y) > ~/docker-script-install.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo -e "${BLUE}    2. Install Prerequisite Packages...${NC}"
        sleep 2s

        sudo apt install curl wget git -y >> ~/docker-script-install.log 2>&1
        
        if [[ "$ISACT" != "active" ]]; then
            echo -e "${GREEN}    3. Installing Docker-CE (Community Edition)...${NC}"
            sleep 2s

        
            curl -fsSL https://get.docker.com | sh >> ~/docker-script-install.log 2>&1
            echo -e "${YELLOW}         - Docker-Ce version is now:${NC}"
            DOCKERV=$(docker -v)
            echo -e "${NC}          ${NC}"${DOCKERV}
            sleep 3s

            if [[ "$OS" == 2 ]]; then
                echo "${GREEN}    5. Starting Docker Service${NC}"
                sudo systemctl docker start >> ~/docker-script-install.log 2>&1
            fi
        fi

    fi
        
    
#######################################################
###              Install for CentOS 7 or 8          ###
#######################################################
    if [[ "$OS" == "1" ]]; then
        if [[ "$DOCK" == [yY] ]]; then
            echo "    1. Updating System Packages..."
            sudo yum check-update > ~/docker-script-install.log 2>&1

            echo "    2. Installing Prerequisite Packages..."
            sudo dnf install git curl wget -y >> ~/docker-script-install.log 2>&1

            if [[ "$ISACT" != "active" ]]; then
                echo "    3. Installing Docker-CE (Community Edition)..."

                sleep 2s
                (curl -fsSL https://get.docker.com/ | sh) >> ~/docker-script-install.log 2>&1

                echo "    4. Starting the Docker Service..."

                sleep 2s


                sudo systemctl start docker >> ~/docker-script-install.log 2>&1

                echo "    5. Enabling the Docker Service..."
                sleep 2s

                sudo systemctl enable docker >> ~/docker-script-install.log 2>&1

                echo "      - docker version is now:"
                DOCKERV=$(docker -v)
                echo "        "${DOCKERV}
                sleep 3s
            fi
        fi
    fi

#######################################################
###               Install for Arch Linux            ###
#######################################################

    if [[ "$OS" == "5" ]]; then
        read -rp "Do you want to install system updates prior to installing Docker-CE? (y/n): " UPDARCH
        if [[ "$UPDARCH" == [yY] ]]; then
            echo "    1. Installing System Updates... this may take a while...be patient."
            (sudo pacman -Syu --noconfirm) > ~/docker-script-install.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        else
            echo "    1. Skipping system update..."
            sleep 2s
        fi

        echo "    2. Installing Prerequisite Packages..."
        sudo pacman -Sy git curl wget --noconfirm >> ~/docker-script-install.log 2>&1

        if [[ "$ISACT" != "active" ]]; then
            echo "    3. Installing Docker-CE (Community Edition)..."
            sleep 2s

            sudo pacman -Sy docker --noconfirm >> ~/docker-script-install.log 2>&1

            echo "    - docker-ce version is now:"
            DOCKERV=$(docker -v)
            echo "        "${DOCKERV}
            sleep 3s
        fi
    fi

#######################################################
###               Install for Open Suse             ###
#######################################################

    if [[ "$OS" == "6" ]]; then
        # install system updates first
        read -rp "Do you want to install system updates prior to installing Docker-CE? (y/n): " UPDSUSE
        if [[ "$UPDSUSE" == [yY] ]]; then
            echo "    1. Installing System Updates... this may take a while...be patient."

            (sudo zypper -n update) > docker-script-install.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        else
            echo "    1. Skipping system update..."
            sleep 2s
        fi

        echo "    2. Installing Prerequisite Packages..."
        sudo zypper -n install git curl wget >> ~/docker-script-install.log 2>&1

        if [[ "$ISACT" != "active" ]]; then
            echo "    3. Installing Docker-CE (Community Edition)..."
            sleep 2s

            sudo zypper -n install docker-compose >> ~/docker-script-install.log 2>&1
            sudo zypper -n remove docker-compose
            echo "Giving the Docker service time to start..."
        
            sudo systemctl start docker >> ~/docker-script-install.log 2>&1
            sleep 5s &
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
            sudo systemctl enable docker >> ~/docker-script-install.log 2>&1

            echo "    - docker-ce version is now:"
            DOCKERV=$(docker -v)
            echo "        "${DOCKERV}
            sleep 3s
        fi
    fi

    if [[ "$ISACT" != "active" ]]; then
        if [[ "$DOCK" == [yY] ]]; then
            # add current user to docker group so sudo isn't needed
            echo ""
            echo "  - Attempting to add the currently logged in user to the docker group..."

            sleep 2s
            sudo usermod -aG docker "${USER}" >> ~/docker-script-install.log 2>&1
            echo "  - You'll need to log out and back in to finalize the addition of your user to the docker group."
            echo ""
            echo ""
            sleep 3s
        fi
    fi

    if [[ "$DCOMP" = [yY] ]]; then
        echo "############################################"
        echo "######     Install Docker-Compose     ######"
        echo "############################################"

        # install docker-compose
        echo ""
        echo -e "${GREEN}    1. Installing Docker-Compose...${NC}"
        echo ""
        echo ""
        sleep 2s

        ######################################
        ###     Install Debian / Ubuntu    ###
        ######################################        
        
        if [[ "$OS" == "2" || "$OS" == "3" || "$OS" == "4" ]]; then
            VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
		    sudo curl -SL https://github.com/docker/compose/releases/download/$VERSION/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
            #sudo curl -L "https://github.com/docker/compose/releases/download/$(curl https://github.com/docker/compose/releases | grep -m1 '<a href="/docker/compose/releases/download/' | grep -o 'v[0-9:].[0-9].[0-9]')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

            sleep 2
            sudo chmod +x /usr/local/bin/docker-compose
        fi
        ######################################
        ###        Install CentOS 7 or 8   ###
        ######################################

        if [[ "$OS" == "1" ]]; then
            VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
		    sudo curl -SL https://github.com/docker/compose/releases/download/$VERSION/docker-compose-linux-x86_64 -o /usr/bin/docker-compose >> ~/docker-script-install.log 2>&1

            sudo chmod +x /usr/bin/docker-compose >> ~/docker-script-install.log 2>&1
        fi

        ######################################
        ###        Install Arch Linux      ###
        ######################################

        if [[ "$OS" == "5" ]]; then
            sudo pacman -Sy docker-compose --noconfirm > ~/docker-script-install.log 2>&1
        fi

        ######################################
        ###        Install Open Suse       ###
        ######################################

        if [[ "$OS" == "6" ]]; then
            VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
		    sudo curl -SL https://github.com/docker/compose/releases/download/$VERSION/docker-compose-linux-x86_64 -o /usr/bin/docker-compose >> ~/docker-script-install.log 2>&1

            sudo chmod +x /usr/bin/docker-compose >> ~/docker-script-install.log 2>&1
        fi

        echo ""

        echo -e "${YELLOW}      - Docker Compose Version is now: ${NC}" 
        DOCKCOMPV=$(docker-compose --version)
        echo "        "${DOCKCOMPV}
        echo ""
        echo ""
        sleep 3s
    fi

    ##########################################
    #### Test if Docker Service is Running ###
    ##########################################
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    if [[ "$ISACt" != "active" ]]; then
        echo -e "${GRREN}Giving the Docker service time to start...${NC}"
        while [[ "$ISACT" != "active" ]] && [[ $X -le 10 ]]; do
            sudo systemctl start docker >> ~/docker-script-install.log 2>&1
            sleep 10s &
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
            ISACT=`sudo systemctl is-active docker`
            let X=X+1
            echo "$X"
        done
    fi

    echo "################################################"
    echo "######      Create a Docker Network    #########"
    echo "################################################"

    sudo docker network create my-main-net
    sleep 3s
    cd

    echo -e "${GREEN}Docker and Docker-Compose installed successfully.${NC}"
    echo ""
    echo -e "${RED}Note:${NC} If you add more docker applications to this server, make sure to add them to the ${GREEN}my-main-app${NC} network."
    echo ""
    echo -e "      ${CYAN}Provided to you by ${YELLOW}Mohammad Mohammadpour${NC}"
    echo -e "          ${YELLOW}https://github.com/shawshanck${NC}"

    exit 1
}

echo ""
echo ""

clear

echo -e "${YELLOW}Let's figure out which OS / Distro you are running.${NC}"
echo -e ""
echo -e ""
echo -e "${GREEN}    From some basic information on your system, you appear to be running: ${NC}"
echo -e "${GREEN}        --  OS Name            ${NC}" $(lsb_release -i)
echo -e "${GREEN}        --  Description        ${NC}" $(lsb_release -d)
echo -e "${GREEN}        --  OS Version         ${NC}" $(lsb_release -r)
echo -e "${GREEN}        --  Code Name          ${NC}" $(lsb_release -c)
echo -e ""
echo -e "${YELLOW}------------------------------------------------${NC}"
echo -e ""

PS3="Please select the number for your OS / distro: "
select _ in \
    "CentOS 7 / 8 / Fedora" \
    "Debian 10 / 11" \
    "Ubuntu 18.04" \
    "Ubuntu 20.04 / 21.04 / 22.04" \
    "Arch Linux" \
    "Open Suse"\
    "End this Installer"
do
  case $REPLY in
    1) installApps ;;
    2) installApps ;;
    3) installApps ;;
    4) installApps ;;
    5) installApps ;;
    6) installApps ;;
    7) exit ;;
    *) echo "Invalid selection, please try again..." ;;
  esac
done
