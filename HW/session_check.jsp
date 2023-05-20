<%
    session = request.getSession();
    String user_id = (String)session.getAttribute("user_id");
    if(user_id == null){
        response.sendRedirect("/login.jsp");
    }
%>