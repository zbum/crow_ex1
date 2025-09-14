# Crow API Server

A RESTful API server built with Crow C++ framework, featuring configurable database and server settings.

## Features

- **RESTful API**: Member and Product management endpoints
- **Configurable**: YAML-based configuration system
- **Database Support**: MySQL integration
- **Memory Efficient**: Shared repository and service instances

## API Endpoints

### Members
- `GET /members` - Get all members
- `GET /members/{id}` - Get member by ID
- `POST /members` - Create new member
- `PUT /members/{id}` - Update member
- `DELETE /members/{id}` - Delete member

### Products
- `GET /products` - Get all products
- `GET /products/{id}` - Get product by ID
- `POST /products` - Create new product
- `PUT /products/{id}` - Update product
- `DELETE /products/{id}` - Delete product

## Configuration

The server uses YAML configuration files for database and server settings.

### Configuration Files

- `config.yaml` - Default configuration
- `config.development.yaml` - Development environment
- `config.production.yaml` - Production environment

### Configuration Structure

```yaml
# Database Configuration
database:
  host: "127.0.0.1"
  port: 3306
  username: "root"
  password: "test"
  database: "crow_ex1"

# Server Configuration
server:
  host: "0.0.0.0"
  port: 8080
  threads: 10
```

### Running with Configuration

```bash
# Use default config.yaml
./crow_ex1

# Use specific configuration file
./crow_ex1 config.development.yaml
./crow_ex1 config.production.yaml
```

## Building

### Prerequisites

- C++17 compatible compiler
- MySQL client library
- yaml-cpp library

### Install Dependencies (macOS)

```bash
brew install mysql-client yaml-cpp
```

### Compile

```bash
# Dynamic linking (default)
make clean
make

# Static linking (for deployment)
make clean
make static
```

### Run

```bash
# Default configuration
./crow_ex1

# Custom configuration
./crow_ex1 config.development.yaml

# Static build
./crow_ex1_static config.yaml
```

### Static Build

The static build (`crow_ex1_static`) includes most dependencies statically linked, making it more portable across different systems. However, some system libraries (OpenSSL, zlib, zstd, yaml-cpp) may still be required on the target system.

**File sizes:**
- Dynamic build: ~300KB
- Static build: ~9.9MB

## Database Setup

Create the required database and tables:

```sql
CREATE DATABASE crow_ex1;
USE crow_ex1;

CREATE TABLE members (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gender ENUM('male', 'female') NOT NULL
);

CREATE TABLE products (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price INT NOT NULL,
    category VARCHAR(50) NOT NULL
);
```

## Example Usage

### Create a Member

```bash
curl -X POST http://localhost:8080/members \
  -H "Content-Type: application/json" \
  -d '{"id":"user1","name":"John Doe","gender":"male"}'
```

### Get All Members

```bash
curl http://localhost:8080/members
```

### Create a Product

```bash
curl -X POST http://localhost:8080/products \
  -H "Content-Type: application/json" \
  -d '{"id":"prod1","name":"Laptop","price":1500000,"category":"Electronics"}'
```

### Get All Products

```bash
curl http://localhost:8080/products
```

## Testing

The project includes comprehensive testing with organized test structure:

### Test Directory Structure

```
tests/
├── bench/                    # Performance tests
│   ├── benchmark_test.cpp   # C++ performance benchmarks
│   └── test_api_performance.sh # HTTP API performance tests
└── unit/                    # Functional tests
    ├── functional_test.cpp  # Core functionality tests
    ├── test_*.cpp          # Individual unit tests
    └── test_helper.h       # Test utilities
```

### Running Tests

```bash
# Functional tests (unit tests)
make test

# Performance benchmarks
make benchmark

# HTTP API performance tests
make test-api

# Clean test artifacts
make clean
```

### Test Types

- **Unit Tests**: Test individual components and functions
- **Performance Tests**: Measure execution time and resource usage
- **API Tests**: Test HTTP endpoints and response times

## Architecture

The application follows a layered architecture:

- **Router Layer**: Handles HTTP requests and responses
- **Service Layer**: Business logic and validation
- **Repository Layer**: Database operations
- **Config Layer**: Configuration management

All layers use dependency injection for better testability and maintainability.
