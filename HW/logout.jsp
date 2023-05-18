<%@ include file="header.jsp" %>
<% 
session.invalidate();
response.sendRedirect("/login.jsp");
%>
<%@ include file="footer.jsp" %>