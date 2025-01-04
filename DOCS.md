# Black Alert - Technical Documentation

## Codebase Structure

### Core Components

#### 1. Lambda Function (`lambda_function.py`)
The main application logic is implemented as an AWS Lambda function that:
- Integrates with Google's Gemini AI API for chat functionality
- Handles HTTP requests and responses
- Implements error handling and CORS support
- Uses async/await pattern for efficient chat processing
- Requires a GEMINI_API_KEY environment variable

#### 2. Infrastructure as Code (`/infra`)
The project uses Terraform for infrastructure management:
- `main.tf`: Core AWS provider and backend configuration
- `lambdas.tf`: Lambda function resource definitions
- `rest_api.tf`: API Gateway configuration
- `aws_users.tf`: IAM user management
- `repo_var.tf`: Repository variables and configuration
- Modular structure with `/modules` directory for reusable components

### CI/CD Pipeline

#### BitBucket Pipeline Configuration (`bitbucket-pipelines.yml`)
Implements a CI/CD pipeline with:
- Python 3.12 base image
- Two-stage pipeline:
  1. Build & Package:
     - Installs dependencies
     - Creates deployment package (code.zip)
     - Packages Lambda function and dependencies
  2. Deployment:
     - Uploads package to S3
     - Updates AWS Lambda function
     - Supports different environments (dev branch configuration included)

### Dependencies
- Python requirements are managed via `requirements.txt`
- Core dependencies include:
  - Google Gemini AI SDK
  - AWS SDK
  - Async/await support libraries

### Environment Configuration
- `.env` file for local development
- Environment variables required:
  - GEMINI_API_KEY
  - AWS credentials and configuration
  - Lambda and S3 bucket names

### Infrastructure Overview
The application is deployed on AWS with:
- Lambda function for serverless execution
- API Gateway for REST API endpoints
- S3 bucket for deployment artifacts
- IAM roles and policies for security
- Terraform-managed infrastructure

## Development Workflow

### Local Development
1. Set up Python virtual environment
2. Configure environment variables
3. Install dependencies from requirements.txt
4. Test Lambda function locally

### Deployment Process
1. Changes pushed to dev branch trigger pipeline
2. Pipeline builds deployment package
3. Package uploaded to S3
4. Lambda function updated automatically
5. API Gateway endpoints updated if needed

### Security Considerations
- CORS configured for API endpoints
- Error handling implements security best practices
- Environment variables used for sensitive data
- IAM roles follow principle of least privilege

## API Documentation

### Endpoints
POST / (main chat endpoint)
- Request Body:
  ```json
  {
    "message": "string"
  }
  ```
- Response:
  ```json
  {
    "response": "string"
  }
  ```
- Error Responses:
  - 400: Bad Request (invalid JSON or missing message)
  - 500: Internal Server Error

### Error Handling
The application implements three levels of error handling:
1. JSON parsing errors
2. Message validation
3. General exception handling

All errors return appropriate HTTP status codes and JSON-formatted error messages.

## Monitoring and Logging
- Lambda function logs to CloudWatch
- Pipeline execution logs in BitBucket
- Infrastructure state tracked in Terraform state files
