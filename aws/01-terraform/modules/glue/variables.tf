variable "gc_db_type" {
    description = "rds db type (engine)"
}
variable "gc_db_endpoint" {
    description = "rds endpoint"
}
variable "gc_db_name" {
    description = "rds db name"
}
variable "gc_db_password" {
    description = "rds instance password"
}
variable "gc_db_username" {
    description = "rds instance username"
}
variable "gc_subnet_az" {
    description = "gc_subnet_id's availability zone"
}
variable "gc_secgroup_id" {
    description = "security group asociated to rds traffic"
}
variable "gc_subnet_id" {
    description = "vpc subnet where rds instance is"
}
variable "gj_bucket_id" {
    description = "s3 bucket that houses scala script"
}
variable "gj_job_id" {
    description = "s3 bucket object key belonging to scala script"
}
variable "gj_class" {
    description = "External - main scala class that houses job main function"
}
