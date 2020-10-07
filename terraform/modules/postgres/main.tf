##########################################################
# Postgres
##########################################################
resource "aws_db_subnet_group" "rds" {
  name        = "rds-app-${lower(var.stage)}"
  description = "RDS subnet group"
  subnet_ids  = var.private_db_subnet_ids
}

resource "aws_db_instance" "rds-app-prod" {
  allocated_storage           = 100
  allow_major_version_upgrade = true
  apply_immediately           = true
  engine                      = "postgres"
  engine_version              = "12"
  instance_class              = "db.t3.large"
  identifier                  = "app${lower(var.stage)}"
  name                        = "app${lower(var.stage)}"
  username                    = "app${lower(var.stage)}"
  password                    = var.db_password
  db_subnet_group_name        = aws_db_subnet_group.rds.name
  parameter_group_name        = "default.postgres12"
  multi_az                    = "false"
  vpc_security_group_ids      = var.security_group_ids
  skip_final_snapshot         = false
  final_snapshot_identifier   = "final-snaphot-appstaging-${uuid()}"
  snapshot_identifier         = "arn:aws:rds:eu-west-2:464702836434:snapshot:sbx1-old-version-snapshot-sbx2"
  storage_encrypted           = true
}
