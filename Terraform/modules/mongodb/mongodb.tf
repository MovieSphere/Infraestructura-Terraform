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
}

resource "aws_docdb_cluster_instance" "this" {
  count              = var.instance_count
  identifier         = "${var.project_name}-docdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.instance_class
}