data "aws_subnet" "this" {
  count = var.create ? 1 : 0
  id    = var.client_subnets[0]
}

resource "aws_security_group" "this" {
  count       = var.create ? 1 : 0
  name_prefix = "${var.cluster_name}-"
  vpc_id      = data.aws_subnet.this[0].vpc_id
}

resource "aws_security_group_rule" "msk-plain" {
  count             = var.create ? 1 : 0
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  security_group_id = aws_security_group.this[0].id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "msk-tls" {
  count             = var.create ? 1 : 0
  from_port         = 9094
  to_port           = 9094
  protocol          = "tcp"
  security_group_id = aws_security_group.this[0].id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "zookeeper-plain" {
  count             = var.create ? 1 : 0
  from_port         = 2181
  to_port           = 2181
  protocol          = "tcp"
  security_group_id = aws_security_group.this[0].id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "zookeeper-tls" {
  count             = var.create ? 1 : 0
  from_port         = 2182
  to_port           = 2182
  protocol          = "tcp"
  security_group_id = aws_security_group.this[0].id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "jmx-exporter" {
  count = var.create && var.open_monitoring_config.jmx_exporter_enabled_in_broker ? 1 : 0

  from_port         = 11001
  to_port           = 11001
  protocol          = "tcp"
  security_group_id = aws_security_group.this[0].id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "node_exporter" {
  count = var.create && var.open_monitoring_config.node_exporter_enabled_in_broker ? 1 : 0

  from_port         = 11002
  to_port           = 11002
  protocol          = "tcp"
  security_group_id = aws_security_group.this[0].id
  type              = "ingress"
  self              = true
}
