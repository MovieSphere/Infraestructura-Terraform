resource "aws_docdb_subnet_group" "this" {
  name       = "${var.project_name}-docdb-subnets"
  subnet_ids = var.subnet_ids
}

resource "aws_docdb_cluster" "this" {
  cluster_identifier     = "${var.project_name}-docdb-cluster"
  engine                 = "docdb"
  master_username        = var.master_username
  master_password        = var.master_password
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = aws_docdb_subnet_group.this.name
  apply_immediately      = true
  
  storage_encrypted       = true                   # CKV_AWS_74: cifrado en descanso
  kms_key_id              = var.docdb_kms_key_id   # CKV_AWS_182: usar CMK de cliente
  backup_retention_period = var.backup_retention_period  # CKV_AWS_360: retención adecuada
}

resource "aws_docdb_cluster_instance" "this" {
  count              = var.instance_count
  identifier         = "${var.project_name}-docdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.instance_class
}
