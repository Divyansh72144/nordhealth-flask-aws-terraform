# Assignment Overview

This project is a “hello world” Flask app that can be run locally in Docker and deployed to AWS using ECS Fargate. All AWS resources are managed with Terraform for easy and reproducible setup.

Follow the instructions below to set up, run, and deploy the application.
# NordHealth Flask AWS Terraform

This project shows how to containerize a Python Flask application, run it locally with Docker, and deploy it to AWS ECS using Terraform.

## Prerequisites
- Python 3.x
- pip
- Docker
- AWS CLI (configured with your credentials)
- Terraform

## Local Development

1. **Install dependencies:**
   ```sh
   pip install -r requirements.txt
   ```


2. **Run the application:**
   ```sh
   python app.py
   ```

**Note:** The app runs on port 8080. When accessing it locally or via a browser, use `http://localhost:8080` or your ECS service's public IP, e.g. `http://16.16.196.225:8080`.


## Docker Usage

1. **Build the Docker image:**
   ```sh
   docker build -t nordhealth-flask-aws-terraform .
   ```


2. **Run the container:**
   ```sh
   docker run --name nordhealthContainer -p 8080:8080 nordhealth-flask-aws-terraform
   ```

**Note:** The app runs on port 8080. When accessing it locally or via a browser, use `http://localhost:8080` or `your-ec2-public-dns:8080`.

## Deploying to AWS ECS with Terraform

### Initial Infrastructure Setup (one-time or after destroy)
1. **Navigate to the Terraform directory:**
   ```sh
   cd terraform-ecs
   ```
2. **Initialize Terraform:**
   ```sh
   terraform init
   ```
3. **Review the plan:**
   ```sh
   terraform plan
   ```
4. **Apply to create AWS infrastructure:**
   ```sh
   terraform apply
   ```
   
### Deploy Latest App Changes to AWS ECS

To deploy the latest code changes (without AWS ECS infrastructure changes), from your project root directory, run:

```sh
./deploy-latest.sh
```

- To Build, tag, and push your Docker image to ECR
- It triggers your ECS service to pull and run the new image

**Note:**
- If you have destroyed your infrastructure with Terraform (using `terraform destroy`), running `./deploy-latest.sh` alone will NOT work, because the AWS resources no longer exist. You must recreate the infrastructure first by following Initial Infrastructure Setup or use `./destroy-and-redeploy.sh`.

**For infrastructure (Terraform) changes:**
- Edit your Terraform files as needed in the `terraform-ecs` directory.
- To apply changes, run:
   ```sh
   cd terraform-ecs
   terraform apply
   cd ..
   ```
- You can also use `./destroy-and-redeploy.sh` to destroy and fully recreate everything (see below).



## Destroying AWS Resources

To destroy all AWS resources created by this project, run:

```sh
cd terraform-ecs
terraform destroy
cd ..
```

This will remove all infrastructure (ECR, ECS, IAM roles, security groups, etc.) created by Terraform for this project. After this, `./deploy-latest.sh` will NOT work until you recreate the infrastructure.
 terraform apply
## Full Redeploy: Destroy and Re-Deploy Everything

To destroy and then fully redeploy your AWS infrastructure and Docker image, use the provided script from the project root:

```sh
./destroy-and-redeploy.sh
```

This will:
- Destroy all AWS resources (using Terraform)
- Recreate all infrastructure (applying the latest Terraform code)
- Build, tag, and push your Docker image
- Redeploy your app to ECS

**This ensures that any changes to your Terraform code are reflected in the new infrastructure.**

If you only want to apply new Terraform changes (without destroying), use:
```sh
cd terraform-ecs
   terraform apply
cd ..
```

If you only want to deploy new code (no infra changes), use:
```sh
./deploy-latest.sh
```

**Directory summary:**
- `terraform-ecs/` — contains all Terraform code. Run Terraform commands here.
- Project root (`./`) — run deployment and destroy scripts here.

## Notes
Ensure your AWS credentials are configured using `aws configure` before running Terraform or pushing to ECR.
The ECS service will automatically pull the latest image after the final `terraform apply`.




