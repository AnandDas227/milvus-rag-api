terraform workspace select milvus_rag_api
terraform plan -var-file="milvus_rag_api.tfvars"
terraform apply -var-file="milvus_rag_api.tfvars" --auto-approve