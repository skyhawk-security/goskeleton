AWSTemplateFormatVersion: "2010-09-09"
Transform: AWS::Serverless-2016-10-31
Description: [[[ .ServiceName ]]] fargate
Parameters:
  Name:
    Type: String
    Default: [[[ .ServiceName ]]]
  Environment:
    Type: AWS::SSM::Parameter::Value<String>
    Default: "env"
  ImageURL:
    Type: String
Resources:
  MyECRRepository:
    Type: 'AWS::ECR::Repository'
    Properties:
      RepositoryName: !Sub "${Name}"
      ImageTagMutability: MUTABLE
  [[[ .ServiceName ]]]ECSCluster:
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: !Sub "${Name}"
  [[[ .ServiceName ]]]TaskExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Sid: ""
            Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
  ECSTaskExecutionRolePolicy:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: [[[ .ServiceName ]]]TaskExecutionRolePolicy
      Roles:
        - !Ref [[[ .ServiceName ]]]TaskExecutionRole
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Sid: VisualEditor0
            Effect: Allow
            Action:
              - logs:CreateLogGroup
            Resource: !Sub "arn:aws:logs:${AWS::Region}:${AWS::AccountId}:log-group:/microservices/ecs/*"
  [[[ .ServiceName ]]]TaskRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub "${Name}-ecs-role"
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Sid: ""
            Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole
  ECSRolePolicy:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: [[[ .ServiceName ]]]TaskRolePolicy
      Roles:
        - !Ref [[[ .ServiceName ]]]TaskRole
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Sid: VisualEditor0
            Effect: Allow
            Action:
              - sts:AssumeRole
            Resource: "*"
  [[[ .ServiceName ]]]TaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: !Sub "${Name}"
      TaskRoleArn: !Ref [[[ .ServiceName ]]]TaskRole
      ExecutionRoleArn: !Ref [[[ .ServiceName ]]]TaskExecutionRole
      NetworkMode: awsvpc
      Cpu: '512'
      Memory: '1024'
      RuntimePlatform:
        CpuArchitecture: ARM64
        OperatingSystemFamily: LINUX
      RequiresCompatibilities:
        - FARGATE
      ContainerDefinitions:
        - Name: !Sub "${Name}"
          Image: !Ref ImageURL
          Cpu: 0
          Essential: true
          Command:
            - "python3"
            - "app.py"
          Environment:
            - Name: AWS_REGION
              Value: !Sub "${AWS::Region}"
          LogConfiguration:
            LogDriver: "awslogs"
            Options:
              awslogs-create-group: "true"
              awslogs-group: "/microservices/ecs/[[[ .ServiceName ]]]"
              awslogs-region: !Sub ${AWS::Region}
              awslogs-stream-prefix: "ecs"
  FargateContainerErrorEventRule:
    Type: AWS::Events::Rule
    Properties:
      Name: "[[[ .ServiceName ]]]-fargate-container-error"
      Description: "Container stopped with a non-zero exit code"
      EventPattern:
        source:
          - "aws.ecs"
        detail-type:
          - "ECS Task State Change"
        detail:
          lastStatus:
            - "STOPPED"
          clusterArn:
            - !GetAtt [[[ .ServiceName ]]]ECSCluster.Arn
          stoppedReason:
            - "Essential container in task exited"
          containers:
            exitCode:
              - "anything-but": 0
  [[[ .ServiceName ]]]Errors:
    Type: 'AWS::CloudWatch::Alarm'
    Properties:
      AlarmName: "[[[ .ServiceName ]]] errors (failed scans)"
      EvaluationPeriods: 1
      Threshold: 50
      ComparisonOperator: 'GreaterThanOrEqualToThreshold'
      TreatMissingData: 'notBreaching'
      Metrics:
        - Id: "errors"
          MetricStat:
            Metric:
              Namespace: "AWS/Events"
              MetricName: "MatchedEvents"
              Dimensions:
                - Name: "RuleName"
                  Value: !Ref FargateContainerErrorEventRule
            Period: 3600
            Stat: "Sum"
          ReturnData: true
      ActionsEnabled: true
      AlarmActions:
        - !Sub "arn:${AWS::Partition}:sns:${AWS::Region}:${AWS::AccountId}:OpsGenie_P1"
      OKActions:
        - !Sub "arn:${AWS::Partition}:sns:${AWS::Region}:${AWS::AccountId}:OpsGenie_P1"
  [[[ .ServiceName ]]]ErrorRate:
    Type: 'AWS::CloudWatch::Alarm'
    Properties:
      AlarmName: "[[[ .ServiceName ]]] scans error rate"
      EvaluationPeriods: 1
      Threshold: 20
      ComparisonOperator: 'GreaterThanOrEqualToThreshold'
      TreatMissingData: 'notBreaching'
      Metrics:
        - Id: "e1"
          Expression: "errors / requests * 100"
          Label: "Error Percentage"
          ReturnData: true
        - Id: "errors"
          MetricStat:
            Metric:
              Namespace: "AWS/Events"
              MetricName: "MatchedEvents"
              Dimensions:
                - Name: "RuleName"
                  Value: !Ref FargateContainerErrorEventRule
            Period: 3600
            Stat: "Sum"
          ReturnData: false
        - Id: "requests"
          MetricStat:
            Metric:
              Namespace: "AWS/Lambda"
              MetricName: "Invocations"
              Dimensions:
                - Name: "FunctionName"
                  Value: scanscheduler
            Period: 3600
            Stat: "Sum"
          ReturnData: false
      ActionsEnabled: true
      AlarmActions:
        - !Sub "arn:${AWS::Partition}:sns:${AWS::Region}:${AWS::AccountId}:OpsGenie_P1"
      OKActions:
        - !Sub "arn:${AWS::Partition}:sns:${AWS::Region}:${AWS::AccountId}:OpsGenie_P1"