variable "name" {
  default = "kube-cluster"
}

variable "ami" {
  default = "ami-fe5efb9e"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  default = "kube-keypair"
}
