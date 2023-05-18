<%@ include file="db_open.jsp" %>
<%@ page import="org.json.simple.JSONArray" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ include file="session_check.jsp" %>
<%
    String search = request.getParameter("search");
    // your codes here
%>
<%@ include file="db_close.jsp" %>