# set subscription
export ARM_SUBSCRIPTION_ID="abcc12e8-46f6-4fb0-ae1f-86a92dafdaa7"

# set app / env
export TF_VAR_application_name="devops"
export TF_VAR_environment_name="prod"
export TF_VAR_primary_region="northeurope"

# set backend
export BACKEND_RESOURCE_GROUP="rg-app-prod"
export BACKEND_STORAGE_ACCOUNT="stcglqzse0k9"
export BACKEND_CONTAINER_NAME="tfstate"
export BACKEND_KEY=$TF_VAR_application_name-$TF_VAR_environment_name

# run terraform
terraform init \
    -backend-config="resource_group_name=${BACKEND_RESOURCE_GROUP}" \
    -backend-config="storage_account_name=${BACKEND_STORAGE_ACCOUNT}" \
    -backend-config="container_name=${BACKEND_CONTAINER_NAME}" \
    -backend-config="key=${BACKEND_KEY}"

terraform $* 

rm -rf .terraform