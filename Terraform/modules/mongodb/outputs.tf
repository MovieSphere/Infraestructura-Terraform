output "docdb_endpoint" {
  value = aws_docdb_cluster.this.endpoint
}

output "docdb_reader_endpoint" {
  value = aws_docdb_cluster.this.reader_endpoint
}