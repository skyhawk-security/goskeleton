package main

import (
	"fmt"
	"github.com/getkin/kin-openapi/openapi3"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"text/template"

	"github.com/deepmap/oapi-codegen/pkg/codegen"
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

func generateOpenAPITemplate(outputPath, specFile string) error {
	fmt.Println("generating openapi server and types")

	generatedServerFile := fmt.Sprintf("%s/server.go", outputPath)
	openapiSpecificationFile := fmt.Sprintf("%s/openapi.yaml", outputPath)

	var content []byte
	var err error

	switch {
	case specFile == "":
		specFile = filepath.Join(templatePath, "web/api/openapi.yaml")

		content, err = ioutil.ReadFile(specFile)
		if err != nil {
			fmt.Printf("Error reading file: %v\n", err)
			return err
		}
	case strings.HasPrefix(specFile, "http"):
		content, err = downloadAndLoadFile(specFile)
		if err != nil {
			fmt.Println("unable to download openapi specification file with error: " + err.Error())
		}
	default:
		content, err = ioutil.ReadFile(specFile)
		if err != nil {
			fmt.Printf("Error reading file: %v\n", err)
			return err
		}
	}

	opts := codegen.Configuration{
		PackageName: "api",
		Generate: codegen.GenerateOptions{
			Strict:       true,
			ChiServer:    true,
			Models:       true,
			EmbeddedSpec: true,
		},
	}

	loader := openapi3.NewLoader()
	loader.IsExternalRefsAllowed = true

	// Get a spec from the test definition in this file:
	swagger, err := loader.LoadFromData(content)
	if err != nil {
		return err
	}

	server, err := codegen.Generate(swagger, opts)
	if err != nil {
		return err
	}

	err = os.MkdirAll(filepath.Dir(generatedServerFile), os.ModePerm)
	if err != nil {
		fmt.Println("Error:", err)
		return err
	}

	// write the generated server to disk
	err = os.WriteFile(generatedServerFile, []byte(server), 0644)
	if err != nil {
		fmt.Println("Error writing output file:", err)
		return err
	}

	// write the openapi template to disk
	err = os.WriteFile(openapiSpecificationFile, content, 0644)
	if err != nil {
		fmt.Println("Error writing output file:", err)
		return err
	}

	return nil
}

func isAlphabeticLowercase(input string) bool {
	pattern := "^[a-z]+$"

	regex, err := regexp.Compile(pattern)
	if err != nil {
		fmt.Println("Error compiling regular expression:", err)
		return false
	}

	return regex.MatchString(input)
}

func downloadAndLoadFile(url string) ([]byte, error) {
	// Send an HTTP GET request to the specified URL
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// Check if the request was successful
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HTTP request failed with status code %d", resp.StatusCode)
	}

	// Read the response body (file content) into a byte slice
	fileContent, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return fileContent, nil
}
