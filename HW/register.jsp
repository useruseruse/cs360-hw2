<%@ include file="header.jsp" %>
<h1>Register page</h1>
<form action="./register_insert.jsp", method="post">
    <label for="id"> ID: 
    <input type="text" name="id"> <br>
    <label for="id"> Password: 
    <input type="password" name="password"> <br>
    <input type="submit">
</form>
<%@ include file="footer.jsp" %>