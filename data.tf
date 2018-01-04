# data "aws_kms_secret" "ad_admin_password" {
#   secret {
#     name    = "ad_admin_password"
#     payload = "AQICAHhvgBGgfqKOs77uuefIlKz+1Juy68zw0CvFLI73Aw935AGCQHfjnKRKdyogyrrdYCbBAAAAbjBsBgkqhkiG9w0BBwagXzBdAgEAMFgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM9NT3Q+ksNdre4LkZAgEQgCsBnaFznq7diq2Kx4azj2mliuCxA5s10zPh4LXqpBFSZr52ChM4Tgg6RLVq"
#
#     context {
#       terraform = "active_directory"
#     }
#   }
# }
#
# data "aws_kms_secret" "ad_joiner_password" {
#   secret {
#     name    = "ad_joiner_password"
#     payload = "AQICAHgWjLd9KCkAMoIiCrlHxvDoU7a2O9qUTzlOgMxGQGUmigFuxbWy63GMuCQpbhwRQcbfAAAAbjBsBgkqhkiG9w0BBwagXzBdAgEAMFgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMa9Z+hs562+Tfp2woAgEQgCs0+/QWJDbOILu6OxR6DJcSe3YuGbg5QFPFVXmyDOsIR8UYxhijuFfWmnGV"
#
#     context {
#       terraform = "active_directory"
#     }
#   }
# }
