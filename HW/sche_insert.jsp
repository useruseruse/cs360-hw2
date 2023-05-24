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
        System.out.println("Inserting"+ user_id + ":    "+ start + "~" + end + dow);
        String checkSql = "SELECT * FROM schedule WHERE dow =?  AND NOT( END <= ? OR START >= ?) AND user_id =?";
        PreparedStatement checkPstmt = con.prepareStatement(checkSql);
        checkPstmt.setString(1, dow);
        checkPstmt.setString(2, start);
        checkPstmt.setString(3, end);
        checkPstmt.setString(4, user_id);
    

        ResultSet checkSet = checkPstmt.executeQuery();
        if(checkSet.next()){
            System.out.println("failed because of" + checkSet.getString(1)+ checkSet.getString(2)+ ":   " +checkSet.getString(4) + checkSet.getString(5) + checkSet.getString(6) );
        
            System.out.println("Error: overlapping time");
            response.getWriter().write("0");
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
            System.out.println("Error: error at inserting");
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