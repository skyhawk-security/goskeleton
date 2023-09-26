package main

import (
	"embed"
	"fmt"
	"github.com/spf13/cobra"
	"os"
	"path/filepath"
)

const templatePath = "templates"

//go:embed templates/*
var templateFs embed.FS

func main() {
	var serviceName string
	var serviceType string
	var destination string

	var openapiTemplatePath string
	var eventSource string

	rootCmd := &cobra.Command{
		Use:   "cli",
		Short: "A CLI application to create a Golang service skeleton",
		PersistentPreRun: func(cmd *cobra.Command, args []string) {
			err := validate(serviceName, filepath.Join(destination, serviceName))
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

	rootCmd.PersistentFlags().StringVarP(&serviceName, "serviceName", "n", "", "Name of the service")
	rootCmd.PersistentFlags().StringVarP(&destination, "destination", "d", "", "Destination to write the skeleton to")

	rootCmd.MarkFlagRequired("serviceName")
	rootCmd.MarkFlagRequired("serviceType")
	rootCmd.MarkFlagRequired("destination")

	webCmd := &cobra.Command{
		Use:   "web-service command",
		Short: "Build a Web API service",
		RunE: func(cmd *cobra.Command, args []string) error {
			serviceType = "web"

			err := generateOpenAPITemplate(filepath.Join(filepath.Join(destination, serviceName), "api"), openapiTemplatePath)
			if err != nil {
				return err
			}

			err = generateService(serviceName, serviceType, filepath.Join(destination, serviceName))
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
			serviceType = "eventDriven"
			err := generateService(serviceName, serviceType, filepath.Join(destination, serviceName))
			if err != nil {
				fmt.Println("failed to generate service with error: " + err.Error())
				os.Exit(1)
			}

			return nil
		},
	}

	webCmd.Flags().StringVarP(&openapiTemplatePath, "openapi-template-path", "o", "", "Path to OpenAPI Template")

	eventDrivenCmd.Flags().StringVarP(&eventSource, "event-source", "e", "", "Event Source. SQS/SNS/etc")
	eventDrivenCmd.MarkFlagRequired("event-source")

	rootCmd.AddCommand(webCmd)
	rootCmd.AddCommand(eventDrivenCmd)

	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
