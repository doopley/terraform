#!/bin/bash

# Print colored message
function printf_colored() {
    local color=$1
    local message=$2

    success="\e[0;92m"
    danger="\e[0;91m"
    info="\e[0;94m"
    warning="\e[0;93m"
    expand_bg="\e[K"
    info_bg="\e[0;104m${expand_bg}"
    danger_bg="\e[0;101m${expand_bg}"
    success_bg="\e[0;102m${expand_bg}"
    white="\e[0;97m"
    bold="\e[1m"
    uline="\e[4m"
    reset="\e[0m"

    printf "${!color}${message}${reset}\n"
}

# Read input
read_input() {
    read -p "$1 " input
    echo "$input"
}

# Fcuntion to remove files or folders with action skip, remove or ask
function remove_action() {
    local path=$1
    local action=$2

    # Default values file
    local path_type="f"
    local path_type_name="file"

    # Check if path is a folder
    if [ -d "$path" ]; then
        path_type="d"
        path_type_name="folder"
    fi

    if [ -$path_type "$path" ] && [ "$action" == "skip" ]; then
        printf_colored "success" "Continuing, the $path_type_name '$path' > not removed"
        return
    fi

    if [ -$path_type "$path" ] && [ "$action" == "remove" ]; then
        rm -rf "$path"
        printf_colored "danger" "$path_type_name > '$path' deleted"
        return
    fi

    if [ -$path_type "$path" ]; then
        read -p "Do you want to delete the $path_type_name '$path'? [y/n]: " answer
        if [ "$answer" == "y" ]; then
            rm -rf "$path"
            printf_colored "danger" "$path_type_name > '$path' deleted"
        fi
    else
        printf_colored "warning" "$path_type_name > '$path' not found or already deleted"
    fi
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --continue)
            continue=true
            shift
            ;;
        --destroy)
            action=destroy
            action_ssh_key="skip"
            action_tfvars="skip"
            action_terraform_root="remove"
            action_tfstate="remove"
            action_tfstate_backup="remove"
            action_setup_output="remove"
            shift
            ;;
        --clean)
            action=destroy
            action_ssh_key="remove"
            action_terraform_root="remove"
            action_tfvars="remove"
            action_tfstate="remove"
            action_tfstate_backup="remove"
            action_setup_output="remove"
            shift
            ;;
        --action-all=*)
            action_ssh_key="${1#*=}"
            action_terraform_root="${1#*=}"
            action_tfvars="${1#*=}"
            action_tfstate="${1#*=}"
            action_tfstate_backup="${1#*=}"
            action_setup_output="${1#*=}"
            shift
            ;;
        --action-ssh_key=*)
            action_ssh_key="${1#*=}"
            shift
            ;;
        --action-terraform_root=*)
            action_terraform_root="${1#*=}"
            shift
            ;;
        --action-tfvars=*)
            action_tfvars="${1#*=}"
            shift
            ;;
        --action-tfstate=*)
            action_tfstate="${1#*=}"
            shift
            ;;
        --action-tfstate_backup=*)
            action_tfstate_backup="${1#*=}"
            shift
            ;;
        --action-setup_output=*)
            action_setup_output="${1#*=}"
            shift
            ;;
        username=*)
            username="${1#*=}"
            shift
            ;;
        do_token=*)
            do_token="${1#*=}"
            shift
            ;;
        project=*)
            project="${1#*=}"
            if [ ! -d "$project" ]; then
                printf_colored "danger" "Project ($project) not found"
                exit 1
            fi
            shift
            ;;
        action=*)
            action="${1#*=}"
            shift
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
done

### Select project
if [ -z "$project" ]; then
    printf_colored "info" "List of projects:"
    for d in */; do
        echo "* $d"
    done
    project=$(read_input "Select project (folder_name): ")
fi

if [ ! -d "$project" ]; then
    printf_colored "danger" "Project ($project) not found"
    exit 1
fi

cd $project

### Start
printf_colored "info" "Start $project"

### Username
if [ -z "$username" ]; then
    username=$(read_input "Enter username: ")
fi

### Select action

if [ -z "$action" ]; then
    action=$(read_input "Select action [init, destroy, plan, apply]: ")
fi

if [ "$action" != "destroy" ]; then
    ### SSH Key for username
    ssh_key="../ssh_keys/$username"
    if [ ! -f "$ssh_key" ]; then
        printf_colored "danger" "($username) your ssh_key ($ssh_key) was not found"

        read -p "Do you want to create a new key? [y/n]: " answer_key_create
        if [ "$answer_key_create" == "y" ]; then
            ssh-keygen -m PEM -f $ssh_key -N ""
            printf_colored "success" "The ssh_key ($ssh_key) for your account ($username) was created"
        else
            printf_colored "warning" "You need to create a new key for ($username)"
            exit 1
        fi
    else
        printf_colored "success" "Welcome ($username) your ssh_key ($ssh_key) is ready to use"
    fi
    chmod 600 $ssh_key

    ### Setup terraform.tfvars
    if [ ! -f "terraform.tfvars" ]; then
        printf_colored "danger" "File terraform.tfvars not found"
        setup_tfvar=$(read_input "Do you want to create terraform.tfvars? [y/n]: ")
        if [ "$setup_tfvar" == "y" ]; then
            if [ -z "$do_token" ]; then
                do_token=$(read_input "Insert your DigitalOcean token: ")
            fi
            sed "s/USERNAME/$username/g;s/DO_TOKEN/$do_token/g" terraform.tfvars.example > terraform.tfvars
            printf_colored "success" "File terraform.tfvars created"
        else
            printf_colored "warning" "You need to terraform.tfvars"
            exit 1
        fi
    else
        printf_colored "success" "File terraform.tfvars is ready to use"
    fi

    printf_colored "info" ">>> Remember to add the public key to DigitalOcean <<<"
fi

### Continue - Ask or not, give the option to continue for the next step before the action
### Give a time to save the ssh key in DigitalOcean
if [ "$continue" = "true" ]; then
    printf_colored "info" "Continuing terraform apply ..."
else
    read -p "Do you want to continue? [y/n]: " answer_continue
    if [ "$answer_continue" != "y" ]; then
        printf_colored "danger" "You need to continue"
        exit 1
    fi
fi

printf_colored "info" "---------- $action ----------"

if [ "$action" == "init" ]; then
    printf_colored "success" "Terrform initialize"
    terraform init
elif [ "$action" == "plan" ]; then
    printf_colored "success" "Terraform plan infrastructure"
    terraform init
    terraform plan
elif [ "$action" == "apply" ]; then
    printf_colored "success" "Apply terraform infrastructure"
    terraform init
    terraform plan
    terraform apply --auto-approve | tee setup_output.txt
elif [ "$action" == "destroy" ]; then
    printf_colored "danger" "Destroy infrastructure"

    terraform destroy --auto-approve
    remove_action ".terraform" "$action_terraform_root"
    remove_action "terraform.tfstate.backup" "$action_tfstate_backup"
    remove_action "terraform.tfstate" "$action_tfstate"
    remove_action "setup_output.txt" "$action_setup_output"

    if [ ! -f "terraform.tfvars" ]; then
        printf_colored "danger" "File terraform.tfvars not found"
        exit 1
    fi

    ssh_key=$(grep 'pvt_key' terraform.tfvars | cut -d '"' -f 2)

    remove_action "terraform.tfvars" "$action_tfvars"
    remove_action "$ssh_key" "$action_ssh_key"
    remove_action "$ssh_key.pub" "$action_ssh_key"
else
    printf_colored "danger" "Invalid action"
    exit 1
fi
