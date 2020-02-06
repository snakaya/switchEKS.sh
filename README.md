# switchEKS.sh

Bash script for switching Profile of AWS EKS, Authenticating with MFA, Update kubeconfig. 

## Usage

```
switchEKS.sh <MFA Device ARN(SerialNumber)> <EKS Cluster Name>
```

## Example

switchEKS.sh arn:aws:iam::111111:mfa/tanaka eks-test

```bash
$ . ./switchEKS.sh arn:aws:iam::108242370871:mfa/snakaya prod-eks-poc-vp
Your AWS Profiles:
  [1] default
  [2] vptest
  [3] vpprod
  [4] vpstg
Select AWS Profile for authentication [1-4]: 3
Input MFA Code[6digit]: 539878
EKS Changing finished to prod-eks-poc-vp on ap-northeast-1.
$  env | grep AWS
AWS_SESSION_TOKEN=FwoGZXIvYXdzEAgaD...aJyOrhHTtxUu2bxikbvgLRfHAF+cUMXWLaNAR9sK
AWS_SECRET_ACCESS_KEY=9r5dr7Z...3G2MH5a33lUe
AWS_DEFAULT_PROFILE=vpprod
AWS_ACCESS_KEY_ID=ASI...S4J
```
