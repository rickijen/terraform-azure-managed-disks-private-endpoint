# Deploying Azure Managed OS and Data Disks with Private Endpoint using Terraform
[![Terraform](https://img.shields.io/badge/terraform-v1.3+-blue.svg)](https://www.terraform.io/downloads.html)

Blog --> https://gmusumeci.medium.com/using-private-endpoint-in-azure-manage-disks-with-terraform-9f0a443506e9

Deploy an Ubuntu Virtual Machine with Azure Managed Disk with Private Endpoint in Azure using Terraform

This code will:

- Resource Group Creation
- VNET Creation
- Subnets Creation
- Create a Linux VM
- Create a Private DNS zone
- Create Virtual Network Links
- Creation of the Disk Access Resource
- Creation of Manage OS and Data Disks and Attach to the VM
- Creation of the Managed Disk Endpoint
- Creation of DNS A Record
- Configure the network access to the Azure Managed Disk
