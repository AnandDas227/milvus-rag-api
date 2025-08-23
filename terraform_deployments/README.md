
# Terraform Deployments

We use Terraform to manage our frontend and backend deployments on Code Engine. Each app uses the same main.tf and variables.tf file, and is configured strictly through the corresponding tfvars file. To run the terraform:

1. Create a tfvars for the application you're deploying (reference `sample_tfvars.txt`)
2. Run the `setup_terraform.sh` script to initialize Terraform and import the apps from Code Engine
   1. Requires a .env file in this directory with a "ce_project_id"
   2. If this is your first time deploying the app, the terraform will not be able to import the non-existent app.
3. Run a deploy script to deploy the corresponding application
   1. If this is your first time deploying the app, run the `setup_terraform.sh` script one more time to import the app into your terraform workspace.
4. To update the application, simply run the deploy script again.

**Note**: The Terraform currently expects the Code Engine Project, Registry Secret, SSH Secret, and Container Namespace to exist.
