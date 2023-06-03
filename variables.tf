
variable "cloud_id" {
    type = string
    default = "b1gp2hsa65msuhi4n685"
}
variable "folder_id" {
  type = string
  default = "b1g5qe24o1sfk312vhrb"
}
variable "zone" {
  type = string
  default = "ru-central1-a"
}
variable "os-image-id" {
  description = "container-optimized-image id is fd80o2eikcn22b229tsa"
  type = string
  default = "data.yandex_compute_image.container-optimized-image.id"
}
data "yandex_compute_image" "container-optimized-image" {
    family = "container-optimized-image"
  }
