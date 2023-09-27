package main

import (
	"embed"
	"fmt"
	"github.com/spf13/cobra"
	"os"
	"path/filepath"
	"strings"
)

const templatePath = "templates"

type EventSource string

const (
	SQSEventSource EventSource = "SQS"
	SNSEventSource EventSource = "SNS"
)

type Service struct {
	Name                string
	Type                string
	Destination         string
	OpenAPITemplatePath string
	EventSource         EventSource
	EventSourceARN      string
}

//go:embed templates/*
var templateFs embed.FS

func main() {
	service := Service{}

	rootCmd := &cobra.Command{
		Use:   "cli",
		Short: "A CLI application to create a Golang service skeleton",
		PersistentPreRun: func(cmd *cobra.Command, args []string) {
			err := validate(service.Name, filepath.Join(service.Destination, service.Name))
			if err != nil {
				fmt.Println("validation error: " + err.Error())
				os.Exit(1)
			}
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			return nil
		},
	}

	rootCmd.Parent()

	rootCmd.PersistentFlags().StringVarP(&service.Name, "serviceName", "n", "", "Name of the service")
	rootCmd.PersistentFlags().StringVarP(&service.Destination, "destination", "d", "", "Destination to write the skeleton to")

	rootCmd.MarkFlagRequired("serviceName")
	rootCmd.MarkFlagRequired("serviceType")
	rootCmd.MarkFlagRequired("destination")

	webCmd := &cobra.Command{
		Use:   "web-service command",
		Short: "Build a Web API service",
		RunE: func(cmd *cobra.Command, args []string) error {
			service.Type = "web"

			err := generateOpenAPITemplate(filepath.Join(filepath.Join(service.Destination, service.Name), "api"), service.OpenAPITemplatePath)
			if err != nil {
				return err
			}

			err = service.generateService(filepath.Join(service.Destination, service.Name))
			if err != nil {
				fmt.Println("failed to generate service with error: " + err.Error())
				os.Exit(1)
			}

			return nil
		},
	}

	eventDrivenCmd := &cobra.Command{
		Use:   "event-driven service command",
		Short: "Build an event driven service",
		RunE: func(cmd *cobra.Command, args []string) error {
			service.Type = "eventdriven"

			service.EventSource = EventSource(strings.ToUpper(string(service.EventSource)))

			// Check if the userInput is one of the allowed values
			switch service.EventSource {
			case SNSEventSource, SQSEventSource:
				fmt.Printf("Creating an %s consumer service\n", service.EventSource)
			default:
				return fmt.Errorf("invalid input. Please enter '%s' or '%s'", SNSEventSource, SQSEventSource)
			}

			err := service.generateService(filepath.Join(service.Destination, service.Name))
			if err != nil {
				fmt.Println("failed to generate service with error: " + err.Error())
				os.Exit(1)
			}

			return nil
		},
	}

	webCmd.Flags().StringVarP(&service.OpenAPITemplatePath, "openapi-template-path", "o", "", "Path to OpenAPI Template")

	eventDrivenCmd.Flags().StringVarP((*string)(&service.EventSource), "event-source", "e", "", "Event Source. SQS/SNS/etc")
	eventDrivenCmd.Flags().StringVarP(&service.EventSourceARN, "event-source-arn", "a", "", "Event Source ARN that triggers the lambda. for example, the ARN of the SQS queue URL")
	eventDrivenCmd.MarkFlagRequired("event-source")
	eventDrivenCmd.MarkFlagRequired("event-source-arn")

	rootCmd.AddCommand(webCmd)
	rootCmd.AddCommand(eventDrivenCmd)

	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
