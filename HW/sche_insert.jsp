<%@ include file="db_open.jsp" %>
<%@ include file="session_check.jsp" %>
<%
    String start = request.getParameter("start");
    String end = request.getParameter("end");
    String name = request.getParameter("name");
    String dow = request.getParameter("dow");

    // your codes here
%>
<%@ include file="db_close.jsp" %>