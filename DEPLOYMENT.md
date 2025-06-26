# Guitar Tabs Player - Deployment Guide

This document provides comprehensive information about deploying and maintaining the Guitar Tabs Player application.

## Table of Contents

1. [Application Overview](#application-overview)
2. [Architecture](#architecture)
3. [Local Development Setup](#local-development-setup)
4. [Deployment to Azure](#deployment-to-azure)
5. [CI/CD Pipeline Configuration](#cicd-pipeline-configuration)
6. [Monitoring and Maintenance](#monitoring-and-maintenance)
7. [Security Considerations](#security-considerations)
8. [Cost Analysis](#cost-analysis)

## Application Overview

Guitar Tabs Player is a web application for displaying and playing guitar tablatures. Key features include:

- Tablature display and playback using AlphaTab library
- Guitar Tuner using Web Audio API
- Karaoke Tab Mode with note/chord highlighting
- User-uploaded tablature file management
- Responsive design for desktop and mobile

## Architecture

The application consists of:

1. **Frontend**: Vue.js 3 application with TypeScript
2. **Backend**: Python Flask RESTful API
3. **Infrastructure**: Azure-hosted services

### Technology Stack

#### Frontend
- Vue.js 3 with TypeScript
- AlphaTab for tablature rendering and playback
- Web Audio API for Guitar Tuner
- Storybook for component documentation

#### Backend
- Python 3.11
- Flask web framework
- Flask-SocketIO for WebSocket support
- Docker containerization

#### Infrastructure
- Azure Container Registry for Docker images
- Azure Web App for Containers
- Azure Front Door for global routing and caching
- Azure Key Vault for secrets management
- Azure Monitor and App Insights for monitoring

## Local Development Setup

### Prerequisites
- Node.js 18+ and Bun
- Python 3.11+
- Docker
- Git

### Frontend Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/GuitarTabs.git
   cd GuitarTabs
   ```

2. Install frontend dependencies:
   ```bash
   cd frontend
   bun install
   ```

3. Create `.env` file:
   ```
   VITE_API_URL=http://localhost:5000
   ```

4. Start development server:
   ```bash
   bun dev
   ```

### Backend Setup

1. Create Python virtual environment:
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Create `.env` file:
   ```
   SECRET_KEY=your_secret_key_here
   UPLOAD_FOLDER=uploads
   PORT=5000
   ```

4. Start Flask server:
   ```bash
   python app.py
   ```

### Docker Setup

You can also use Docker to run both services:

#### Prerequisites
- Docker Desktop must be installed and running
- WSL 2 integration enabled (Windows only)

#### Backend Docker Commands

**Using the helper script (recommended):**
```powershell
cd backend
# Build the image
.\docker-helper.ps1 build

# Run the container
.\docker-helper.ps1 run

# View logs
.\docker-helper.ps1 logs

# Stop the container
.\docker-helper.ps1 stop
```

**Manual Docker commands:**
```bash
cd backend
# Build the image
docker build -t guitar-tabs-backend .

# Run the container with volume mounting for uploads
docker run -d --name guitar-tabs-backend-container -p 5000:5000 -v "${PWD}/uploads:/app/uploads" guitar-tabs-backend

# Check container status
docker ps

# View logs
docker logs guitar-tabs-backend-container
```

#### Frontend Docker Commands

```bash
cd frontend
docker build -t guitar-tabs-frontend .
docker run -p 8080:80 guitar-tabs-frontend
```

#### Troubleshooting Docker Issues

If you encounter Docker errors, see the [TROUBLESHOOTING.md](TROUBLESHOOTING.md#docker-issues) file for detailed solutions.

## Deployment to Azure

### Prerequisites
- Azure subscription
- Azure CLI installed and configured
- Registered domain name (optional for custom domain)

### Deployment Steps

1. Log in to Azure:
   ```bash
   az login
   ```

2. Run the deployment script:
   ```bash
   # On Linux/macOS
   ./infrastructure/deploy.sh
   
   # On Windows
   .\infrastructure\deploy.ps1
   ```

3. The script will:
   - Create a resource group
   - Set up Azure Container Registry
   - Create Azure Key Vault
   - Deploy the Bicep template
   - Configure all necessary Azure resources

4. After deployment completes, you'll receive URLs for:
   - Frontend application
   - Backend API
   - Azure Front Door endpoint

### Custom Domain Configuration

1. Add a CNAME record in your domain's DNS configuration:
   ```
   Name: www (or subdomain of your choice)
   Value: [your-frontdoor-name].azurefd.net
   TTL: 3600 (or as desired)
   ```

2. Configure SSL certificate in Azure Front Door for your custom domain.

## CI/CD Pipeline Configuration

The project includes GitHub Actions workflow for CI/CD:

### Setup Steps

1. Add the following secrets to your GitHub repository:
   - `REGISTRY_USERNAME`: ACR username
   - `REGISTRY_PASSWORD`: ACR password
   - `AZURE_CREDENTIALS`: JSON output from Azure service principal

2. Create an Azure service principal:
   ```bash
   az ad sp create-for-rbac --name "GuitarTabsGitHubActions" --role contributor \
     --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
     --sdk-auth
   ```

3. The workflow will automatically:
   - Build and test the frontend and backend
   - Create Docker images
   - Push images to Azure Container Registry
   - Deploy to Azure Web Apps

## Monitoring and Maintenance

### Azure Monitor

- Application performance monitoring is configured via Application Insights
- Set up alerts for key metrics:
  - Response time > 1s
  - Error rate > 1%
  - CPU usage > 80%

### Log Analytics

- All application logs are forwarded to Log Analytics workspace
- Use Kusto Query Language (KQL) to analyze logs
- Example query for error tracking:
  ```
  AppEvents
  | where Level == "Error"
  | summarize count() by EventId, bin(TimeGenerated, 1h)
  ```

### Maintenance Tasks

- Regularly update dependencies
- Monitor disk usage for uploaded files
- Set up automatic backups for user data
- Implement database cleanup for old/unused tablature files

## Security Considerations

### Authentication and Authorization

- API endpoints are secured using JWT tokens
- User authentication can be implemented with Azure AD B2C
- CORS is configured to restrict API access

### Data Protection

- All data in transit is encrypted via HTTPS
- Uploaded files are stored securely with limited access
- Sensitive configuration is stored in Azure Key Vault

### Network Security

- Azure Front Door provides DDoS protection
- Web Application Firewall (WAF) policies are configured
- Network security groups restrict access to backend services

## Cost Analysis

Monthly cost estimate for Azure services:

| Service | Configuration | Estimated Monthly Cost (USD) |
|---------|---------------|------------------------------|
| Azure DNS | Zone with basic records | $0.50 |
| Azure Front Door | 50 GB bandwidth | $35.00 |
| Azure Container Apps | 2 vCPU, 4 GB RAM, 1 instance | $75.00 |
| Azure Container Registry | Basic tier | $5.00 |
| Azure App Service | 2 instances (P1v2) | $146.00 |
| Azure Key Vault | 10 secrets, 5000 operations | $0.50 |
| Azure Monitor | Basic usage | $12.00 |
| Azure Defender | App Service protection | $15.00 |
| **Total** | | **$289.00** |

*Note: Actual costs may vary based on usage patterns and Azure region.*

### Cost Optimization Tips

1. Scale down resources during low-traffic periods
2. Use reserved instances for predictable workloads
3. Configure auto-scaling based on demand
4. Monitor and set budget alerts
5. Consider switching to Consumption plan for lower traffic applications

---

For additional assistance or questions about this deployment guide, please contact the development team.
