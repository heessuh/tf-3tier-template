# Creating an ec2 instance in a public subnet
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = "subnet-0a1b2c3d4e5f6g7h"
  tags = {
    Name = "web"
  }
}

# Creating a dynamodb table
resource "aws_dynamodb_table" "users" {
  name           = "users"
  hash_key       = "id"
  billing_mode   = "PAY_PER_REQUEST"
  attribute {
    name = "id"
    type = "S"
  }
}

# Creating an apigateway integration with the ec2 instance
resource "aws_api_gateway_rest_api" "api" {
  name        = "api"
  description = "A simple API"
}

resource "aws_api_gateway_resource" "web" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "web"
}

resource "aws_api_gateway_method" "web_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.web.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "web_get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.web.id
  http_method = aws_api_gateway_method.web_get.http_method
  type        = "HTTP"
  integration_http_method = "GET"
  uri         = "http://${aws_instance.web.public_ip}"
}
