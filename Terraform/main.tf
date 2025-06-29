terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend para guardar el estado en S3
  backend "s3" {
    bucket = "tu-bucket-de-estados-terraform" # Cambiar por tu bucket real
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# Importar los 3 módulos
module "catalog_search" {
  source      = "./modules/ms_catalog_search_service"
  environment = "prod"
}

module "recomendation" {
  source      = "./modules/ms_recomendation_service"
  environment = "prod"
}

module "rating" {
  source      = "./modules/ms_rating_service"
  environment = "prod"
}
