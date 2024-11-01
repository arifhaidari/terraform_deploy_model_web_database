package test

// This approach uses Go and Terratest for robust Terraform testing compared to bash scripting.
// Key advantages:
// - Retry configuration: Allows setting the number of retries and time intervals between retries
// - Improved error handling with retryable errors for resilience against transient issues
// - Detailed logging and testing control through Go's testing framework and Terratest's modules

import (
	"crypto/tls"                  // Provides security configurations for HTTP requests
	"fmt"                          // Standard library for formatted I/O operations
	"testing"                      // Go's testing package to define and run unit tests
	"time"                         // Provides time-related functions for setting intervals between retries

	"github.com/gruntwork-io/terratest/modules/http-helper"  // Terratest helper for HTTP requests with retries
	"github.com/gruntwork-io/terratest/modules/terraform"    // Terratest Terraform helper module
)

func TestTerraformHelloWorldExample(t *testing.T) {
	// Define Terraform options with retryable error handling:
	// `terraform.WithDefaultRetryableErrors` wraps common, retryable errors
	// so the test can retry on temporary issues, increasing robustness.
	// `TerraformDir` specifies the path to the Terraform configuration.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../hello_world_app",
	})

	// Clean up resources with `terraform destroy` after test execution.
	// `defer` ensures cleanup even if the test fails partway.
	defer terraform.Destroy(t, terraformOptions)

	// Initialize and apply the Terraform configuration, creating resources.
	// Errors during init/apply are handled through `WithDefaultRetryableErrors`.
	terraform.InitAndApply(t, terraformOptions)

	// Extract the instance URL from Terraform output, where 'url' is the output variable name.
	// This URL is used to make an HTTP request to verify server status.
	instanceURL := terraform.Output(t, terraformOptions, "url")

	// TLS configuration for the HTTP request. An empty `tls.Config{}` can be customized as needed.
	tlsConfig := tls.Config{}

	// Define retry behavior:
	// `maxRetries`: The number of times to retry the request in case of failure (30 retries here)
	// `timeBetweenRetries`: The wait duration between each retry (10 seconds here)
	maxRetries := 30
	timeBetweenRetries := 10 * time.Second

	// Make an HTTP GET request to `instanceURL` with retry functionality and custom validation:
	// `http_helper.HttpGetWithRetryWithCustomValidation` takes:
	// - `t`: The testing context, allowing it to log and manage test assertions.
	// - `instanceURL`: The endpoint being tested.
	// - `tlsConfig`: TLS configuration, which could handle HTTPS or custom certificates.
	// - `maxRetries` and `timeBetweenRetries`: Settings for the retry loop.
	// - `validate`: Custom validation function, defined below, which checks the HTTP status code.
	http_helper.HttpGetWithRetryWithCustomValidation(
		t, instanceURL, &tlsConfig, maxRetries, timeBetweenRetries, validate,
	)
}

// Validation function to check the HTTP response status and body.
// This function takes the HTTP status and response body as arguments:
// - Prints the response body for debugging purposes
// - Returns true if the HTTP status code is 200 (OK), indicating success.
// This is used as the custom validation function in `HttpGetWithRetryWithCustomValidation`.
func validate(status int, body string) bool {
	fmt.Println(body)
	return status == 200
}

// Steps to run this test:
// 1. Run `go mod download` to download and install dependencies specified in the `go.mod` file.
// 2. Run the test with a timeout of 10 minutes (600 seconds), using the command:
//    `go test -v --timeout 10m`
//    - `-v`: Verbose mode for detailed output
//    - `--timeout 10m`: Sets a maximum time limit for the test, ensuring it does not hang indefinitely.
