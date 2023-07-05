# Define provider
provider "aws" {
  region = "us-east-2"  # Specify your desired AWS region
}

# Create a VPC security group
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "Security group for MySQL database"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a subnet group for RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "my-db-subnet-group"
  description = "DB subnet group for RDS"

  subnet_ids = ["subnet-0a00651e5d569bdf8", "subnet-0327c84b4858fa0ac"]  # Replace with the appropriate subnet IDs in your VPC
}

# Create an RDS instance for MySQL
resource "aws_db_instance" "mysql_instance" {
  identifier              = "mysql-db"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  publicly_accessible     = true
  vpc_security_group_ids  = [aws_security_group.mysql_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  username                = "akki"
  password                = "MySecurePassword123"  # Replace with your desired password

  # Set the desired backup retention period
  backup_retention_period = 7

  # Set the availability zone
  availability_zone = "us-east-2b"  # Specify your desired availability zone

  # Set the database parameter group
  parameter_group_name  = "default.mysql5.7"  # Specify your existing DB parameter group name

  # Set the maintenance window
  maintenance_window = "Mon:00:00-Mon:03:00"

  # Set the backup window
  backup_window = "03:00-06:00"
}

# Output the RDS instance endpoint
output "rds_endpoint" {
  value = aws_db_instance.mysql_instance.endpoint
}
