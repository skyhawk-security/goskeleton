AWSTemplateFormatVersion: "2010-09-09"
Transform: AWS::Serverless-2016-10-31
Description: [[[ .ServiceName ]]] lambda
Resources:
  LambdaFunction:
    Type: AWS::Serverless::Function
    Properties:
      Handler: main
      FunctionName: [[[ .ServiceName ]]]
      Runtime: provided.al2023
      Architectures:
        - arm64
      CodeUri: ./
      MemorySize: 256
      Timeout: 10
  LambdaFunctionLogGroup:
    Type: AWS::Logs::LogGroup
    DependsOn: LambdaFunction
    Properties:
      RetentionInDays: 14
      LogGroupName:
        Fn::Join:
          - ''
          - - /aws/lambda/
            - Ref: LambdaFunction
  [[[ .ServiceName ]]]Resource:
    Type: AWS::ApiGateway::Resource
    Properties:
      RestApiId: !Sub '{{resolve:ssm:/microservices/apigateway/api_gateway_id:1}}'
      ParentId: !Sub '{{resolve:ssm:/microservices/apigateway/api_gateway_root_resource_id:1}}'
      PathPart: [[[ .ServiceName ]]]
  [[[ .ServiceName ]]]ProxyResource:
    Type: 'AWS::ApiGateway::Resource'
    Properties:
      RestApiId: !Sub '{{resolve:ssm:/microservices/apigateway/api_gateway_id:1}}'
      ParentId: !Ref [[[ .ServiceName ]]]Resource
      PathPart: '{proxy+}'
  [[[ .ServiceName ]]]AnyMethodResource:
    Type: AWS::ApiGateway::Method
    Properties:
      AuthorizationType: CUSTOM
      AuthorizerId: !Sub '{{resolve:ssm:/microservices/apigateway/authorizer_arn:1}}'
      ApiKeyRequired: false
      Integration:
        Credentials: !Sub '{{resolve:ssm:/microservices/apigateway/api_gateway_role_arn:1}}'
        Type: AWS_PROXY
        Uri:
          Fn::Join:
            - ''
            - - !Sub 'arn:${AWS::Partition}:apigateway:'
              - Ref: AWS::Region
              - ":lambda:path/2015-03-31/functions/"
              - Fn::GetAtt:
                  - LambdaFunction
                  - Arn
              - "/invocations"
        IntegrationHttpMethod: POST
      HttpMethod: ANY
      ResourceId: !Ref [[[ .ServiceName ]]]Resource
      RestApiId: !Sub '{{resolve:ssm:/microservices/apigateway/api_gateway_id:1}}'
  [[[ .ServiceName ]]]OptionsMethodResource:
    Type: AWS::ApiGateway::Method
    Properties:
      AuthorizationType: NONE
      Integration:
        IntegrationResponses:
          - StatusCode: 200
            ResponseParameters:
              method.response.header.Access-Control-Allow-Headers: "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
              method.response.header.Access-Control-Allow-Methods: "'OPTIONS,GET,PUT,POST,DELETE,PATCH,HEAD'"
              method.response.header.Access-Control-Allow-Origin: "'*'"
        Type: MOCK
        PassthroughBehavior: WHEN_NO_MATCH
        RequestTemplates:
          application/json: '{"statusCode": 200}'
        Uri: "http://example.com"
      MethodResponses:
        - StatusCode: 200
          ResponseParameters:
            method.response.header.Access-Control-Allow-Headers: true
            method.response.header.Access-Control-Allow-Methods: true
            method.response.header.Access-Control-Allow-Origin: true
      HttpMethod: OPTIONS
      ResourceId: !Ref [[[ .ServiceName ]]]Resource
      RestApiId: !Sub '{{resolve:ssm:/microservices/apigateway/api_gateway_id:1}}'
  [[[ .ServiceName ]]]OptionsMethodProxyResource:
    Type: AWS::ApiGateway::Method
    Properties:
      AuthorizationType: NONE
      Integration:
        IntegrationResponses:
          - StatusCode: 200
            ResponseParameters:
              method.response.header.Access-Control-Allow-Headers: "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
              method.response.header.Access-Control-Allow-Methods: "'OPTIONS,GET,PUT,POST,DELETE,PATCH,HEAD'"
              method.response.header.Access-Control-Allow-Origin: "'*'"
        Type: MOCK
        PassthroughBehavior: WHEN_NO_MATCH
        RequestTemplates:
          application/json: '{"statusCode": 200}'
        Uri: "http://example.com"
      MethodResponses:
        - StatusCode: 200
          ResponseParameters:
            method.response.header.Access-Control-Allow-Headers: true
            method.response.header.Access-Control-Allow-Methods: true
            method.response.header.Access-Control-Allow-Origin: true
      HttpMethod: OPTIONS
      ResourceId: !Ref [[[ .ServiceName ]]]ProxyResource
      RestApiId: !Sub '{{resolve:ssm:/microservices/apigateway/api_gateway_id:1}}'
  [[[ .ServiceName ]]]AnyProxyMethod:
    Type: AWS::ApiGateway::Method
    Properties:
      AuthorizationType: CUSTOM
      AuthorizerId: !Sub '{{resolve:ssm:/microservices/apigateway/authorizer_arn:1}}'
      Integration:
        Credentials: !Sub '{{resolve:ssm:/microservices/apigateway/api_gateway_role_arn:1}}'
        Type: AWS_PROXY
        Uri:
          Fn::Join:
            - ''
            - - !Sub 'arn:${AWS::Partition}:apigateway:'
              - Ref: AWS::Region
              - ":lambda:path/2015-03-31/functions/"
              - Fn::GetAtt:
                  - LambdaFunction
                  - Arn
              - "/invocations"
        IntegrationHttpMethod: POST
      HttpMethod: ANY
      ResourceId: !Ref [[[ .ServiceName ]]]ProxyResource
      RestApiId: !Sub '{{resolve:ssm:/microservices/apigateway/api_gateway_id:1}}'
