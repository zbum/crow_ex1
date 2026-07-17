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
  database: "test"

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

- C++17 compatible compiler (GCC 7+, Clang 5+, or MSVC 2019+)
- CMake 3.15 or later
- MySQL client library
- yaml-cpp library

### Install Dependencies (macOS)

```bash
brew install mysql-client yaml-cpp cmake
```

### Install Dependencies (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install build-essential cmake libmysqlclient-dev libyaml-cpp-dev
```

### Build with CMake

#### Quick Build

```bash
# Build with default settings (Release mode)
./build.sh

# Build debug version
./build.sh debug

# Build release version
./build.sh release

# Clean build directories
./build.sh clean
```

#### Manual CMake Build

```bash
# Create build directory
mkdir build && cd build

# Configure
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build . --parallel

# Or use preset
cmake --preset=default
cmake --build --preset=default
```

#### Build Options

```bash
# Configure with options
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTS=ON \
    -DBUILD_BENCHMARKS=ON

# Build specific target
cmake --build . --target crow_ex1

# Build all targets
cmake --build . --target all
```

### Run

```bash
# Default configuration
./build/crow_ex1

# Custom configuration
./build/crow_ex1 config.development.yaml

# From build directory
cd build && ./crow_ex1
```

### Build Types

- **Debug**: Full debugging symbols, no optimization
- **Release**: Full optimization, no debugging symbols
- **RelWithDebInfo**: Optimization with debugging symbols
- **MinSizeRel**: Size optimization

## Database Setup

Create the required database and tables:

```bash
mysql -h 127.0.0.1 -P 3306 -u root -p < create_members_users_tables.sql
```

The script creates the `test` database with the following core tables:

```sql
CREATE DATABASE test;
USE test;

CREATE TABLE members (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gender ENUM('male', 'female') NOT NULL
);

CREATE TABLE users (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    display_name VARCHAR(100),
    role ENUM('user', 'admin') NOT NULL DEFAULT 'user',
    is_active TINYINT(1) NOT NULL DEFAULT 1
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

The project includes comprehensive testing with organized test structure using CMake's CTest framework:

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

#### Using Build Script

```bash
# Run tests after building
./build.sh test

# Run benchmarks after building
./build.sh benchmark
```

#### Using CMake/CTest

```bash
# Build with tests enabled
cmake .. -DBUILD_TESTS=ON -DBUILD_BENCHMARKS=ON
cmake --build .

# Run all tests
ctest --output-on-failure

# Run specific test
ctest -R functional_test

# Run tests in verbose mode
ctest --verbose

# Run tests with parallel execution
ctest --parallel 4
```

#### Using CMake Presets

```bash
# Configure and build with tests
cmake --preset=default
cmake --build --preset=default

# Run tests
ctest --preset=default
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
