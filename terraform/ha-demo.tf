
# AMI Amazon Linux 2023
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Application Load Balancer public
resource "aws_lb" "demo" {
  name               = "ha-demo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "ha-demo-alb"
  }
}

# Cible HTTP des instances applicatives
resource "aws_lb_target_group" "demo" {
  name     = "ha-demo-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ha-demo-tg"
  }
}

# Listener HTTP de l'ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.demo.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo.arn
  }
}

# Modèle des instances privées
resource "aws_launch_template" "demo" {
  name_prefix   = "ha-demo-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -eu

    mkdir -p /var/www/html
    cat > /var/www/html/index.html <<HTML
    <!doctype html>
    <html>
      <head><title>AWS HA Demo</title></head>
      <body>
        <h1>Application AWS HA</h1>
        <p>Infrastructure déployée avec Terraform.</p>
        <p>Serveur : $(hostname)</p>
      </body>
    </html>
    HTML

    PYTHON="$(command -v python3 || true)"
    if [ -z "$PYTHON" ]; then
      echo "Python3 absent de l'AMI" >&2
      exit 1
    fi

    cat > /etc/systemd/system/ha-demo.service <<SERVICE
    [Unit]
    Description=Serveur HTTP de démonstration HA
    After=network.target

    [Service]
    Type=simple
    ExecStart=$PYTHON -m http.server 80 --directory /var/www/html
    Restart=always
    RestartSec=3

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable --now ha-demo.service
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ha-demo-instance"
    }
  }

  tags = {
    Name = "ha-demo-launch-template"
  }
}

# Deux instances, réparties sur les deux sous-réseaux privés
resource "aws_autoscaling_group" "demo" {
  name                = "ha-demo-asg"
  min_size            = 2
  desired_capacity    = 2
  max_size            = 2
  vpc_zone_identifier = aws_subnet.private[*].id

  target_group_arns = [aws_lb_target_group.demo.arn]

  launch_template {
    id      = aws_launch_template.demo.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 180

  tag {
    key                 = "Name"
    value               = "ha-demo-instance"
    propagate_at_launch = true
  }

  depends_on = [aws_lb_listener.http]
}

output "demo_alb_dns_name" {
  description = "Adresse DNS du Load Balancer de démonstration"
  value       = aws_lb.demo.dns_name
}
