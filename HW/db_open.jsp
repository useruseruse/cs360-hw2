<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>

<%
    Connection con = null;
    String jdbcUrl ="jdbc:mysql://db:3306/HW?characterEncoding=UTF-8&serverTimezone=UTC";
    String dbUser = "dbuser";
    String dbPass = "dbuser1234";
 
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
    } catch(ClassNotFoundException e) { 
        out.println("mysql driver loading error!");
        out.println(e.toString());
        System.out.println("mysql driver loading error!");
        return;
    }
 
    try {
        con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
    } catch(SQLException e) {
        con = null;
        out.println("mysql connection error!");
        out.println(e.toString());
        return;
    }

    request.setCharacterEncoding("UTF-8");
%>