<%@ include file="header.jsp" %>
<%
    String user_id = request.getParameter("id");
    String user_password = request.getParameter("password");

    // your codes here
    String query = "SELECT user_id FROM user WHERE user_id = ?";
    try{
        PreparedStatement pstmt = con.prepareStatement(query);
        pstmt.setString(1,user_id);
        ResultSet rset = pstmt.executeQuery();

        if (rset.next())  // user_name already exists
            response.sendRedirect("/register.jsp");
        else
        {
            String query = "INSERT INTO user VALUES(?, SHA1(?))";
            
            pstmt = con.prepareStatement(query);
            pstmt.setString(1,user_id);
            pstmt.setString(2,user_password);
            pstmt.executeUpdate();

            response.sendRedirect("/login.jsp");
        }
    }catch(Exception e){
        e.printStackTrace();
    }
    
%>
<%@ include file="footer.jsp" %>

