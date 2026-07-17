#pragma once

#include "crow.h"
#include <mysql/mysql.h>
#include <stdexcept>
#include <string>
#include <vector>
#include <memory>
#include "../config/config.h"
#include "mysql_connection_pool.h"

class DuplicateMemberError : public std::runtime_error {
public:
    explicit DuplicateMemberError(const std::string& message) : std::runtime_error(message) {}
};

class MySQLMemberRepository {
private:
    std::shared_ptr<MySQLConnectionPool> connectionPool;

public:
    MySQLMemberRepository(std::shared_ptr<MySQLConnectionPool> pool);
    ~MySQLMemberRepository() = default;
    
    // 모든 멤버 조회
    std::vector<crow::json::wvalue> getAllMembers();
    
    // ID로 멤버 조회
    crow::json::wvalue getMemberById(const std::string& id);
    
    // 멤버 존재 여부 확인
    bool memberExists(const std::string& id);
    
    // 멤버 추가
    bool addMember(const std::string& id, const crow::json::wvalue& member);
    
    // 멤버 업데이트
    bool updateMember(const std::string& id, const crow::json::wvalue& member);
    
    // 멤버 삭제
    bool deleteMember(const std::string& id);
};
