const e = require("express");

<%@ include file="db_open.jsp" %>
<%@ include file="session_check.jsp" %>
<%
    var code = 0;
    session = request.getSession();
    System.out.println("inserting schedule session check"+session.isNew());
    String name = request.getParameter("name");
    String start = request.getParameter("start");
    String end = request.getParameter("end");
    String dow = request.getParameter("dow");
    String user_id = session.getAtttribute("user_id");

    try{
        String sql = "INSERT INTO schedule VALUES(?,?,?,?,?)";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, user_id);
        pstmt.setString(2, name);
        pstmt.setString(3, start);
        pstmt.setString(4, end);
        pstmt.setString(5, dow);
        if(pstmt.executeUpdate()){          //if update db successes, return code 
            code+=1;
            protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
                response.setContentType("text/plain"); 
                PrintWriter writer = response.getWriter(); 
                writer.println(code);
            }
        }
    }catch(Exception e){
        e.printStackTrace();
    }

%>
<%@ include file="db_close.jsp" %>