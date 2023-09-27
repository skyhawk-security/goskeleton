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
      Events:
        My{{ .EventSource }}Event:
          Type: {{ .EventSource }}
          Properties:
          {{- if ("SQS" | eq .EventSource) }}
            Queue: {{ .EventSourceARN }}
            BatchSize: 10
          {{- end }}
          {{- if ("SNS" | eq .EventSource) }}
            Topic: {{ .EventSourceARN }}
          {{- end}}
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
  LambdaArnParameter:
    Type: "AWS::SSM::Parameter"
    Properties:
      Name: /aws/lambda/{{ .ServiceName }}/arn
      Type: "String"
      Value:
        Fn::Join:
          - ''
          - - 'arn:aws:apigateway:'
            - Ref: AWS::Region
            - ":lambda:path/2015-03-31/functions/"
            - Fn::GetAtt:
                - LambdaFunction
                - Arn
            - "/invocations"
