<%@ include file="header.jsp" %>
<%
    String code = request.getParameter("code");
    try{

        String sql = "DELETE FROM schedule WHERE code = ?";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, code);
        int success = pstmt.executeUpdate();
        if(success != 1){
            return;
        }
        response.getWriter().write("success" + code);  
 
    }catch(Exception e){
        e.printStackTrace();
    }
%>
<%@ include file="footer.jsp" %>