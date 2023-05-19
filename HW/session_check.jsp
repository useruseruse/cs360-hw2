<%
    String user_id =  userSession.getAttribute("user_id").toString();
    if(user_id == null )
        response.sendRedirect("/login.jsp");
%>