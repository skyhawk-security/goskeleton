package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"text/template"
)

func findFilesWithSuffix(directory, suffix string) ([]string, error) {
	var matchingFiles []string

	err := filepath.Walk(directory, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && filepath.Ext(path) == suffix {
			matchingFiles = append(matchingFiles, path)
		}
		return nil
	})

	if err != nil {
		return nil, err
	}

	return matchingFiles, nil
}

func processTemplate(pathToTemplate, serviceName, serviceType, finalDestination string) error {
	if !strings.HasSuffix(pathToTemplate, ".tpl") {
		return fmt.Errorf("%s is not a template", pathToTemplate)
	}

	templateContent, err := ioutil.ReadFile(pathToTemplate)
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

	writePath := filepath.Join(finalDestination, strings.TrimSuffix(strings.TrimPrefix(pathToTemplate, fmt.Sprintf("%s/%s", templatePath, serviceType)), ".tpl"))

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
	specFile := filepath.Join(templatePath, "web/api/openapi.yaml.tpl")
	outputFile := fmt.Sprintf("%s/server.go", outputPath)

	// Run oapi-codegen as an external command
	command := exec.Command("oapi-codegen", "-generate", "chi-server,types,spec", "-package", "server", specFile)
	output, err := command.CombinedOutput()
	if err != nil {
		fmt.Println("Error:", err)
		return err
	}

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
