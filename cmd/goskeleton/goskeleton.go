package main

import (
	"fmt"
	"github.com/spf13/cobra"
	"os"
	"os/exec"
	"path/filepath"
)

const templatePath = "templates"

// TODO install oapi-codegen
// TODO install oapi-codegen
// TODO install oapi-codegen
// TODO install oapi-codegen
// TODO install oapi-codegen
// TODO install oapi-codegen
// TODO install oapi-codegen

func main() {
	var serviceName string
	var serviceType string
	var destination string

	rootCmd := &cobra.Command{
		Use:   "cli",
		Short: "A CLI application to create a Golang service skeleton",
		RunE: func(cmd *cobra.Command, args []string) error {
			if serviceType != "web" && serviceType != "eventDriven" {
				return fmt.Errorf("serviceType should be either web or eventDriven")
			}

			finalDestination := filepath.Join(destination, serviceName)

			_, err := os.Stat(finalDestination)
			if !os.IsNotExist(err) {
				return fmt.Errorf("service %s already exists", serviceName)
			}

			myServiceTemplatePaths, err := findFilesWithSuffix(filepath.Join(templatePath, serviceType), ".tpl")
			if err != nil {
				fmt.Println("Error:", err)
				return err
			}

			for _, t := range myServiceTemplatePaths {
				if err := processTemplate(t, serviceName, serviceType, finalDestination); err != nil {
					fmt.Printf("error processing template: %v", err)
					return err
				}
				fmt.Printf("processing template %s\n", t)
			}

			if serviceType == "web" {
				err = generateOpenAPITemplate(filepath.Join(finalDestination, "api"))
			}

			command := exec.Command("go", "mod", "tidy")
			command.Dir = finalDestination
			_, err = command.CombinedOutput()
			if err != nil {
				fmt.Println("Error:", err)
				return err
			}

			return nil
		},
	}

	rootCmd.Flags().StringVarP(&serviceName, "serviceName", "n", "", "Name of the service")
	rootCmd.Flags().StringVarP(&serviceType, "serviceType", "a", "", "Type of the service. either web or event driven")
	rootCmd.Flags().StringVarP(&destination, "destination", "d", "", "Destination to write the skeleton to")

	rootCmd.MarkFlagRequired("serviceName")
	rootCmd.MarkFlagRequired("serviceType")
	rootCmd.MarkFlagRequired("destination")

	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
