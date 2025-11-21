#!/bin/bash

# Helm Quick Start Script for 2-Tier Application
# This script helps you quickly test the Helm chart

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    print_success "kubectl is installed"
    
    # Check helm
    if ! command -v helm &> /dev/null; then
        print_error "helm is not installed"
        print_info "Install with: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
        exit 1
    fi
    print_success "helm is installed"
    
    # Check kind
    if ! command -v kind &> /dev/null; then
        print_error "kind is not installed"
        print_info "Install with: curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64"
        exit 1
    fi
    print_success "kind is installed"
    
    # Check if kubectl can connect
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        print_info "Create cluster with: kind create cluster --name demo-cluster"
        exit 1
    fi
    print_success "Connected to Kubernetes cluster"
}

# Build and load webapp image
build_webapp_image() {
    print_header "Building Webapp Image"
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    APP_DIR="$SCRIPT_DIR/app"
    
    if [ ! -d "$APP_DIR" ]; then
        print_error "App directory not found at $APP_DIR"
        exit 1
    fi
    
    print_info "Building webapp:latest image..."
    cd "$APP_DIR"
    docker build -t webapp:latest . || {
        print_error "Failed to build Docker image"
        exit 1
    }
    print_success "Image built successfully"
    
    print_info "Loading image into kind cluster..."
    CLUSTER_NAME=$(kind get clusters | head -n 1)
    kind load docker-image webapp:latest --name "$CLUSTER_NAME" || {
        print_error "Failed to load image into kind cluster"
        exit 1
    }
    print_success "Image loaded into kind cluster"
    
    cd "$SCRIPT_DIR"
}

# Validate Helm chart
validate_chart() {
    print_header "Validating Helm Chart"
    
    CHART_DIR="$SCRIPT_DIR/2-tier-helm-chart"
    
    if [ ! -d "$CHART_DIR" ]; then
        print_error "Helm chart directory not found at $CHART_DIR"
        exit 1
    fi
    
    print_info "Linting chart..."
    helm lint "$CHART_DIR" || {
        print_error "Chart validation failed"
        exit 1
    }
    print_success "Chart is valid"
}

# Install Helm chart
install_chart() {
    print_header "Installing Helm Chart"
    
    RELEASE_NAME="${1:-my-2tier-app}"
    CHART_DIR="$SCRIPT_DIR/2-tier-helm-chart"
    
    print_info "Installing release: $RELEASE_NAME"
    
    # Check if release already exists
    if helm list | grep -q "$RELEASE_NAME"; then
        print_warning "Release $RELEASE_NAME already exists"
        read -p "Do you want to upgrade it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            helm upgrade "$RELEASE_NAME" "$CHART_DIR"
            print_success "Release upgraded successfully"
        fi
    else
        helm install "$RELEASE_NAME" "$CHART_DIR"
        print_success "Release installed successfully"
    fi
    
    print_info "Waiting for pods to be ready..."
    sleep 5
    kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s || true
    kubectl wait --for=condition=ready pod -l app=webapp --timeout=120s || true
}

# Show status
show_status() {
    print_header "Deployment Status"
    
    RELEASE_NAME="${1:-my-2tier-app}"
    
    print_info "Helm release status:"
    helm status "$RELEASE_NAME"
    
    echo ""
    print_info "Kubernetes resources:"
    kubectl get all -l "app.kubernetes.io/instance=$RELEASE_NAME"
    
    echo ""
    print_info "Services:"
    kubectl get svc
    
    # Get NodePort
    NODEPORT=$(kubectl get svc webapp-service -o jsonpath='{.spec.ports[0].nodePort}')
    echo ""
    print_success "Application is accessible at: http://localhost:$NODEPORT"
}

# Uninstall chart
uninstall_chart() {
    print_header "Uninstalling Helm Chart"
    
    RELEASE_NAME="${1:-my-2tier-app}"
    
    if helm list | grep -q "$RELEASE_NAME"; then
        print_info "Uninstalling release: $RELEASE_NAME"
        helm uninstall "$RELEASE_NAME"
        print_success "Release uninstalled successfully"
    else
        print_warning "Release $RELEASE_NAME not found"
    fi
}

# Main menu
show_menu() {
    echo ""
    echo "╔═══════════════════════════════════════════╗"
    echo "║   Helm 2-Tier App Quick Start Script     ║"
    echo "╚═══════════════════════════════════════════╝"
    echo ""
    echo "1) Check prerequisites"
    echo "2) Build and load webapp image"
    echo "3) Validate Helm chart"
    echo "4) Install Helm chart"
    echo "5) Show deployment status"
    echo "6) Uninstall Helm chart"
    echo "7) Full setup (all steps)"
    echo "8) Exit"
    echo ""
}

# Full setup
full_setup() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    check_prerequisites
    build_webapp_image
    validate_chart
    install_chart "my-2tier-app"
    show_status "my-2tier-app"
    
    echo ""
    print_success "🎉 Setup complete!"
    print_info "Access your application at: http://localhost:30080"
}

# Main script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$1" == "--full" ] || [ "$1" == "-f" ]; then
    full_setup
    exit 0
fi

while true; do
    show_menu
    read -p "Select an option (1-8): " choice
    
    case $choice in
        1)
            check_prerequisites
            ;;
        2)
            build_webapp_image
            ;;
        3)
            validate_chart
            ;;
        4)
            read -p "Enter release name (default: my-2tier-app): " release_name
            release_name=${release_name:-my-2tier-app}
            install_chart "$release_name"
            ;;
        5)
            read -p "Enter release name (default: my-2tier-app): " release_name
            release_name=${release_name:-my-2tier-app}
            show_status "$release_name"
            ;;
        6)
            read -p "Enter release name (default: my-2tier-app): " release_name
            release_name=${release_name:-my-2tier-app}
            uninstall_chart "$release_name"
            ;;
        7)
            full_setup
            ;;
        8)
            print_info "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please try again."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
