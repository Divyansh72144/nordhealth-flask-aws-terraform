set -a
source .env
set +a

echo "Building Docker image"
docker build -t nordhealth-flask-aws-terraform:latest . 

echo "Tagging Docker image"
docker tag nordhealth-flask-aws-terraform:latest $ECR_REPO:latest 

echo "Authenticating Docker to ECR"
aws ecr get-login-password --region $AWS_REGION --no-cli-pager | docker login --username AWS --password-stdin $ECR_REPO 

echo "Pushing Docker image to ECR"
docker push $ECR_REPO:latest 

echo "Forcing new ECS deployment"
aws ecs update-service --cluster $CLUSTER --service $SERVICE --force-new-deployment --region $AWS_REGION --no-cli-pager

echo "Deployment triggered!"
exit 0
