if [ -f .env ]; then
  source .env
else
  echo ".env file not found."
  exit 1
fi

terraform init

terraform workspace new milvus_rag_api

terraform workspace select milvus_rag_api
terraform import -var-file="milvus_rag_api.tfvars" ibm_code_engine_app.code_engine_app_instance $ce_project_id/milvus-rag-api-tf


