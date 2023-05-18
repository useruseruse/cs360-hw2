<%@ include file="db_open.jsp" %>

<% 
Statement stmt = con.createStatement();

String query = "DROP TABLE IF EXISTS registration";
stmt.executeUpdate(query);

query = "DROP TABLE IF EXISTS schedule";
stmt.executeUpdate(query);

query = "DROP TABLE IF EXISTS user";
stmt.executeUpdate(query);


query = "CREATE TABLE user ("+
                "user_id VARCHAR(200)," +
                "user_password VARCHAR(200)," +
                "PRIMARY KEY (user_id))";
                
stmt.executeUpdate(query);

query = "CREATE TABLE schedule ("+
                "code INT AUTO_INCREMENT," +
                "user_id VARCHAR(200)," +
                "name VARCHAR(200)," +
                "start INT," +
                "end INT," +
                "dow VARCHAR(3)," +
                "PRIMARY KEY (code)," +
                "FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE)";

stmt.executeUpdate(query);

%>

<%@ include file="db_close.jsp" %>