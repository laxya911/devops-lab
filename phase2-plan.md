# Phase 2: Full-Stack Application Deployment Plan

## Overview
This phase transitions from a static site to a full-stack application deployment in the K3s cluster using Jenkins CI/CD pipeline. The application will be a Node.js app using Next.js, Tailwind CSS, and Shadcn UI components, with database integration for CRUD operations.

## Tasks

### 1. Automate Jenkins Server Initial Configuration
- **Objective**: Fully automate Jenkins setup after container startup, eliminating manual steps.
- **Current State**: Jenkins runs in Docker, but requires manual:
  - Accessing initial admin password from container logs.
  - Creating admin user.
  - Installing suggested plugins.
  - Setting up Docker-hosted registry.
- **Actions**:
  - Verify existing `jenkins_initial_conf.yml` (JCasC format) and `plugins.txt`.
  - Modify `04-jenkins-nexus.yml` playbook to:
    - Wait for Jenkins to be ready.
    - Retrieve initial admin password.
    - Use JCasC to apply initial configuration (create admin user, set security).
    - Install plugins from `plugins.txt`.
    - Configure Docker registry in Jenkins.
  - Ensure all steps are idempotent and handle restarts.

### 2. Automate Nexus Server Initial Configuration
- **Objective**: Automate Nexus setup similar to Jenkins.
- **Current State**: Nexus runs in Docker, requires manual initial configuration.
- **Actions**:
  - Create `nexus_initial_conf.yml` or scripts for Nexus initial setup.
  - Modify `04-jenkins-nexus.yml` playbook to:
    - Wait for Nexus to be ready.
    - Create admin user via REST API.
    - Configure repositories (Docker registry, etc.).
    - Set up anonymous access if needed.
  - Use Nexus REST API for automation.

### 3. Update Ansible Playbook
- **File**: `ansible/playbooks/04-jenkins-nexus.yml`
- **Changes**:
  - Add tasks for Jenkins automation post-container start.
  - Add tasks for Nexus automation post-container start.
  - Ensure proper sequencing and error handling.

### 4. Create Full-Stack Application
- **Directory**: `phase2-fullstack-site`
- **Technology Stack**:
  - Next.js (React framework)
  - Tailwind CSS (styling)
  - Shadcn UI (component library)
  - Database: MongoDB or PostgreSQL for CRUD operations
  - API: REST or GraphQL for backend
- **Features**:
  - User management (CRUD)
  - Sample data model (e.g., blog posts, products)
  - Responsive UI
- **Structure**:
  - Dockerfile
  - Kubernetes manifests (deployment, service)
  - Jenkinsfile for CI/CD
  - README.md

### 5. Update CI/CD Pipeline
- Modify Jenkins pipeline to handle full-stack app deployment.
- Include database setup if needed.
- Ensure integration with Nexus for artifact management.

### 6. Testing and Validation
- Update validation playbook `99-validate.yml` to check full-stack app.
- Add health checks for database connectivity.

## Timeline
- Day 1: Automate Jenkins and Nexus configurations, update playbook.
- Day 2: Create full-stack application structure and basic CRUD functionality.
- Day 3: Implement UI components, styling, and testing.
- Day 4: Update Kubernetes manifests and Jenkins pipeline.

## Dependencies
- Existing K3s cluster
- Docker registry in Nexus
- Database service (to be deployed or configured)

## Risks and Mitigations
- API changes in Jenkins/Nexus: Use stable APIs and version pinning.
- Database connectivity: Ensure proper networking in K8s.
- Plugin compatibility: Test plugin installations.