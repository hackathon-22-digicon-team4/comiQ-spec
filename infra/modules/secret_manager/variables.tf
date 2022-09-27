variable "rds_credential" {
  default = {
    password = "tmp-password"
  }
  type = map(string)
}
variable "name" {
  type = string
}