<a href="https://skyhawk.security/">
    <img src="https://avatars.githubusercontent.com/u/134402648?s=200&v=4" alt="Skyhawk Security logo" title="Skyhawk Security" align="right" height="60" />
</a>

<div align="center">
<img src="https://speedmedia.jfrog.com/08612fe1-9391-4cf3-ac1a-6dd49c36b276/https://media.jfrog.com/wp-content/uploads/2020/01/20125954/BLOG_GO_XRAY863X300.jpg/w_863" width="500", height="200">

</div>


# Go Skeleton


Go Skeleton is a project aimed at creating skeleton services for easier and quicker onboarding to both the projects and
the Golang language itself.
The projects that are generated are built with Clean Architecture and support both native (docker, ec2, etc) and lambda
deployments.


## Table Of Contents

- [Installation](#installation)
- [Features](#features)
- [Example](#example)



## Installation
```azure
go install
```

## Features
#### Clean Architecture generated code, structured and implemented
Focus on your business logic and avoid distractions

#### Have a full Golang experience
The directory structure, generated code and intensive use standard library and Golang's best practices provide a minimalistic, lean and Go-ish experience

#### Multi platform support
AWS Lambda and Native (Docker, EC2, etc) deployments are available out of the box.

#### OpenAPI 3.x code generation and validation
Write your OpenAPI spec and let us do the REST. Avoid writing boilerplate code but still have control over what's going on


## Example
#### For a web server Lambda
goskeleton web-service --serviceName mycoolservice --destination /Users/reshef.sharvit/Desktop

#### For an event driven Lambda
goskeleton event-driven --event-source SQS --event-source-arn arn:aws:sqs:us-east-1:123456789:resheftest-kabadi --serviceName mycoolservice --destination /Users/reshef.sharvit/Desktop/