const { response } = require("express");

<%@ include file="db_open.jsp" %>
<%@ include file="session_check.jsp" %>
<%! int code = 0; %>
<%
    String name = request.getParameter("name");
    String start = request.getParameter("start");
    String end = request.getParameter("end");
    String dow = request.getParameter("dow");

    try{

        //CHECK OVERLAPPING SCHEDULE
        String checkSql = "SELECT * FROM schedule WHERE START <= ? AND  END >= ?";
        PreparedStatement pstmt = con.prepareStatement(checkSql);
        pstmt.setInt(1, end);
        pstmt.setInt(2,start);
        ResultSet checkSet = pstmt.executeQuery();
        if(checkSet.next()){
            response.getWriter.write("Error: overlapping time");
            return; 
        }

        //INSERT SCHEDULE
        String sql = "INSERT INTO schedule VALUES(NULL,?,?,?,?,?)";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, user_id);
        pstmt.setString(2, name);
        pstmt.setString(3, start);
        pstmt.setString(4, end);
        pstmt.setString(5, dow);
        int success = pstmt.executeUpdate();
        if(success != 1){
            response.getWriter.write("Error: error at inserting");
            return; 
        }   
        
        // IF SUCCESS, RETURN CODE 
        String getCode = "SELECT code FROM schedule ORDER BY code DESC LIMIT 1";
        Statement stmt = con.createStatement();
        ResultSet rset = stmt.executeQuery(getCode);
        if(rset.next()){
            code = rset.getInt(1);
        }
        response.getWriter().write(Integer.toString(code));  
        
    
    }catch(Exception e){
        e.printStackTrace();
    }

%>
<%@ include file="db_close.jsp" %>