<%@ include file="header.jsp" %>
<%
    String code = request.getParameter("code");
    try{
        String sql = "DELETE FROM schedule WHERE code = ?";
        PreparedStatement pstmt = con.prepareStatement(sql);
        int success = pstmt.executeUpdate();
        if(success == 1)
        {   
            response.getWriter().write('success');  
        }
        
    }catch(Exception e){
        e.printStackTrace();
    }
%>
<%@ include file="footer.jsp" %>