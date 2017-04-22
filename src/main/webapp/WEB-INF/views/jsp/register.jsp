<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
 <%@ page errorPage="errorPage.jsp"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Register</title>
</head>
<body>
  <jsp:include page="header2.jsp" />
        <br>
        <br>
        <br><br><br><br><br><br><br><br>
<h2>Please register a new account</h2>
<h5 id = "error">${ errorMsg}</h5>
<form action="register" method="post">
Username: <input type="text" value="${ username }" name="username" required></br>
Email: <input type="text"  value="${ email }" name="email" required></br>
First Name: <input type="text" value="${ firstname }" name="firstname" required></br>
Family Name: <input type="text" value="${ lastname }" name="lastname" required></br>
Password: <input type="password" placeholder="enter password" name="password" required></br>
<input type="submit" value = "Register"></br>
</form>
<a href="login">Already a registered user? Login here.</a>
</body>
</html>