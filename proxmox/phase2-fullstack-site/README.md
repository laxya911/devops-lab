# Phase 2 Full-Stack Application

A modern full-stack web application built with Next.js, Tailwind CSS, and Shadcn UI components. Features a task management system with CRUD operations.

## Features

- **Task Management**: Create, read, update, and delete tasks
- **Responsive Design**: Mobile-first design with Tailwind CSS
- **Modern UI**: Clean interface using Shadcn UI components
- **TypeScript**: Full type safety with TypeScript
- **Docker Support**: Containerized deployment
- **Kubernetes Ready**: Deployed on K3s cluster

## Tech Stack

- **Frontend**: Next.js 15, React 18.3, TypeScript
- **Styling**: Tailwind CSS 3.4, Shadcn UI
- **Backend**: Next.js API routes (for future database integration)
- **Deployment**: Docker, Kubernetes (K3s)
- **CI/CD**: Jenkins, Nexus Registry
- **Node.js**: 22 (LTS)

## Local Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Run the development server:
   ```bash
   npm run dev
   ```

3. Open [http://localhost:3000](http://localhost:3000) in your browser.

## Docker Build

```bash
docker build -t phase2-fullstack-app .
docker run -p 3000:3000 phase2-fullstack-app
```

## Deployment

The application is automatically deployed to the K3s cluster via Jenkins CI/CD pipeline.

- **Jenkins Pipeline**: Builds, tests, and deploys the application
- **Nexus Registry**: Stores Docker images
- **K3s Cluster**: Runs the application pods

## Project Structure

```
phase2-fullstack-site/
├── src/
│   └── app/
│       ├── globals.css
│       ├── layout.tsx
│       └── page.tsx
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── Dockerfile
├── Jenkinsfile
├── package.json
└── README.md
```

## Future Enhancements

- Database integration (MongoDB/PostgreSQL)
- User authentication
- API endpoints for CRUD operations
- Real-time updates
- Advanced task features (due dates, categories, etc.)