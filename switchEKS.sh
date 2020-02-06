#!/usr/bin/env bash
#  switchEKS.sh
#  
#
#

function set_profile() {
	local aws_credential_file="$HOME/.aws/credentials"
	local aws_profile_list=(`sed -nE 's|^[ \t]*\[([^]]+)\][ \t]*$|\1|p' < $aws_credential_file`)
	while :; do
		echo "Your AWS Profiles:"
		for i in ${!aws_profile_list[@]} ; do
	  		echo "  [$((i+1))] ${aws_profile_list[$i]}"
		done
		read -p "Select AWS Profile for authentication [1-${#aws_profile_list[@]}]: " select_aws_profile_number
		if [[ ${select_aws_profile_number} =~ ^[1-${#aws_profile_list[@]}]$ ]];then
			break
		fi
	done
	AWS_DEFAULT_PROFILE="${aws_profile_list[$((select_aws_profile_number-1))]}"
	export $AWS_DEFAULT_PROFILE
	if [[ ${AWS_DEFAULT_PROFILE} != "default" ]];then
		ini_section="profile ${AWS_DEFAULT_PROFILE}"
		eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' -e 's/;.*$//' -e 's/[[:space:]]*$//' -e 's/^[[:space:]]*//' -e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" <"${HOME}/.aws/config" | sed -n -e "/^\[${ini_section}\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`
		aws_region=$region
	else
		aws_region=${AWS_DEFAULT_PROFILE}
	fi

	return 0
}

function set_mfacode() {
	while :; do
		read -p "Input MFA Code[6digit]: " input_mfa_code
		if [[ ${input_mfa_code} == "" ]];then
			echo "Error: No MFA Code"
        		echo " "
        		continue
		fi
		if [[ ! ${input_mfa_code} =~ ^[0-9]{6}$ ]];then
			echo "Error: MFA Code must be 6digit numeric."
			echo " "
			continue
		fi
		break
	done
	mfa_code=${input_mfa_code}

	return 0
}

function set_token() {
	unset AWS_ACCESS_KEY_ID
	unset AWS_SECRET_ACCESS_KEY
	unset AWS_SESSION_TOKEN

	sts_json=`aws sts get-session-token --serial-number $mfa_arn --token-code $mfa_code | awk ' $1 == "\"AccessKeyId\":" { gsub(/\"/,""); gsub(/,/,""); print "export AWS_ACCESS_KEY_ID="$2";" } $1 == "\"SecretAccessKey\":" { gsub(/\"/,""); gsub(/,/,""); print "export AWS_SECRET_ACCESS_KEY="$2";" } $1 == "\"SessionToken\":" { gsub(/\"/,""); gsub(/,/,""); print "export AWS_SESSION_TOKEN="$2";" } '`
	if [[ $? -ne 0 || -z "$sts_json" ]]; then
		echo "Error: Fail getting session token."
		return 1
	fi
	eval $sts_json

	return 0
}

function set_cluster() {
	aws eks --region $aws_region update-kubeconfig --name $cluster_name > /dev/null
	if [[ $? -ne 0 ]]; then
                echo "Error: Fail update kubeconfig."
                return 1
        fi
 
	return 0
}

function usage() {
    echo "Usage:  switchEKS.sh <MFA Device ARN(SerialNumber)> <EKS Cluster Name>"
    echo " "
    echo "  Example:"
    echo "  switchEKS.sh arn:aws:iam::111111:mfa/tanaka eks-test"
}


if [[ $# != 2 ]];then
	usage
	return 1	
fi

mfa_arn=$1
cluster_name=$2
mfa_code=""
aws_region=""

set_profile || {
	return 1
}
set_mfacode || {
	return 1
}
set_token || {
	return 1
}
set_cluster || {
	return 1
}

echo "EKS Changing finished to $cluster_name on $aws_region."

return 0
