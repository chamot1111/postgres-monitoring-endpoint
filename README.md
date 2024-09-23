# Postgres Monitoring Endpoint

This project provides a simple HTTP endpoint for monitoring PostgreSQL databases. It allows you to execute predefined monitoring functions and retrieve the results via a GET request.

## Features

- Execute custom monitoring functions on PostgreSQL databases only in the schema `monitoring`
- Basic authentication for securing the endpoint
- Parameterized requests to specify the monitoring function and target database
- JSON responses for easy integration with monitoring tools

## Limitations

- This project does not support TLS connections to PostgreSQL databases.
- However, it can still utilize SCRAM-SHA-256 authentication for secure password-based authentication.
- Ensure that your network configuration provides adequate security for database connections in the absence of TLS.

## Usage

To use this endpoint, make a GET request with the following parameters:

- `monitor`: The name of the monitoring function to execute
- `db`: The name of the database to monitor

The endpoint is secured using Basic Authentication. Use the following credentials:

- Username: `pgm`
- Password: The value of the `PGM_SECRET` environment variable


Example:

```
GET /health?monitor=check_connections&db=PRODUCTION
```

Note: The `db` parameter value must match one of the names declared in the environment variables (e.g., PRODUCTION, STAGING).

### Authentication

The endpoint uses Basic Authentication. Make sure to include the appropriate credentials in your request headers.

### Response Format

The endpoint returns JSON responses with the following structure:

```json
{
  "status": "success",
  "result": [
    // Result of the monitoring function
  ]
}
```

In case of an error:

```json
{
  "status": "error",
  "error": "Error message"
}
```

## Setup

1. Set up environment variables for each database you want to monitor:
   - PGM_DB_HOST_$NAME: PostgreSQL host for the database
   - PGM_DB_PORT_$NAME: PostgreSQL port for the database
   - PGM_DB_DATABASE_$NAME: Database name
   - PGM_DB_USER_$NAME: PostgreSQL user for monitoring
   - PGM_DB_PASSWORD_$NAME: PostgreSQL password for the monitoring user
   Where $NAME is a unique identifier for each database (e.g., PRODUCTION, STAGING).

2. Set the PGM_SECRET environment variable for Basic Authentication.

## Security Considerations

- Always use HTTPS to encrypt traffic to and from this endpoint.
- Implement proper authentication and authorization mechanisms.
- Limit the scope of the PostgreSQL user used for monitoring to only the necessary permissions.
- Regularly review and update the allowed monitoring functions to prevent potential security risks.
## IP Access Restrictions

To enhance security, it's recommended to limit IP addresses that can access this monitoring endpoint:

- Configure your web server (e.g., Nginx, Apache) to restrict access based on IP addresses.
- Use firewall rules (e.g., iptables, ufw) to allow only specific IP ranges.
- If using cloud services, utilize their network security groups or similar features to control inbound traffic.
- For containerized deployments, implement network policies to restrict pod-to-pod communication.

Always keep your allowed IP list up-to-date and use the principle of least privilege when granting access.

## Contributing

Contributions to improve this monitoring endpoint are welcome. Please submit issues and pull requests on the project's repository.
