package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

func validate(serviceName, finalDestination string) error {
	if !isAlphabeticLowercase(serviceName) {
		return fmt.Errorf("serviceName should be alphabetic lower case only")
	}

	_, err := os.Stat(finalDestination)
	if !os.IsNotExist(err) {
		return fmt.Errorf("service %s already exists", serviceName)
	}

	return nil
}

func (s *Service) generateService(finalDestination string) error {
	myServiceTemplatePaths, err := findFilesWithSuffix(filepath.Join(templatePath, s.Type), ".tpl")
	if err != nil {
		fmt.Println("Error:", err)
		return err
	}

	for _, t := range myServiceTemplatePaths {
		if err := s.processTemplate(t, finalDestination); err != nil {
			fmt.Printf("error processing template: %v", err)
			return err
		}
		fmt.Printf("processing template %s\n", t)
	}

	command := exec.Command("go", "mod", "tidy")
	command.Dir = finalDestination
	_, err = command.CombinedOutput()
	if err != nil {
		fmt.Println("Error:", err)
		return err
	}

	return nil
}
