# Backend configuration for S3 remote state.

bucket         = "ntr-tfstate"
key            = "ntr/terraform.tfstate"
region         = "us-west-2"
profile        = "terraform"
use_lockfile   = true
encrypt        = true