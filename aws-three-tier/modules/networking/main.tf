resource "aws_vpc" "main" {
    cidr_block              = var.vpc_cidr
    enable_dns_support      = true
    enable_dns_hostnames    = true

    tags = {
        Name        = "${var.environment}-vpc"
        Environment = var.environment
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id  = aws_vpc.main.id

    tags    = {
        Name            = "${var.environment}-igw"
        Environment     = "${var.environment}"
    }
}


#public subnets for ALB
resource "aws_subnet" "public" {
    count                       = length(var.public_subnets_cidr)
    vpc_id                      = aws_vpc.main.id
    cidr_block                  = var.public_subnets_cidr[count.index]
    availability_zone           = var.availability_zones[count.index]
    map_public_ip_on_launch     = true # instances get default public IPs upon launching
    
    tags = {
        Name        = "${var.environment}-public-subnet-${count.index + 1}"
        Environment = "${var.environment}"
        Type        = "Public"
    }
}


# private subnets for ECS Tasks & RDS
resource "aws_subnet" "private" {
    count               = length(var.private_subnets_cidr)
    vpc_id              = aws_vpc.main.id
    cidr_block          = var.private_subnets_cidr[count.index]
    availability_zone   = var.availability_zones[count.index]

    tags    = {
        Name            = "${var.environment}-private-subnet-${count.index + 1}"
        Type            = "Private"
        Environment     = "${var.environment}"
    }
}

#NAT Gateway for private subnets to access internet
resource "aws_eip" "nat" {
    count       = var.environment == "prod" ? length(var.public_subnets_cidr) : 1
    domain      = "vpc"
    depends_on  = [aws_internet_gateway.igw]

    tags        = {
        Name        = "${var.environment}-nat-eip-${count.index + 1}"
        Environment = "${var.environment}"
    }
}

resource "aws_nat_gateway" "main" {
    #In DEV I'm assigning 1 to save money, & in PROD I'll assign 1 per AZ for HA
    count           = var.environment == "prod" ? length(var.public_subnets_cidr) : 1 
    allocation_id   = aws_eip.nat[count.index].id
    subnet_id       = aws_subnet.public[count.index].id
    depends_on      = [aws_internet_gateway.igw] 

    tags = {
        Name            = "${var.environment}-nat-gateway-${count.index + 1}"
        Environment     = "${var.environment}"
    }
}

#public routetable routes traffic to the igw
resource "aws_route_table" "public" {
    vpc_id      = aws_vpc.main.id
    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id  = aws_internet_gateway.igw.id
    }
    depends_on  = [aws_internet_gateway.igw]

    tags = {
        Name            = "${var.environment}-public-rt"
        Environment     = "${var.environment}"
    }
}

resource "aws_route_table_association" "public" {
    count           = length(var.public_subnets_cidr)
    subnet_id       = aws_subnet.public[count.index].id
    route_table_id  = aws_route_table.public.id
}

#private routetable routes traffic to the nat gateway
resource "aws_route_table" "private" {
    #I'm creating 1 RT for DEV & in PROD I'll create 1 per AZ for HA
    count       = var.environment == "prod" ? length(var.private_subnets_cidr) : 1
    vpc_id      = aws_vpc.main.id
    route {
        cidr_block  = "0.0.0.0/0"
        nat_gateway_id = var.environment == "prod" ? aws_nat_gateway.main[count.index].id : aws_nat_gateway.main[0].id
    }
    depends_on  = [aws_nat_gateway.main]

    tags = {
        Name            = "${var.environment}-private-rt-${count.index + 1}"
        Environment     = "${var.environment}"
    } 
}

resource "aws_route_table_association" "private" {
    count = length(var.private_subnets_cidr)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = var.environment == "prod" ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}