resource "aws_memorydb_subnet_group" "this" {
  name       = "${var.project_name}-memorydb-subnets"
  subnet_ids = var.subnet_ids
}

resource "aws_memorydb_cluster" "this" {
  name                    = "${var.project_name}-recommendations"
  node_type               = var.node_type
  num_shards              = 1
  num_replicas_per_shard  = 1
  subnet_group_name       = aws_memorydb_subnet_group.this.name
  security_group_ids      = [var.security_group_id]
  acl_name                = var.acl_name  # ACL requerida obligatoriamente
}
