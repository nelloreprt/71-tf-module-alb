
resource "aws_lb" "alb" {
  name               = "${var.name}-${var.env}"
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  # security_groups    = [aws_security_group.lb_sg.id] >> not required for now
  subnets            = var.subnets  # subnet_id is required

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags,
    { Name = "${var.name}-${var.env}" })
}