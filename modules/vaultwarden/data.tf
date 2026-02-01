# Declare the data source for AZ's
data "aws_availability_zones" "available" {
  state = "available"
}