resource "aws_api_gateway_rest_api" "apigw" {
  name = "tester"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "tracks" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  parent_id   = aws_api_gateway_rest_api.apigw.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "tracks_post" {
  rest_api_id      = aws_api_gateway_rest_api.apigw.id
  resource_id      = aws_api_gateway_resource.tracks.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "tracks_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.apigw.id
  resource_id             = aws_api_gateway_resource.tracks.id
  http_method             = aws_api_gateway_method.tracks_post.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "https://en.wikipedia.org/wiki/Lolcat"
}

resource "aws_api_gateway_deployment" "live" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  stage_name  = "live"

  #hack to force recreate of the deployment resource
  stage_description = md5(file("apigw.tf"))

  depends_on = [
    aws_api_gateway_method.tracks_post,
    aws_api_gateway_integration.tracks_post_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}
