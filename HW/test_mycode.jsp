
<%@ page import="java.io.*" %>

<%
    ProcessBuilder pb = new ProcessBuilder("pkill", "chrome");
    Process p = pb.start();
    p.waitFor();
    pb = new ProcessBuilder("python3", "/usr/src/python/tester.py");
    p = pb.start();
    BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
    out.println(in.readLine());
    out.println("<br>");
    out.println(in.readLine());
    p.waitFor();
%>