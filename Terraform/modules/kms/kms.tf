resource "aws_kms_key" "this" {
  description             = "KMS key for Moviesphere encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

  tags = {
    Name        = "${var.project_name}-os-domain"
    Environment = var.environment
  }
}
