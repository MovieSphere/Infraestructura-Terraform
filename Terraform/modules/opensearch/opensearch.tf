resource "aws_opensearch_domain" "moviesphere" {
  domain_name           = "moviesphere"
  engine_version        = "OpenSearch_2.11"
  cluster_config {
    instance_type = "t3.small.search"
    instance_count = 1
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }
  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "es:*",
      "Resource": "arn:aws:es:${var.region}:*:domain/moviesphere/*"
    }
  ]
}
POLICIES
}