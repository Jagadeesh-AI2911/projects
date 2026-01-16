#database subnet group
resource "aws_db_subnet_group" "main" {
    name        = "${var.environment}-db-subnet-group"
    subnet_ids  = var.private_subnet_ids
    description = "Database subnet group for ${var.environment}"
    tags = {
        Name = "${var.environment}-db-subnet-group"
        Environment = var.environment
    }
}

#database security group
resource "aws_security_group" "rds_sg" {
    name        = "${var.environment}-rds-sg"
    description = "Security group for RDS. allow MySQL traffic from internal vpc"
    vpc_id      = var.vpc_id
    ingress {
        description = "MySQL from internal vpc"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
        description = "Allow all outbound traffic"
    }
    tags = {
        Name = "${var.environment}-rds-sg"
        Environment = var.environment
    }
}

#RDS instance
resource "aws_db_instance" "mysql" {
    identifier              = "${var.environment}-mysqldb"
    engine                  = "mysql"
    engine_version          = "8.0"
    instance_class          = var.db_instance_class
    db_name                 = "myappdb"
    username                = "admin"
    password                = "var.db_password"
    allocated_storage       = 20
    max_allocated_storage   = 100
    storage_type            = "gp2"
    db_subnet_group_name    = aws_db_subnet_group.main.name
    vpc_security_group_ids  = [aws_security_group.rds_sg.id]
    publicly_accessible     = false
    multi_az                = var.environment == "prod" ? true : false
    deletion_protection     = var.environment == "prod" ? true : false
    skip_final_snapshot     = var.environment == "dev" ? true : false

    tags = {
        Name = "${var.environment}-mysqldb-instance"
        Environment = var.environment
    }
}