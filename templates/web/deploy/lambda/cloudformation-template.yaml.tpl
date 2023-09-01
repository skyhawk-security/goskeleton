AWSTemplateFormatVersion: "2010-09-09"
Transform: AWS::Serverless-2016-10-31
Description: {{ .ServiceName }} lambda
Resources:
  LambdaFunction:
    Type: AWS::Serverless::Function
    Properties:
      Handler: main
      FunctionName: {{ .ServiceName }}
      Runtime: go1.x
      CodeUri: ./
      MemorySize: 256
      Timeout: 300
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