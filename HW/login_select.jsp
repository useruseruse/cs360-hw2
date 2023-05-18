<%@ include file="header.jsp" %>
<%
    String user_id = request.getParameter("id");
    String userPassword = request.getParameter("password");

    // your codes here
    
    response.sendRedirect("/index.jsp");
%>
<%@ include file="footer.jsp" %>