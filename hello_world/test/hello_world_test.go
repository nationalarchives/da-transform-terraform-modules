package test

import (
	"fmt"
	"strings"
	"testing"

	
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)


func TestTerraformAwsS3Example(t *testing.T) {
	t.Parallel()


	expectedName := fmt.Sprintf("terratest-aws-s3-example-%s", strings.ToLower(random.UniqueId()))


	

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../hello_world",

		Vars: map[string]interface{}{
			"pipeline_deployment_bucket_name":        expectedName,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
}