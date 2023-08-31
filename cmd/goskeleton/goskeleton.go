package main

import (
	"fmt"
	"github.com/spf13/cobra"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"text/template"
)

// TODO join the common templates to avoid duplication
var templatePaths = map[string][]string{
	"web": {"api/openapi.yaml.tpl",
		"domain/aggregate/aggregate.go.tpl", "domain/entity/entity.go.tpl", "domain/valueobject/valueobject.go.tpl", "deploy/lambda/build_and_deploy.sh.tpl",

		"deploy/lambda/cloudformation-template.yaml.tpl", "api/chi/handler/handler.go.tpl",
		"cmd/lambda/main.go.tpl", "cmd/native/main.go.tpl", "domain/entity/entity.go.tpl",
		"repository/repository.go.tpl", "usecase/someusecase/someusecase.go.tpl",
		"usecase/someusecase/someusecase_test.go.tpl", "usecase/someusecase/types.go.tpl", "go.mod.tpl"},
	"eventDriven": {"domain/aggregate/aggregate.go.tpl", "domain/entity/entity.go.tpl", "domain/valueobject/valueobject.go.tpl",
		"deploy/lambda/build_and_deploy.sh.tpl", "deploy/lambda/cloudformation-template.yaml.tpl",
		"cmd/lambda/main.go.tpl", "cmd/native/main.go.tpl", "repository/repository.go.tpl", "usecase/myusecase/myusecase.go.tpl",
		"usecase/myusecase/types.go.tpl", "go.mod.tpl"},
}

// TODO install oapi-codegen and chi
// TODO install oapi-codegen and chi
// TODO install oapi-codegen and chi
// TODO install oapi-codegen and chi
// TODO install oapi-codegen and chi
// TODO install oapi-codegen and chi
// TODO install oapi-codegen and chi

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

			myServiceTemplatePaths, ok := templatePaths[serviceType]
			if !ok {
				fmt.Println("error processing template: no template pathsr")
				return fmt.Errorf("no template paths for %s", serviceType)
			}

			for _, t := range myServiceTemplatePaths {
				if err := processTemplate(t, serviceType, serviceName, finalDestination); err != nil {
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

func processTemplate(templatePath, serviceType, serviceName, finalDestination string) error {
	serviceTypeAndNamePath := fmt.Sprintf("%s/%s", serviceType, templatePath)

	if !strings.HasSuffix(serviceTypeAndNamePath, ".tpl") {
		return fmt.Errorf("%s is not a template", serviceTypeAndNamePath)
	}

	templateContent, err := ioutil.ReadFile(serviceTypeAndNamePath)
	if err != nil {
		return err
	}

	data := struct {
		ServiceName      string
		ServiceNameUpper string
	}{
		ServiceName:      serviceName,
		ServiceNameUpper: strings.Title(serviceName),
	}

	writePath := fmt.Sprintf("%s/%s", finalDestination, strings.Replace(templatePath, ".tpl", "", -1))

	err = os.MkdirAll(filepath.Dir(writePath), os.ModePerm)
	if err != nil {
		fmt.Println("Error creating directories:", err)
		return err
	}

	outputFile, err := os.Create(writePath)
	if err != nil {
		fmt.Println("Error creating file:", err)
		return err
	}
	defer outputFile.Close()

	// Create a new template
	tmpl := template.Must(template.New("my-template").Parse(string(templateContent)))

	// Execute the template and write to the output file
	err = tmpl.Execute(outputFile, data)
	if err != nil {
		fmt.Println("Error executing template:", err)
		return err
	}

	return nil
}

func generateOpenAPITemplate(outputPath string) error {
	specFile := "web/api/openapi.yaml.tpl"
	outputFile := fmt.Sprintf("%s/server.go", outputPath)

	// Run oapi-codegen as an external command
	command := exec.Command("oapi-codegen", "-generate", "chi-server,types", "-package", "server", specFile)
	output, err := command.CombinedOutput()
	if err != nil {
		fmt.Println("Error:", err)
		return err
	}

	fmt.Println("WALLAK")

	err = os.MkdirAll(filepath.Dir(outputFile), os.ModePerm)
	if err != nil {
		fmt.Println("Error:", err)
		return err
	}

	err = os.WriteFile(outputFile, output, 0644)
	if err != nil {
		fmt.Println("Error writing output file:", err)
		return err
	}

	return nil
}
