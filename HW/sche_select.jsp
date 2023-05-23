<%@ include file="db_open.jsp" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>
<%@ include file="session_check.jsp" %>
<%
    String search = request.getParameter("query") + "%";

    try{
        JSONArray jsonArray = new JSONArray();

        String sql = "SELECT * FROM schedule WHERE name LIKE ?";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, search );
        ResultSet rset = pstmt.executeQuery();
        while(rset.next()){
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("code", rset.getString(1));
            jsonObject.put("name", rset.getString(3));
            jsonObject.put("start", rset.getString(4));
            jsonObject.put("end", rset.getString(5));
            jsonObject.put("dow", rset.getString(6));
        
            jsonArray.put(jsonObject);
        }

        String jsonString = jsonArray.toString();
        response.setContentType("application/json");
        response.getWriter().write(jsonString);
    }catch(Exception e){
        e.printStackTrace();
    }
%>
<%@ include file="db_close.jsp" %>