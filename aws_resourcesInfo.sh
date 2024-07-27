#!/bin/bash

#######################
# simple script to list the active ec2, s3, lambda and IAM instances and its usage
#######################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check if AWS CLI is configured
check_aws_config() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}Error: AWS CLI is not configured. Please run 'aws configure' first.${NC}"
        exit 1
    fi
}

# Function to list EC2 instances
list_ec2() {
    
	echo -e "${GREEN}EC2 Instances:${NC}"
    	instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table)
    	if [ -z "$instances" ]; then
        	echo -e "${YELLOW}No EC2 instances found.${NC}"
    	else
        	echo "$instances"
    	fi
}

# Function to list S3 buckets
list_s3() {
    
	echo -e "${GREEN}S3 Buckets:${NC}"
    	buckets=$(aws s3 ls)
    	if [ -z "$buckets" ]; then
        	echo -e "${YELLOW}No S3 buckets found.${NC}"
    	else
        	echo "$buckets"
    	fi
}

# Function to list Lambda functions
list_lambda() {
    echo -e "${GREEN}Lambda Functions:${NC}"
    functions=$(aws lambda list-functions --query 'Functions[*].[FunctionName,Runtime,MemorySize,LastModified]' --output table)
    if [ -z "$functions" ]; then
        echo -e "${YELLOW}No Lambda functions found.${NC}"
    else
        echo "$functions"
    fi
}

# Function to list IAM users
list_iam() {
    echo -e "${GREEN}IAM Users:${NC}"
    users=$(aws iam list-users --query 'Users[*].[UserName,CreateDate]' --output table)
    if [ -z "$users" ]; then
        echo -e "${YELLOW}No IAM users found.${NC}"
    else
        echo "$users"
    fi
}

# Main menu
show_menu() {
    echo -e "${YELLOW}AWS Resource Lister${NC}"
    echo "1. List EC2 Instances"
    echo "2. List S3 Buckets"
    echo "3. List Lambda Functions"
    echo "4. List IAM Users"
    echo "5. List All Resources"
    echo "6. Exit"
}

# Main function
main() {
    check_aws_config
    while true; do
        show_menu
        read -p "Enter your choice [1-6]: " choice
        case $choice in
            1) list_ec2 ;;
            2) list_s3 ;;
            3) list_lambda ;;
            4) list_iam ;;
            5)
                list_ec2
                echo
                list_s3
                echo
                list_lambda
                echo
                list_iam
                ;;
            6) echo "Exiting..."; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac
        echo
        read -p "Press enter to continue..."
        clear
    done
}

# Run the main function
main
