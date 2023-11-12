resource "aws_launch_configuration" "hsh_lc" {

  name_prefix   = "hsh-lc-"

  image_id      = "ami-0fc5d935ebf8bc3bc"

  instance_type = "t2.micro"



  lifecycle {

    create_before_destroy = true

  }

}



resource "aws_autoscaling_group" "hsh_asg" {

  launch_configuration    = aws_launch_configuration.hsh_lc.id

  vpc_zone_identifier     = [aws_subnet.hsh_public_subnet.id]

  max_size                = 3

  min_size                = 1

  desired_capacity        = 1



  tag {

    key                 = "Name"

    value               = "hsh-instance"

    propagate_at_launch = true

  }

}

resource "aws_autoscaling_policy" "hsh_as_policy" {

  name                   = "hsh-cpu-scale"

  scaling_adjustment     = 1

  adjustment_type        = "ChangeInCapacity"

  cooldown               = 300

  autoscaling_group_name = aws_autoscaling_group.hsh_asg.name



  policy_type = "SimpleScaling"

}



resource "aws_cloudwatch_metric_alarm" "hsh_high_cpu" {

  alarm_name          = "hsh_high_cpu_alarm"

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods  = 1

  metric_name         = "CPUUtilization"

  namespace           = "AWS/EC2"

  period              = 60

  statistic           = "Average"

  threshold           = 30.0

  alarm_description   = "This alarm monitors EC2 CPU utilization"

  actions_enabled     = true

  alarm_actions       = [aws_autoscaling_policy.hsh_as_policy.arn]

  dimensions = {

    AutoScalingGroupName = aws_autoscaling_group.hsh_asg.name

  }

}




