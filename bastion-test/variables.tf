variable "region" {
  description = "네이버 클라우드 리전"
  type        = string
  default     = "KR"
}

variable "access_key" {
  description = "네이버 클라우드 플랫폼 액세스 키"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "네이버 클라우드 플랫폼 시크릿 키"
  type        = string
  sensitive   = true
} 