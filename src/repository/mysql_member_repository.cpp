#include "mysql_member_repository.h"

MySQLMemberRepository::MySQLMemberRepository(std::shared_ptr<MySQLConnectionPool> pool) : connectionPool(pool) {
}

std::vector<crow::json::wvalue> MySQLMemberRepository::getAllMembers() {
    std::vector<crow::json::wvalue> members_list;
    auto mysql = connectionPool->getConnection();
    
    if (mysql_query(mysql.get(), "SELECT id, name, gender FROM members")) {
        throw std::runtime_error(std::string("Error querying members: ") + mysql_error(mysql.get()));
    }
    
    MYSQL_RES* result = mysql_store_result(mysql.get());
    if (result == NULL) {
        throw std::runtime_error(std::string("Error storing members result: ") + mysql_error(mysql.get()));
    }
    
    MYSQL_ROW row;
    while ((row = mysql_fetch_row(result)) != NULL) {
        crow::json::wvalue member_obj;
        member_obj["id"] = std::string(row[0]);
        member_obj["name"] = std::string(row[1]);
        member_obj["gender"] = std::string(row[2]);
        members_list.push_back(member_obj);
    }
    
    mysql_free_result(result);
    return members_list;
}

crow::json::wvalue MySQLMemberRepository::getMemberById(const std::string& id) {
    std::string query = "SELECT id, name, gender FROM members WHERE id = '" + id + "'";
    auto mysql = connectionPool->getConnection();
    
    if (mysql_query(mysql.get(), query.c_str())) {
        throw std::runtime_error(std::string("Error querying member: ") + mysql_error(mysql.get()));
    }
    
    MYSQL_RES* result = mysql_store_result(mysql.get());
    if (result == NULL) {
        throw std::runtime_error(std::string("Error storing member result: ") + mysql_error(mysql.get()));
    }
    
    MYSQL_ROW row = mysql_fetch_row(result);
    if (row != NULL) {
        crow::json::wvalue member_obj;
        member_obj["id"] = std::string(row[0]);
        member_obj["name"] = std::string(row[1]);
        member_obj["gender"] = std::string(row[2]);
        mysql_free_result(result);
        return member_obj;
    }
    
    mysql_free_result(result);
    return crow::json::wvalue();
}

bool MySQLMemberRepository::memberExists(const std::string& id) {
    std::string query = "SELECT COUNT(*) FROM members WHERE id = '" + id + "'";
    auto mysql = connectionPool->getConnection();
    
    if (mysql_query(mysql.get(), query.c_str())) {
        throw std::runtime_error(std::string("Error checking member existence: ") + mysql_error(mysql.get()));
    }
    
    MYSQL_RES* result = mysql_store_result(mysql.get());
    if (result == NULL) {
        throw std::runtime_error(std::string("Error storing member existence result: ") + mysql_error(mysql.get()));
    }
    
    MYSQL_ROW row = mysql_fetch_row(result);
    bool exists = false;
    if (row != NULL) {
        exists = std::stoi(row[0]) > 0;
    }
    
    mysql_free_result(result);
    return exists;
}

bool MySQLMemberRepository::addMember(const std::string& id, const crow::json::wvalue& member) {
    std::string name = std::string(member["name"].dump()).substr(1, std::string(member["name"].dump()).length() - 2);
    std::string gender = std::string(member["gender"].dump()).substr(1, std::string(member["gender"].dump()).length() - 2);
    
    std::string query = "INSERT INTO members (id, name, gender) VALUES ('" + id + "', '" + name + "', '" + gender + "')";
    auto mysql = connectionPool->getConnection();
    
    if (mysql_query(mysql.get(), query.c_str())) {
        if (mysql_errno(mysql.get()) == 1062) {
            throw DuplicateMemberError(std::string("Member already exists: ") + mysql_error(mysql.get()));
        }
        throw std::runtime_error(std::string("Error adding member: ") + mysql_error(mysql.get()));
    }
    return mysql_affected_rows(mysql.get()) == 1;
}

bool MySQLMemberRepository::updateMember(const std::string& id, const crow::json::wvalue& member) {
    std::string name = std::string(member["name"].dump()).substr(1, std::string(member["name"].dump()).length() - 2);
    std::string gender = std::string(member["gender"].dump()).substr(1, std::string(member["gender"].dump()).length() - 2);
    
    std::string query = "UPDATE members SET name = '" + name + "', gender = '" + gender + "' WHERE id = '" + id + "'";
    auto mysql = connectionPool->getConnection();
    
    if (mysql_query(mysql.get(), query.c_str())) {
        throw std::runtime_error(std::string("Error updating member: ") + mysql_error(mysql.get()));
    }
    return mysql_affected_rows(mysql.get()) > 0;
}

bool MySQLMemberRepository::deleteMember(const std::string& id) {
    std::string query = "DELETE FROM members WHERE id = '" + id + "'";
    auto mysql = connectionPool->getConnection();
    
    if (mysql_query(mysql.get(), query.c_str())) {
        throw std::runtime_error(std::string("Error deleting member: ") + mysql_error(mysql.get()));
    }
    return mysql_affected_rows(mysql.get()) > 0;
}
