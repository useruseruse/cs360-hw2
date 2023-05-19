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
        HttpSession userSession = request.getSession(false);        //기존 session이 있었으면, 그 session을 반환하고, 없었을 경우 null을 반환 
        

        if(userSession.getAttribute("user_id") != null){                // 아직 세션이 만료되지  않은 경우, 바로 index 페이지로 다이렉팅.
            System.out.println(userSession.getAttribute("user_id"));
            response.sendRedirect("/session_check.jsp");
        }
        else if(rset.next()){                                           //기존 session이 없고, 로그인에 성공할 경우.
            userSession.setAttribute("user_id", user_id);
            System.out.println(userSession.getAttribute("user_id"));
            response.sendRedirect("/session_check.jsp");
        }
        else{
            response.sendRedirect("/login.jsp");
       }
    }catch(Exception e){
        e.printStackTrace();
    }
%>
<%@ include file="footer.jsp" %>