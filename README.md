# CreatWorx Admin Dashboard

A comprehensive admin dashboard for managing the CreatWorx platform, built with Next.js 14, React 18, TypeScript, and Material-UI.

## 🚀 Features

- **Modern Tech Stack**: Next.js 14, React 18, TypeScript 5, Material-UI
- **State Management**: Redux Toolkit with RTK Query
- **Authentication**: JWT-based authentication with role-based access control
- **Real-time Updates**: WebSocket integration for live data
- **Responsive Design**: Mobile-first responsive UI
- **Dark/Light Theme**: Theme switching capability
- **Internationalization**: Multi-language support
- **Analytics Dashboard**: Real-time metrics and charts
- **User Management**: Complete user CRUD operations
- **Content Management**: Media and content moderation
- **System Monitoring**: Health checks and performance metrics

## 📋 Prerequisites

- Node.js 18+ 
- npm 8+
- Docker (for containerization)
- Kubernetes (for deployment)
- Google Cloud Platform (for production deployment)

## 🛠️ Installation

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/AkshayDubey29/cw-admin.git
   cd cw-admin
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env.local
   # Edit .env.local with your configuration
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

5. **Open your browser**
   Navigate to [http://localhost:3000](http://localhost:3000)

### Production Build

```bash
# Build the application
npm run build

# Start production server
npm start
```

## 🏗️ Project Structure

```
cw-admin/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── layout/         # Layout components
│   │   ├── dashboard/      # Dashboard components
│   │   ├── forms/          # Form components
│   │   ├── ui/             # Basic UI components
│   │   ├── charts/         # Chart components
│   │   ├── tables/         # Table components
│   │   └── modals/         # Modal components
│   ├── pages/              # Next.js pages
│   │   ├── admin/          # Admin pages
│   │   ├── auth/           # Authentication pages
│   │   └── api/            # API routes
│   ├── store/              # Redux store
│   │   └── slices/         # Redux slices
│   ├── services/           # API services
│   ├── hooks/              # Custom React hooks
│   ├── utils/              # Utility functions
│   ├── types/              # TypeScript type definitions
│   ├── constants/          # Application constants
│   ├── styles/             # Global styles
│   └── assets/             # Static assets
├── k8s/                    # Kubernetes manifests
├── public/                 # Public assets
├── tests/                  # Test files
└── docs/                   # Documentation
```

## 🐳 Docker

### Build Docker Image

```bash
# Build the image
docker build -t gcr.io/createworx/cw-admin:latest .

# Run locally
docker run -p 3000:3000 gcr.io/createworx/cw-admin:latest
```

### Multi-stage Build

The Dockerfile uses multi-stage builds for optimization:
- **Base stage**: Installs global dependencies
- **Builder stage**: Builds the application
- **Production stage**: Creates minimal production image

## ☸️ Kubernetes Deployment

### Prerequisites

- GKE cluster configured
- kubectl configured
- gcloud authenticated

### Deploy to GKE

```bash
# Deploy all components
make deploy-k8s

# Or deploy individually
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/hpa.yaml
```

### Kubernetes Resources

- **Namespace**: `creatworx`
- **Deployment**: 3 replicas with auto-scaling
- **Service**: ClusterIP service
- **Ingress**: GCE ingress with SSL
- **HPA**: Horizontal Pod Autoscaler (2-10 replicas)

## 🔧 Configuration

### Environment Variables

```bash
# API Configuration
NEXT_PUBLIC_API_URL=https://api.creatworx.com

# Authentication
JWT_SECRET=your-jwt-secret

# Database
DATABASE_URL=postgresql://user:password@host:port/database

# Redis
REDIS_URL=redis://host:port/0

# Application
NODE_ENV=production
NEXT_PUBLIC_APP_NAME=CreatWorx Admin
NEXT_PUBLIC_APP_VERSION=1.0.0
```

### Kubernetes ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cw-admin-config
  namespace: creatworx
data:
  NEXT_PUBLIC_API_URL: "https://api.creatworx.com"
  NODE_ENV: "production"
  NEXT_PUBLIC_APP_NAME: "CreatWorx Admin"
  NEXT_PUBLIC_APP_VERSION: "1.0.0"
```

## 🧪 Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run performance tests
make performance-test
```

## 📊 Monitoring & Health Checks

### Health Endpoint

```bash
# Check application health
curl http://localhost:3000/api/health
```

### Kubernetes Probes

- **Liveness Probe**: `/api/health` (30s initial delay)
- **Readiness Probe**: `/api/health` (5s initial delay)

### Metrics

- CPU and Memory usage
- Request/Response times
- Error rates
- Active users count

## 🔒 Security

### Security Features

- JWT-based authentication
- Role-based access control (RBAC)
- HTTPS enforcement
- CORS configuration
- Input validation with Zod
- XSS protection
- CSRF protection

### Security Headers

```javascript
// Security headers in next.config.js
async headers() {
  return [
    {
      source: '/(.*)',
      headers: [
        { key: 'X-Frame-Options', value: 'DENY' },
        { key: 'X-Content-Type-Options', value: 'nosniff' },
        { key: 'Referrer-Policy', value: 'origin-when-cross-origin' },
      ],
    },
  ];
}
```

## 🚀 CI/CD Pipeline

### GitHub Actions

The service includes a comprehensive CI/CD pipeline:

1. **Testing**: Lint, type-check, and unit tests
2. **Build**: Docker image build and push to GCR
3. **Deploy**: Automatic deployment to GKE
4. **Security**: Vulnerability scanning with Trivy
5. **Performance**: Load testing with Artillery

### Pipeline Stages

```yaml
jobs:
  test:           # Run tests and linting
  build-and-push: # Build and push Docker image
  deploy:         # Deploy to GKE
  security-scan:  # Security vulnerability scan
  performance-test: # Performance testing
  notify:         # Deployment notifications
```

## 📈 Performance

### Optimization Features

- **Code Splitting**: Automatic code splitting by Next.js
- **Image Optimization**: Next.js Image component
- **Bundle Analysis**: Webpack bundle analyzer
- **Caching**: Redis caching layer
- **CDN**: Static asset delivery via CDN

### Performance Metrics

- **Lighthouse Score**: 95+ (Performance, Accessibility, Best Practices, SEO)
- **First Contentful Paint**: < 1.5s
- **Largest Contentful Paint**: < 2.5s
- **Time to Interactive**: < 3.5s

## 🔧 Development

### Available Scripts

```bash
# Development
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server

# Testing
npm test             # Run tests
npm run test:watch   # Run tests in watch mode
npm run test:coverage # Run tests with coverage

# Code Quality
npm run lint         # Run ESLint
npm run lint:fix     # Fix linting issues
npm run format       # Format code with Prettier
npm run type-check   # Run TypeScript type checking

# Docker
make docker-build    # Build Docker image
make docker-push     # Push to registry
make docker-run      # Run locally

# Deployment
make deploy-gcp      # Deploy to GCP
make deploy-k8s      # Deploy to Kubernetes
```

### Makefile Commands

```bash
# Show all available commands
make help

# Development setup
make setup-dev

# CI pipeline
make ci

# Deployment
make deploy-gcp

# Monitoring
make logs
make status
make health-check
```

## 📚 API Documentation

### Authentication Endpoints

```typescript
// Login
POST /api/admin/auth/login
{
  "email": "admin@creatworx.com",
  "password": "password"
}

// Logout
POST /api/admin/auth/logout

// Get Profile
GET /api/admin/profile
```

### User Management Endpoints

```typescript
// Get Users
GET /api/admin/users?page=1&limit=20&status=active

// Get User
GET /api/admin/users/:id

// Update User
PUT /api/admin/users/:id
{
  "status": "active",
  "role": "creator"
}

// Delete User
DELETE /api/admin/users/:id
```

### Analytics Endpoints

```typescript
// Dashboard Stats
GET /api/admin/analytics/dashboard

// System Metrics
GET /api/admin/analytics/system

// User Analytics
GET /api/admin/analytics/users?period=7d

// Content Analytics
GET /api/admin/analytics/content?period=30d
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow TypeScript best practices
- Write unit tests for new features
- Follow the existing code style
- Update documentation for API changes
- Ensure all tests pass before submitting PR

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [https://docs.creatworx.com](https://docs.creatworx.com)
- **Issues**: [GitHub Issues](https://github.com/AkshayDubey29/cw-admin/issues)
- **Discussions**: [GitHub Discussions](https://github.com/AkshayDubey29/cw-admin/discussions)
- **Email**: support@creatworx.com

## 🏆 Acknowledgments

- Next.js team for the amazing framework
- Material-UI for the beautiful components
- Redux Toolkit for state management
- The CreatWorx development team

---

**Built with ❤️ by the CreatWorx Team**
# Trigger CI/CD Pipeline
# Test GCR permissions fix
