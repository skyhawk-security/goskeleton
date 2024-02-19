package main

import (
	"fmt"
	"github.com/getkin/kin-openapi/openapi3"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"text/template"

	"github.com/deepmap/oapi-codegen/pkg/codegen"
)

// find the relevant files
func findFilesWithSuffix(directory, suffix string) ([]string, error) {
	var files []string
	var matchingFiles []string

	entries, err := templateFs.ReadDir(directory)
	if err != nil {
		return nil, err
	}

	for _, entry := range entries {
		if entry.IsDir() {
			// Recursively list files in subdirectories if needed.
			subdirectory := filepath.Join(directory, entry.Name())
			subFiles, err := findFilesWithSuffix(subdirectory, suffix)
			if err != nil {
				return nil, err
			}
			files = append(files, subFiles...)
		} else {
			files = append(files, filepath.Join(directory, entry.Name()))
		}
	}

	for _, f := range files {
		if filepath.Ext(f) == suffix {
			matchingFiles = append(matchingFiles, f)
		}
	}

	return matchingFiles, nil
}

func (s *Service) processTemplate(pathToTemplate, finalDestination string) error {
	if !strings.HasSuffix(pathToTemplate, ".tpl") {
		return fmt.Errorf("%s is not a template", pathToTemplate)
	}

	templateContent, err := templateFs.ReadFile(pathToTemplate)
	if err != nil {
		return err
	}

	caser := cases.Title(language.English)
	serviceNameUpper := caser.String(s.Name)

	data := struct {
		ServiceName      string
		ServiceNameUpper string
		EventSource      EventSource
		EventSourceARN   string
	}{
		ServiceName:      s.Name,
		ServiceNameUpper: serviceNameUpper,
		EventSource:      s.EventSource,
		EventSourceARN:   s.EventSourceARN,
	}

	writePath := filepath.Join(finalDestination, strings.TrimSuffix(strings.TrimPrefix(pathToTemplate, fmt.Sprintf("%s/%s", templatePath, s.Type)), ".tpl"))

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

	// make the file executable if we're going to need to execute it
	if strings.HasSuffix(writePath, "sh") {
		if err := os.Chmod(writePath, os.FileMode(0755)); err != nil {
			fmt.Println("Error changing file permissions:", err)
			return err
		}
	}

	// Create a new template
	tmpl := template.Must(template.New("my-template").Delims("[[[", "]]]").Parse(string(templateContent)))

	// execute the template and write to the output file.
	err = tmpl.Execute(outputFile, data)
	if err != nil {
		fmt.Println("Error executing template:", err)
		return err
	}

	return nil
}

func generateOpenAPITemplate(outputPath, specFile string) error {
	fmt.Println("generating openapi server and types")

	generatedServerFile := fmt.Sprintf("%s/server.gen.go", outputPath)
	openapiSpecificationFile := fmt.Sprintf("%s/openapi.yaml", outputPath)

	var content []byte
	var err error

	switch {
	// if no openapi template specified.
	case specFile == "":
		specFile = filepath.Join(templatePath, "web/api/openapi.yaml")
		content, err = templateFs.ReadFile(specFile)
	// openapi specified from the web.
	case strings.HasPrefix(specFile, "http"):
		content, err = downloadAndLoadFile(specFile)
	default:
		content, err = os.ReadFile(specFile)
	}

	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		return err
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

	// Get a spec from the test definition in this file.
	swagger, err := loader.LoadFromData(content)
	if err != nil {
		return err
	}

	// generate the openapi server.
	server, err := codegen.Generate(swagger, opts)
	if err != nil {
		return err
	}

	// create a directory for the generated service.
	err = os.MkdirAll(filepath.Dir(generatedServerFile), os.ModePerm)
	if err != nil {
		fmt.Println("Error creating a directory:", err)
		return err
	}

	// write the generated server to disk.
	err = os.WriteFile(generatedServerFile, []byte(server), 0644)
	if err != nil {
		fmt.Println("Error writing output file:", err)
		return err
	}

	// write the openapi template to disk.
	err = os.WriteFile(openapiSpecificationFile, content, 0644)
	if err != nil {
		fmt.Println("Error writing output file:", err)
		return err
	}

	return nil
}

func isAlphabeticLowercase(input string) bool {
	regex, err := regexp.Compile("^[a-z]+$")
	if err != nil {
		fmt.Println("Error compiling regular expression:", err)
		return false
	}

	return regex.MatchString(input)
}

func downloadAndLoadFile(url string) ([]byte, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}

	defer resp.Body.Close() // nolint

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HTTP request failed with status code %d", resp.StatusCode)
	}

	fileContent, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return fileContent, nil
}
