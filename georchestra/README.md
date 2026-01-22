# geOrchestra Helm Chart

This is the official Helm chart for deploying geOrchestra on Kubernetes clusters.

## Maintainers

### Creating a New Chart Release

**IMPORTANT**: Avoid creating too many versions. Test changes using git submodules or other methods. Release versions in batches when possible.

1. Update the version in `Chart.yaml` following [Semantic Versioning](https://semver.org):
   - **MINOR** version: New features
   - **PATCH** version: Bug fixes
2. Document changes in `CHANGELOG.md`
3. Push your changes

## Quick Start

1. Install an Ingress Controller if you don't already have one:
   ```bash
   helm upgrade --install ingress-nginx ingress-nginx \
      --repo https://kubernetes.github.io/ingress-nginx \
      --namespace ingress-nginx --create-namespace
   ```

2. Install geOrchestra:
   ```bash
   helm install georchestra oci://ghcr.io/georchestra/helm-charts/georchestra \
      --set fqdn=YOURDOMAIN
   ```
   
   **Tip:** For testing, you can use a domain like `georchestra-127-0-1-1.nip.io` (replace with your server's IP).

3. Access your geOrchestra instance at `https://YOURDOMAIN`

## Installation

### Customized Installation

1. Create a custom values file:
   ```bash
   # Download the default values.yaml
   helm show values oci://ghcr.io/georchestra/helm-charts/georchestra > my-values.yaml
   ```

2. Edit `my-values.yaml` to configure:
   - `fqdn`: Your domain name
   - `database`: Database configuration (builtin or external)
   - `ldap`: LDAP/OpenLDAP settings
   - Component-specific settings (enable/disable services, resources, etc.)

3. Install with your custom values:
   ```bash
   helm install georchestra oci://ghcr.io/georchestra/helm-charts/georchestra \
      -f my-values.yaml
   ```

### Upgrade

```bash
helm upgrade georchestra oci://ghcr.io/georchestra/helm-charts/georchestra \
   -f my-values.yaml
```

## Architecture

<details>
<summary>Click to expand architecture details</summary>

### Core Components (Enabled by Default)

- **Gateway** - Modern Spring Cloud Gateway-based security gateway
- **Console** - User and organization management interface
- **GeoServer** - OGC-compliant map and feature server
- **GeoNetwork** - Metadata catalog
- **Elasticsearch** - Search engine for GeoNetwork
- **MapStore** - Web mapping application
- **OpenLDAP** - User directory
- **Datafeeder** - Data upload and publishing tool
- **PostgreSQL** - Database (builtin or external)
- **SMTP** - Email service

### Optional Components (Disabled by Default)

- **Analytics** - Usage analytics (deprecated)
- **CAS** - Legacy authentication server
- **Header** - Legacy header component  
- **Security Proxy** - Legacy security proxy (replaced by Gateway)
- **GeoWebCache** - Standalone tile caching service
- **OGC API Records** - OGC API Records service for GeoNetwork
- **Kibana** - Elasticsearch visualization
- **RabbitMQ** - Message broker

### Infrastructure Components

- **Ingress** - HTTP/HTTPS routing to services
- **Persistent Volumes** - Storage for data directories and databases

</details>

## Configuration

### Data Directory (Datadir)

The chart supports bootstrapping the geOrchestra datadir from a Git repository:

```yaml
georchestra:
  datadir:
    git:
      url: https://github.com/georchestra/datadir.git
      ref: docker-master
      # ssh_secret: my-private-ssh-key  # Optional: for private repos
```

The datadir contains configuration files for all geOrchestra components. An initContainer clones the repository before starting services.

### Storage

Persistent volumes are used for:
- **geonetwork_datadir** - GeoNetwork data (default: 2Gi)
- **gn4_es** - Elasticsearch data (default: 2Gi)
- **geoserver_datadir** - GeoServer configuration (default: 256Mi)
- **geoserver_geodata** - GeoServer data files (default: 2Gi)
- **geoserver_tiles** - GeoServer tile cache (default: 2Gi)
- **mapstore_datadir** - MapStore data (default: 256Mi)
- **openldap_data** - LDAP data (default: 256Mi)
- **openldap_config** - LDAP configuration (default: 1Mi)
- **geowebcache_tiles** - GeoWebCache tile cache (default: 5Gi, if enabled)

Configure storage in your values file:

```yaml
georchestra:
  storage:
    geoserver_datadir:
      size: 1Gi
      # storage_class_name: my-storage-class
      # pv_name: my-existing-pv
      # existingClaim: my-existing-pvc
```

### Database

The chart includes a PostgreSQL database by default, or you can use an external database:

```yaml
database:
  builtin: true  # Set to false for external database
  auth:
    database: georchestra
    username: georchestra
    password: changeme
    # existingSecret: my-db-secret  # Optional: use existing secret
```

It is highly recommended to use an external database in production as the built-in database is only for dev.

Three databases are created: `georchestra`, `geodata`, and `datafeeder`.

### LDAP

Configure LDAP settings:

```yaml
ldap:
  adminPassword: "secret"
  baseDn: "dc=georchestra,dc=org"
  # host: "external-ldap"  # Optional: use external LDAP
```

### RabbitMQ

RabbitMQ can be enabled for event-driven architectures related to Console and Gateway:

```yaml
rabbitmq:
  enabled: true
  auth:
    username: georchestra
    password: changeme
  storage:
    size: 1Gi
```

## Technical Implementation Details

<details>
<summary>Click to expand technical details</summary>

### Health Checks

The chart implements health checks using `livenessProbe` and `startupProbe`:

- **startupProbe**: Allows containers sufficient time to start (typically 5 attempts × 10 seconds)
- **livenessProbe**: Continuously monitors container health (every 10 seconds, 3 failure threshold)

Most services use HTTP-based health checks, while some use TCP socket checks. GeoNetwork has a custom `timeoutSeconds` of 5 seconds due to wro4j cache considerations.

### Update Strategy

Services using persistent volumes use the `Recreate` update strategy instead of `RollingUpdate` to avoid volume mounting conflicts during updates. These services include:

- Elasticsearch (used by GeoNetwork)
- GeoNetwork
- GeoWebCache
- MapStore
- OpenLDAP

Other services (including GeoServer) use the default `RollingUpdate` strategy.

### Resource Management

All components support configurable resource requests and limits via `values.yaml`:

```yaml
resources:
  requests:
    cpu: 1000m
    memory: 2Gi
  limits:
    cpu: 2000m
    memory: 4Gi
```

</details>

## Recommended Resource Allocations

### Test/Development Environment

| Component           | CPU Requests | CPU Limits | RAM Requests | RAM Limits |
|---------------------|--------------|------------|--------------|------------|
| console             | 100m         | -          | 1Gi          | 1Gi        |
| datafeeder          | 100m         | -          | 512Mi        | 512Mi      |
| datafeeder-frontend | 50m          | -          | 128Mi        | 128Mi      |
| geonetwork          | 200m         | 2000m      | 1512Mi       | 1512Mi     |
| ogc-api-records     | 100m         | -          | 1Gi          | 1Gi        |
| elasticsearch       | 200m         | 2000m      | 1512Mi       | 1512Mi     |
| kibana              | 100m         | -          | 1Gi          | 1Gi        |
| geoserver           | 1000m        | 4000m      | 2Gi          | 2Gi        |
| header              | 50m          | -          | 512Mi        | 512Mi      |
| mapstore            | 100m         | -          | 1Gi          | 1Gi        |
| openldap            | 100m         | -          | 1Gi          | 1Gi        |
| gateway             | 500m         | 4000m      | 1Gi          | 1Gi        |
| database (PG)       | 200m         | -          | 512Mi        | 512Mi      |
| smtp                | 50m          | -          | 64Mi         | 64Mi       |

### Production Environment (Low Usage)

| Component           | CPU Requests | CPU Limits | RAM Requests | RAM Limits |
|---------------------|--------------|------------|--------------|------------|
| console             | 500m         | -          | 2Gi          | 2Gi        |
| datafeeder          | 200m         | -          | 2Gi          | 2Gi        |
| datafeeder-frontend | 100m         | -          | 256Mi        | 256Mi      |
| geonetwork          | 2000m        | 4000m      | 3Gi          | 3Gi        |
| ogc-api-records     | 100m         | -          | 2Gi          | 2Gi        |
| elasticsearch       | 1000m        | 2000m      | 4Gi          | 4Gi        |
| kibana              | 500m         | -          | 2Gi          | 2Gi        |
| geoserver           | 2000m        | 4000m      | 4Gi          | 4Gi        |
| header              | 200m         | -          | 1Gi          | 1Gi        |
| mapstore            | 1000m        | -          | 2Gi          | 2Gi        |
| openldap            | 500m         | -          | 2Gi          | 2Gi        |
| gateway             | 2000m        | 4000m      | 3Gi          | 3Gi        |
| database (PG)       | 2000m        | 4000m      | 2Gi          | 2Gi        |
| smtp                | 200m         | -          | 128Mi        | 128Mi      |

**Note:** These are baseline recommendations. Production deployments should be tuned based on actual usage patterns, data volume, and traffic. Key components to monitor and adjust: GeoNetwork, Elasticsearch, GeoServer, Gateway, and the database.

## Additional Resources

- [geOrchestra Documentation](https://docs.georchestra.org)
- [GitHub Repository](https://github.com/georchestra/helm-charts)
- [Issue Tracker](https://github.com/georchestra/helm-charts/issues)
