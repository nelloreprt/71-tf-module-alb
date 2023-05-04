
resource "aws_lb" "alb" {
  name               = "${var.name}-${var.env}"
  internal           = var.internal
  load_balancer_type = var.load_balancer_type

  # security_groups    = [aws_security_group.lb_sg.id] >> not required for now

  subnets            = var.subnets  # subnet_id is required

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags,
    { Name = "${var.name}-${var.env}" })

  security_groups = [aws_security_group.main.id]
}

resource "aws_security_group" "main" {
  name        = "${var.name}-${var.env}-lb"
  description = "${var.name}-${var.env}-lb"
  vpc_id      = var.vpc_id    # vpc_id is coming from tf-module-vpc >> output_block

  # We need to open the Application port & we also need too tell to whom that port is opened
  # (i.e who is allowed to use that application port)
  # I.e shat port to open & to whom to open
  # Example for CTALOGUE we will open port 8080 ONLY WITHIN the APP_SUBNET
  # So that the following components (i.e to USER / CART / SHIPPING / PAYMENT) can use CATALOGUE.
  # And frontend also is necessarily need not be accessing the catalogue, i.e not to FRONTEND, because frontend belongs to web_subnet
  ingress {
    description      = "APP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr  # we want cidr number not subnet_id
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(var.tags,
    { Name = "${var.component}-${var.env}-lb" })
}

# creating LISTNER with Fixed_Response
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"   # for message body in html_format
      message_body = "<h1>503 - Invalid</h1>"
      status_code  = "503"
    }
  }
}