# Kubernetes Deployment Guide

This directory contains Kubernetes manifests for deploying the React + Node.js + Firebase application.

## Prerequisites

- Kubernetes cluster (Minikube, Docker Desktop, or cloud provider)
- `kubectl` CLI tool
- Docker images built and available

## Quick Deployment

1. **Build Docker Images:**
   ```bash
   # From the project root
   docker build -t your-registry.com/react-nodejs-app-backend:latest backend/
   docker build -t your-registry.com/react-nodejs-app-frontend:latest frontend/
   ```

2. **Load Images into Minikube:**
   ```bash
   minikube image load your-registry.com/react-nodejs-app-backend:latest
   minikube image load your-registry.com/react-nodejs-app-frontend:latest
   ```

3. **Deploy to Kubernetes:**
   ```bash
   kubectl apply -f namespace.yaml
   kubectl apply -f configmap.yaml
   kubectl apply -f secret.yaml
   kubectl apply -f backend-deployment.yaml
   kubectl apply -f frontend-deployment.yaml
   kubectl apply -f services.yaml
   ```

## Configuration

### ConfigMap (`configmap.yaml`)
- `FRONTEND_URL`: Frontend service URL
- `PORT`: Backend service port
- `REACT_APP_BACKEND_URL`: Backend URL for frontend
- `FIREBASE_PROJECT_ID`: Firebase project ID

### Secret (`secret.yaml`)
- `firebase-project-id`: Base64 encoded Firebase project ID

## Access Points

### Internal Services
- **Backend API**: `nodejs-api-service:8000`
- **Frontend**: `react-app-service:3000`

### External Access (Port Forwarding)
```bash
# Backend API
kubectl port-forward service/nodejs-api-service 8000:8000 -n react-nodejs-app

# Frontend
kubectl port-forward service/react-app-service 3000:3000 -n react-nodejs-app
```

## Monitoring

### Check Status
```bash
# All resources
kubectl get all -n react-nodejs-app

# Pods only
kubectl get pods -n react-nodejs-app

# Services
kubectl get services -n react-nodejs-app
```

### View Logs
```bash
# Backend logs
kubectl logs -n react-nodejs-app deployment/nodejs-backend

# Frontend logs
kubectl logs -n react-nodejs-app deployment/react-frontend
```

### Test API
```bash
# Health check
curl http://localhost:8000/health

# API data
curl http://localhost:8000/api/data
```

## Cleanup

```bash
# Delete all resources
kubectl delete namespace react-nodejs-app

# Or delete individual resources
kubectl delete -f services.yaml
kubectl delete -f frontend-deployment.yaml
kubectl delete -f backend-deployment.yaml
kubectl delete -f secret.yaml
kubectl delete -f configmap.yaml
kubectl delete -f namespace.yaml
```

## Troubleshooting

### Common Issues

1. **Image Pull Errors**
   - Ensure images are built and loaded into the cluster
   - Check image names in deployment files

2. **Pod Not Ready**
   - Check pod logs: `kubectl logs <pod-name> -n react-nodejs-app`
   - Verify environment variables and secrets

3. **Service Not Accessible**
   - Use port forwarding for external access
   - Check service endpoints: `kubectl get endpoints -n react-nodejs-app`

### Useful Commands

```bash
# Describe resources for detailed info
kubectl describe pod <pod-name> -n react-nodejs-app
kubectl describe service <service-name> -n react-nodejs-app

# Execute commands in pods
kubectl exec -it <pod-name> -n react-nodejs-app -- /bin/sh

# Get resource usage
kubectl top pods -n react-nodejs-app
```

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Firebase      │
│   (React)       │◄──►│   (Node.js)     │◄──►│   (Auth/DB)     │
│   Port: 3000    │    │   Port: 8000    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

- **Frontend**: React application with Firebase authentication
- **Backend**: Node.js API with Firebase Admin SDK
- **Services**: Internal communication between frontend and backend
- **Secrets**: Secure storage for Firebase credentials 