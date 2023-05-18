<%
    String user_id = session.getAttribute("user_id");
    System
    if(user_id == null )
        response.sendRedirect("/login.jsp");
%>