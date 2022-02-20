
module "networking" {
  source = "./modules/networking"

  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zone    = var.availability_zone
}

module "eks" {
  source = "./modules/eks"

  vpc_id_eks = module.networking.vpc_id
  subnet     = module.networking.private_subnets_ids

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  instance_type_group1        = var.instance_type_group1
  instance_type_group2        = var.instance_type_group2
  asg_desired_capacity_group1 = var.asg_desired_capacity_group1
  asg_desired_capacity_group2 = var.asg_desired_capacity_group2
}

# module "ec2" {
#   source = "./modules/ec2"

#   vpc_id_ec2                     = module.networking.vpc_id
#   subnet_id                      = module.networking.public_subnets_ids

#   number_of_instances            = var.number_of_instances
#   ec2_name                       = var.ec2_name
#   ec2_security_group_name        = var.ec2_security_group_name
#   ec2_security_group_description = var.ec2_security_group_description
#   ec2_ami                        = var.ec2_ami
#   ec2_instance_type              = var.ec2_instance_type
# }

module "rds" {
  source = "./modules/rds"

  vpc_id_rds  = module.networking.vpc_id
  subnets_rds = module.networking.private_subnets_ids

  allocated_storage   = var.allocated_storage
  db_engine           = var.db_engine
  db_port             = var.db_port
  engine_version      = var.engine_version
  instance_type       = var.instance_type
  database_name       = var.database_name
  db_username         = var.db_username
  publicly_accessible = var.publicly_accessible
}

module "s3" {
  source = "./modules/s3"

  vpc_id_s3 = module.networking.vpc_id
  # subnet_s3 = module.networking.private_subnets_ids

  bucket_prefix = var.bucket_prefix
  acl           = var.acl
  versioning    = var.versioning

  csv_user_purchase_path = var.csv_user_purchase_path
  csv_movie_review_path = var.csv_movie_review_path
  csv_log_reviews_path = var.csv_log_reviews_path
  glue_job_path = var.glue_job_path

}

module "glue" {
  source = "./modules/glue"

  gc_db_type = var.db_engine
  gc_db_endpoint = module.rds.rds_endpoint
  gc_db_name = module.rds.rds_database
  gc_db_password = module.rds.rds_password
  gc_db_username = module.rds.rds_username
  gc_subnet_az = module.networking.priv_subnet_az
  gc_secgroup_id = module.rds.rds_vpc_sg
  gc_subnet_id = module.networking.priv_subnet_id
  gj_bucket_id = module.s3.s3_bucket_id
  gj_job_id = module.s3.s3_glue_job_key
  gj_class = var.gj_class
}

