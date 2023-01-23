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

resource "aws_api_gateway_resource" "tracks_2" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  parent_id   = aws_api_gateway_rest_api.apigw.root_resource_id
  path_part   = "/"
}

resource "aws_api_gateway_method" "tracks_2_post" {
  rest_api_id      = aws_api_gateway_rest_api.apigw.id
  resource_id      = aws_api_gateway_resource.tracks_2.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "tracks_2_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.apigw.id
  resource_id             = aws_api_gateway_resource.tracks_2.id
  http_method             = aws_api_gateway_method.tracks_2_post.http_method
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
    aws_api_gateway_integration.tracks_post_integration,
    aws_api_gateway_method.tracks_2_post,
    aws_api_gateway_integration.tracks_2_post_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_api_key" "api_keys" {
  name  = "fake-mapps"
}

resource "aws_api_gateway_usage_plan" "default" {
  name = "hmpps-integration-api"

  api_stages {
    api_id = aws_api_gateway_rest_api.apigw.id
    stage  = aws_api_gateway_deployment.live.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {

  key_id        = aws_api_gateway_api_key.api_keys.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}