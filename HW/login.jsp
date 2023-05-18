<%@ include file="header.jsp" %>
<h1>Login page</h1>
<form action="./login_select.jsp", method="post">
    <label for="id"> ID: 
    <input type="text" name="id"> <br>
    <label for="id"> Password: 
    <input type="password" name="password"> <br>
    <input type="submit">
</form>
<br>
<a href="/register.jsp">Register</a>
<%@ include file="footer.jsp" %>