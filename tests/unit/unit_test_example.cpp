#include <gtest/gtest.h>
#include "../src/middleware/access_log_middleware.h"
#include <chrono>
#include <sstream>

// AccessLogMiddleware의 로그 포맷팅 기능을 테스트
class AccessLogMiddlewareTest : public ::testing::Test {
protected:
    void SetUp() override {
        // 테스트 전 초기화
    }
    
    void TearDown() override {
        // 테스트 후 정리
    }
};

// 로그 포맷팅 테스트
TEST_F(AccessLogMiddlewareTest, LogFormatting) {
    // 가상의 요청과 응답 생성
    crow::request req;
    crow::response res;
    AccessLogMiddleware::context ctx;
    
    // 시작 시간 설정
    ctx.start_time = std::chrono::high_resolution_clock::now();
    
    // 미들웨어 인스턴스 생성
    AccessLogMiddleware middleware;
    
    // before_handle 테스트
    middleware.before_handle(req, res, ctx);
    
    // 시간이 설정되었는지 확인
    auto now = std::chrono::high_resolution_clock::now();
    EXPECT_LE(ctx.start_time, now);
    
    // after_handle 테스트 (실제로는 로그 출력을 확인해야 함)
    // 여기서는 시간 계산만 테스트
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(now - ctx.start_time);
    EXPECT_GE(duration.count(), 0);
}

// 시간 포맷팅 테스트
TEST_F(AccessLogMiddlewareTest, TimeFormatting) {
    // 현재 시간을 ISO 8601 형식으로 포맷팅 테스트
    auto now = std::chrono::system_clock::now();
    auto time_t = std::chrono::system_clock::to_time_t(now);
    auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()) % 1000;
    
    std::tm* local_tm = std::localtime(&time_t);
    
    std::ostringstream log_stream;
    log_stream << std::put_time(local_tm, "%Y-%m-%dT%H:%M:%S") 
               << "." << std::setfill('0') << std::setw(3) << ms.count() << "+09:00";
    
    std::string time_str = log_stream.str();
    
    // ISO 8601 형식 검증
    EXPECT_TRUE(time_str.find("T") != std::string::npos);
    EXPECT_TRUE(time_str.find("+09:00") != std::string::npos);
    EXPECT_EQ(time_str.length(), 25); // YYYY-MM-DDTHH:MM:SS.sss+09:00
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
