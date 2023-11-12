resource "aws_launch_configuration" "hsh_lc" {

  name_prefix     = "hsh-lc-"

  image_id        = "ami-0fc5d935ebf8bc3bc"

  instance_type   = "t2.micro"

  security_groups = [aws_security_group.hsh_sg.id]



  lifecycle {

    create_before_destroy = true

  }

}



resource "aws_autoscaling_group" "hsh_asg" {

  launch_configuration = aws_launch_configuration.hsh_lc.id

  vpc_zone_identifier  = [aws_subnet.hsh_public_subnet.id]

  max_size             = 3

  min_size             = 1

  desired_capacity     = 1



  tag {

    key                 = "Name"

    value               = "hsh-instance"

    propagate_at_launch = true

  }

}



resource "aws_autoscaling_policy" "hsh_target_tracking" {

  name                   = "hsh-cpu-target-tracking"

  autoscaling_group_name = aws_autoscaling_group.hsh_asg.name

  policy_type            = "TargetTrackingScaling"

  estimated_instance_warmup = 200



  target_tracking_configuration {

    predefined_metric_specification {

      predefined_metric_type = "ASGAverageCPUUtilization"

    }

    target_value = 30.0

  }

}


