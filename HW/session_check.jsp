<%
    Cookie[] Cookies = request.getCookies();
    System.out.println("THIS IS COOKIES" + Cookies);
    
    String func(){
        if(Cookies != null){
        for(Cookie cookie: Cookies){
            if(cookie.getName().equals("user_id")){
                return cookie.getValue();
            }
        }}
        return "";
    };    
    
    String user_id = func();

    System.out.println(user_id);
%>