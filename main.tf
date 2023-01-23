terraform {
  backend "local" {
    path = "./terraform.tfstate"

  }
}

provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      GithubTeam = "Team testing"
    }
  }
}

