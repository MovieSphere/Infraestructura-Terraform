resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
  
  drop_invalid_header_fields = true
  
  enable_deletion_protection = true

  desync_mitigation_mode = "defensive"

  dynamic "access_logs" {
    for_each = var.enable_alb_access_logs && var.alb_logs_bucket != "" ? [1] : []
    content {
      bucket  = var.alb_logs_bucket
      prefix  = "${var.project_name}/alb"
      enabled = true
    }
  }

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_wafv2_web_acl_association" "alb_waf" {
  count        = var.alb_waf_arn != "" ? 1 : 0
  resource_arn = aws_lb.app_alb.arn
  web_acl_arn  = var.alb_waf_arn
}

resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = aws_lb.app_alb.arn
  web_acl_arn  = var.web_acl_arn
}

resource "aws_lb_target_group" "tg_auth" {
  name     = "${var.project_name}-tg-auth"
  port     = 8091
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTP"
    path     = "/health"
    interval = 30
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "tg_user" {
  name     = "${var.project_name}-tg-user"
  port     = 8092
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTP"
    path     = "/health"
    interval = 30
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.project_name}-tg"
  port     = 3000  # Puerto de la aplicación
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTP"
    path     = "/health"
    interval = 30
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

resource "aws_lb_target_group_attachment" "ec2_attachment" {
  count = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.instance_ids[count.index]
  port             = 80
}

resource "aws_lb_target_group_attachment" "auth_attachment" {
  count = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.tg_auth.arn
  target_id        = var.instance_ids[count.index]
  port             = 8091
}

resource "aws_lb_target_group_attachment" "user_attachment" {
  count = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.tg_user.arn
  target_id        = var.instance_ids[count.index]
  port             = 8092
}


resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "https_listener" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}