variable "exoscale_key" {
  description = "Please insert your Exoscale key here: "
  default = ""
  type = string
}

variable "exoscale_secret" {
  description = "Please insert your Exoscale secret here: "
  default = ""
  type = string
}

variable "zone" {
  default = "at-vie-1"
}

variable "template" {
  default = "Linux Ubuntu 20.04 LTS 64-bit"
}
