variable "prefix" {
  description = "Naamgeving voor de verschillende resources die aangemaakt worden"
  default = "lxstorage"
}

variable "location" {
  description = "Welke Azure region moet er gebruikt worden"
  default = "westeurope"
}

variable "omgeving" {
  description = "Soort omgeving zoals test,dev of productie"
  default = "linuxstorage"
}

variable "gebruikersnaam" {
  description = "Soort omgeving zoals test,dev of productie"
  default = "daantoes"
}

variable "wachtwoord" {
  description = "Soort omgeving zoals test,dev of productie"
  default = "Welkom01!"
}