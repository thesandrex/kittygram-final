variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Folder ID"
  type        = string
}

variable "access_key" {
  description = "Yandex Folder ID"
  type        = string
}

variable "secret_key" {
  description = "Yandex Folder ID"
  type        = string
}

variable "token" {
  description = "Yandex OAuth Token"
  type        = string
}

variable "vm_user" {
  description = "Username to create on VM"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}
