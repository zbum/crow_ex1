# C++ 컴파일러 설정
CXX = g++
CXXFLAGS = -I./Crow/include -I/opt/homebrew/opt/asio/include -I/opt/homebrew/opt/mysql-client/include -I/opt/homebrew/opt/yaml-cpp/include -std=c++17 -Wall -Wextra
LDFLAGS = -pthread -L/opt/homebrew/opt/mysql-client/lib -L/opt/homebrew/opt/yaml-cpp/lib -lmysqlclient -lyaml-cpp

# Static 링크용 설정 (macOS)
STATIC_CXXFLAGS = -I./Crow/include -I/opt/homebrew/opt/asio/include -I/opt/homebrew/opt/mysql-client/include -I/opt/homebrew/opt/yaml-cpp/include -std=c++17 -Wall -Wextra
STATIC_LDFLAGS = -pthread -L/opt/homebrew/opt/mysql-client/lib -L/opt/homebrew/opt/yaml-cpp/lib -L/opt/homebrew/opt/openssl@3/lib -L/opt/homebrew/opt/zlib/lib -L/opt/homebrew/opt/zstd/lib /opt/homebrew/opt/mysql-client/lib/libmysqlclient.a -lyaml-cpp -lssl -lcrypto -lz -lzstd

# 타겟 실행 파일명
TARGET = crow_ex1
STATIC_TARGET = crow_ex1_static
BENCHMARK_TARGET = benchmark_test

# 소스 파일
SOURCES = src/main.cpp src/router/member_router.cpp src/router/product_router.cpp src/service/member_service.cpp src/service/product_service.cpp src/repository/mysql_member_repository.cpp src/repository/mysql_product_repository.cpp src/config/config.cpp
BENCHMARK_SOURCES = tests/benchmark_test.cpp src/router/member_router.cpp src/router/product_router.cpp src/service/member_service.cpp src/service/product_service.cpp src/repository/mysql_member_repository.cpp src/repository/mysql_product_repository.cpp src/config/config.cpp

# 기본 타겟
all: $(TARGET)

# Static 타겟
static: $(STATIC_TARGET)

# 실행 파일 생성 규칙
$(TARGET): $(SOURCES)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $(TARGET) $(SOURCES)

# Static 링크 실행 파일 생성 규칙
$(STATIC_TARGET): $(SOURCES)
	$(CXX) $(STATIC_CXXFLAGS) $(STATIC_LDFLAGS) -o $(STATIC_TARGET) $(SOURCES)

# 벤치마크 테스트 실행 파일 생성 규칙
$(BENCHMARK_TARGET): $(BENCHMARK_SOURCES)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $(BENCHMARK_TARGET) $(BENCHMARK_SOURCES)

# 실행
run: $(TARGET)
	./$(TARGET)

# Static 실행
run-static: $(STATIC_TARGET)
	./$(STATIC_TARGET)

# 벤치마크 실행
benchmark: $(BENCHMARK_TARGET)
	./$(BENCHMARK_TARGET)

# API 성능 테스트 실행
test-api: $(TARGET)
	@echo "Starting server for API testing..."
	@./$(TARGET) &
	@SERVER_PID=$$!; \
	sleep 2; \
	./tests/test_api_performance.sh; \
	kill $$SERVER_PID 2>/dev/null || true

# 정리
clean:
	rm -f $(TARGET) $(STATIC_TARGET) $(BENCHMARK_TARGET)

# 도움말
help:
	@echo "Crow_ex1 사용 가능한 명령어:"
	@echo "  make              - 프로그램 컴파일 (동적 링크)"
	@echo "  make static       - 프로그램 컴파일 (정적 링크)"
	@echo "  make run          - 프로그램 컴파일 후 실행 (동적 링크)"
	@echo "  make run-static   - 프로그램 컴파일 후 실행 (정적 링크)"
	@echo "  make benchmark    - 성능 벤치마크 테스트 실행"
	@echo "  make test-api     - HTTP API 성능 테스트 실행"
	@echo "  make clean        - 생성된 파일 정리"
	@echo "  make help         - 이 도움말 표시"

.PHONY: all static run run-static benchmark test-api clean help
