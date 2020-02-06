# switchEKS.sh

Bash script for switching Profile of AWS EKS, Authenticating with MFA, Update kubeconfig. 

## Usage

```
source switchEKS.sh <MFA Device ARN(SerialNumber)> <EKS Cluster Name>
```

## Example

source switchEKS.sh arn:aws:iam::111111:mfa/tanaka eks-test

```bash
$ . ./switchEKS.sh arn:aws:iam::111111171:mfa/snakaya prod-eks
Your AWS Profiles:
  [1] default
  [2] eks-test
  [3] eks-prod
  [4] eks-stg
Select AWS Profile for authentication [1-4]: 3
Input MFA Code[6digit]: 539878
EKS Changing finished to prod-eks on ap-northeast-1.
$  env | grep AWS
AWS_SESSION_TOKEN=FwoGZXIvYXdzEAgaD...aJyOrhHTtxUu2bxikbvgLRfHAF+cUMXWLaNAR9sK
AWS_SECRET_ACCESS_KEY=9r5dr7Z...3G2MH5a33lUe
AWS_DEFAULT_PROFILE=eks-prod
AWS_ACCESS_KEY_ID=ASI...S4J
```
