provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "aws-ha-architecture"
      Environment = "lab"
      ManagedBy   = "Terraform"
    }
  }
}
