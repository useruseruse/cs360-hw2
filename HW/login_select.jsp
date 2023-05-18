<%@ include file="header.jsp" %>
<%
    String user_id = request.getParameter("id");
    String userPassword = request.getParameter("password");

   
    try{
        String sql = "SELECT user_id FROM user WHERE user_id = ? AND user_password = SHA1(?)";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, user_id); 
        pstmt.setString(2, userPassword);
        ResultSet rset = pstmt.executeQuery();

        System.out.println(session);
        if(rset.next() && session == null){    
            session.setAttribute("user_id", user_id);
            response.sendRedirect("/index.jsp");
        }
        else{
            response.sendRedirect("/login.jsp");
        }
    }catch(Exception e){
        e.printStackTrace();
    }
%>
<%@ include file="footer.jsp" %>