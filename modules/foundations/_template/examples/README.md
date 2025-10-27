# Examples for the '**MODULE_NAME**' Module

This directory contains working examples of how to use the `__MODULE_NAME__` module.

## Available Examples

Please choose an example directory below to test a specific scenario.

1.  **[`basic/`](./basic/main.tf)**:

    - Demonstrates the most basic usage of the module with default or minimal settings.
    - **TODO**: Describe what this basic example creates.

2.  **[`advanced/`](./advanced/main.tf)**:
    - Showcases how to enable and configure the module's optional or advanced features.
    - **TODO**: Describe what advanced features are demonstrated in this example.

## How to Run an Example

> **Note:** You must be authenticated to Azure and have the necessary environment variables set (e.g., via `source .env`).

1.  **Navigate into your chosen example directory:**

    ```bash
    cd examples/basic
    ```

2.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

3.  **Review the execution plan:**

    ```bash
    terraform plan
    ```

4.  **(Optional) Apply the configuration:**

    ```bash
    terraform apply
    ```

5.  **Clean up resources:**
    After you are done testing, remember to destroy all created resources.
    ```bash
    terraform destroy
    ```
