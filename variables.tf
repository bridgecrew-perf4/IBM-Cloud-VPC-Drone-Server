variable "region" {
  type        = string
  description = "The region where the VPC resources will be deployed."
  default     = "us-south"
}

variable "ssh_key" {
  type        = string
  description = "The SSH Key that will be added to the compute instances in the region."
  default     = "hyperion-us-south"
}

variable "default_instance_profile" {
  type    = string
  default = "bx2-2x8"
}

variable "os_image" {
  type        = string
  description = "OS Image to use for VPC instances. Default is currently Ubuntu 18."
  default     = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

variable "resource_group" {
  type        = string
  description = "Resource group where resources will be deployed."
  default     = "CDE"
}

variable vpc_name {
  default = "us-south-cde-vpc"
}

variable subnet {
  default = "us-south-cde-subnet-zone1"
}

variable security_group {
  default = "dmz-us-south-cde-sg"
}

variable project {
  default = "dronev2"
}

variable tags {
  default = ["owner:ryantiffany"]
}

variable domain {
  default = "clouddesigndev.com"
}