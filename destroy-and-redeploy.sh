# Destroy all AWS resources managed by Terraform, then redeploy everything

set -e
set -a
source .env
set +a

# Destroy AWS ECS INFRASTRUCTURE
cd terraform-ecs
echo "Destroying all AWS resources managed by Terraform"
terraform destroy 
cd ..

echo "Re-applying Terraform to recreate infrastructure"
cd terraform-ecs
terraform apply 
cd ..

echo "Deploying application"
./deploy-latest.sh

echo "All resources destroyed and redeployed."
