## Deploy a VPN between GCP and Azure

First you have to create the credential.tf
```
provider "azurerm" {
    subscription_id = "<subscription id>"
    tenant_id       = "<tenant id>"
}

provider "google" {
  project = "<project name>"
  region  = "<region>"
  zone    = "<region-zone>"
  credentials = "${file("account.json")}"
}
```
