resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
  drop_invalid_header_fields   = true
  enable_deletion_protection   = true  

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Listener HTTPS
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Listener HTTP que redirige a HTTPS
resource "aws_lb_listener" "http_redirect" {
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

# Reglas para HTTPS - CKV_AWS_103
resource "aws_lb_listener_rule" "auth_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_auth.arn
  }

  condition {
    path_pattern {
      values = ["/auth/*"]
    }
  }
}

resource "aws_lb_listener_rule" "user_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_user.arn
  }

  condition {
    path_pattern {
      values = ["/user/*"]
    }
  }
}

# Target groups
resource "aws_lb_target_group" "tg_auth" {
  name     = "${var.project_name}-tg-auth"
  port     = 8091
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "HTTPS"
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "tg_user" {
  name     = "${var.project_name}-tg-user"
  port     = 8092
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "HTTPS"
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "HTTPS"
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# Target group attachments
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
