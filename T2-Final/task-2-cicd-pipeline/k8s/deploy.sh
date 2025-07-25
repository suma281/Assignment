#!/bin/bash

echo "🚀 Deploying React + Node.js + Firebase App to Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to the cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "Please ensure your cluster is running (minikube start, etc.)"
    exit 1
fi

echo "✅ Kubernetes cluster is accessible"

# Deploy resources in order
echo "📦 Creating namespace..."
kubectl apply -f namespace.yaml

echo "⚙️  Creating ConfigMap..."
kubectl apply -f configmap.yaml

echo "🔐 Creating Secret..."
kubectl apply -f secret.yaml

echo "🔧 Deploying Backend..."
kubectl apply -f backend-deployment.yaml

echo "🎨 Deploying Frontend..."
kubectl apply -f frontend-deployment.yaml

echo "🌐 Creating Services..."
kubectl apply -f services.yaml

echo "🔴 Deploying Redis..."
kubectl apply -f redis-deployment.yaml

echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/nodejs-backend -n react-nodejs-app
kubectl wait --for=condition=available --timeout=300s deployment/react-frontend -n react-nodejs-app
kubectl wait --for=condition=available --timeout=300s deployment/redis -n react-nodejs-app

echo "✅ Deployment completed!"
echo ""
echo "📊 Current Status:"
kubectl get all -n react-nodejs-app

echo ""
echo "🔗 To access the application:"
echo "Backend API: kubectl port-forward service/nodejs-api-service 8000:8000 -n react-nodejs-app"
echo "Frontend:    kubectl port-forward service/react-app-service 3000:3000 -n react-nodejs-app"
echo ""
echo "📝 To view logs:"
echo "Backend: kubectl logs -f deployment/nodejs-backend -n react-nodejs-app"
echo "Frontend: kubectl logs -f deployment/react-frontend -n react-nodejs-app" 