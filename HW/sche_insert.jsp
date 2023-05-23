<%@ include file="db_open.jsp" %>
<%@ include file="session_check.jsp" %>
<%! int code = 0; %>
<%
    String name = request.getParameter("name");
    String start = request.getParameter("start");
    String end = request.getParameter("end");
    String dow = request.getParameter("dow");

    try{

        //CHECK NULL INPUT
         if(name.isEmpty()|| start.isEmpty() ||end.isEmpty() ||dow.isEmpty()){             
            System.out.println("Error: Null input exists");
            response.getWriter().write("0");
            return;
        }

        
        //CHECK IMPOSSIBLE START AND END
        if(Integer.parseInt(end) < Integer.parseInt(start)){            
            System.out.println("plz check start is after end time");
            return;
        }

        //CHECK OVERLAPPING SCHEDULE
        String checkSql = "SELECT * FROM schedule WHERE (START <= ? OR  END >= ?) AND dow = ?";
        PreparedStatement checkPstmt = con.prepareStatement(checkSql);
        checkPstmt.setString(1, end);
        checkPstmt.setString(2, start);
        checkPstmt.setString(3, dow);
        ResultSet checkSet = checkPstmt.executeQuery();
        if(checkSet.next()){
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