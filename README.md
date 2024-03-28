[![goskeleton](.github/resources/goskeleton_logo.png)](#)

[![Maintained by Skyhawk Security](https://img.shields.io/badge/maintained_by-Skyhawk_Security-6C00DB?style=for-the-badge)](https://skyhawk.security)
[![Maintenance](https://img.shields.io/maintenance/yes/2024?style=for-the-badge)](https://github.com/skyhawk-security/goskeleton/pulse)
[![Contributor covenant](https://img.shields.io/badge/Contributor_Covenant-v2.1-blue?style=for-the-badge&logo=contributorcovenant&color=%235E0D73)](CODE_OF_CONDUCT.md)

[![GitHub go.mod Go version](https://img.shields.io/github/go-mod/go-version/skyhawk-security/goskeleton?style=for-the-badge)](https://github.com/skyhawk-security/goskeleton)
[![Go Report Card](https://goreportcard.com/badge/github.com/skyhawk-security/goskeleton?style=for-the-badge)](https://goreportcard.com/report/github.com/skyhawk-security/goskeleton)
[![Go Doc](https://img.shields.io/badge/doc-reference-blue?style=for-the-badge&logo=go)](https://pkg.go.dev/github.com/skyhawk-security/goskeleton)

[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/skyhawk-security/goskeleton/pull_request_build.yaml?style=for-the-badge)](https://github.com/skyhawk-security/goskeleton/actions/workflows/pull_request_build.yaml)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/skyhawk-security/goskeleton?style=for-the-badge)](https://github.com/skyhawk-security/goskeleton/graphs/commit-activity)

# GoSkeleton
- [Installation](#installation)
- [Key Features](#key-features)
- [Usage Examples](#usage-examples)
- [Discussion](#discussion)
- [Contributing](#contributing-to-the-project)
- [License](#license)

GoSkeleton is a project aimed at creating skeleton services for easier and quicker onboarding to both the projects and
the Golang language itself.
The projects that are generated are built with Clean Architecture and support both native (docker, ec2, etc.) and lambda
deployments.

This project adheres to the Contributor Covenant [code of conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report unacceptable behavior to [goskeleton@skyhawk.security](mailto:goskeleton@skyhawk.security).

## Installation
```zsh
# clone && cd into the repository
go install
```

## Key Features
- **Clean Architecture generated code, structured and implemented**: Focus on your business logic and avoid distractions.

- **Have a full Golang experience**: The directory structure, generated code and intensive use standard library and Golang's best practices provide a minimalistic, lean and Go-ish experience.

- **Multi-platform support**: AWS Lambda and Native (Docker, EC2, etc) deployments are available out of the box.

- **OpenAPI 3.x code generation and validation**: Write your OpenAPI spec and let us do the REST. Avoid writing boilerplate code but still have control over what's going on.

## Usage Examples
#### For a web server Lambda
```zsh
goskeleton web-service --serviceName mycoolwebservice --destination $HOME/Desktop
```

#### For an event driven Lambda
```zsh
goskeleton event-driven --event-source SQS --event-source-arn arn:aws:sqs:us-east-1:123456789012:example-sqs-queue-name --serviceName mycooledsservice --destination $HOME/Desktop
```

## Discussion
Have a question? Post it in **goskeleton** [GitHub Discussions](https://github.com/skyhawk-security/goskeleton/discussions)

## Contributing to the project
Want to contribute? Please read the [Contribution Guide](CONTRIBUTING.md)

## License
[GPL-3.0](https://github.com/skyhawk-security/goskeleton/blob/main/LICENSE.md)
