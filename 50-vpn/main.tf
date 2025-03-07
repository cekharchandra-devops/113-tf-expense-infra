resource "aws_key_pair" "key_pair" {
  key_name = "openvpn"
  public_key = file("~/.ssh/openvpn.pub")
}
module "vpn" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.resource_name
  ami = data.aws_ami.openvpn.id

  instance_type          = "t3.micro"
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  subnet_id              = local.public_subnet_id

  tags = merge(
    var.common_tags,
    var.vpn_tags,
    {
        Name = local.resource_name
    }
  )
}