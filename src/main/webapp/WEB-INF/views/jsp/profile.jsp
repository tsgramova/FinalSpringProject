<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
 <%@ page errorPage="errorPage.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Profile</title>
</head>

<body>
<c:set var="usersprofile" scope="session" value="${usersprofile.username }"></c:set>

  <jsp:include page="header2.jsp" />
        <div id="head4">
          <div class="container">
          
        
<!-- view picture -->
                  <img class="profilepic" src="/MyTravelerProject/image/${usersprofile.username }" align="middle" height=300 width="300"> <br>

<script src="https://code.jquery.com/jquery-1.7.1.js" type="text/javascript"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.0/jquery.min.js"></script>
<script>
$(document).ready(function(){
    $("#postShow").click(function(){
        $("#wall").html(document.getElementById("printedPosts").innerHTML);
    });
    $("#followersShow").click(function(){
        $("#wall").html(document.getElementById("printedFollowers").innerHTML);
    });
    $("#followingShow").click(function(){
        $("#wall").html(document.getElementById("printedFollowing").innerHTML);
    });
});
</script>
<script>
$(document).ready(function(){
	   
	$("#btn").click(function(e){
		e.preventDefault();
	    
	    if($("#btn").hasClass('following')){

	        //$.ajax(); Do Unfollow
	        $.post("/MyTravelerProject/unfollow");
	        $("#btn").removeClass('following');
	        $("#btn").removeClass('unfollow');
	        $("#btn").text('Follow');
	    } else {

	        // $.ajax(); Do Follow
	        $.post("/MyTravelerProject/follow");
	        $("#btn").removeClass('following');
	        $("#btn").text('Following');
	    }
	    
	});
	$("#btn1").click(function(e){
		e.preventDefault();
		$.post("/MyTravelerProject/unfollow");
		
		
	    if($("#btn1").hasClass('liked')){

	        //$.ajax(); Do Dislike
	        $.post("/MyTravelerProject/dislikePost");
	        $("#btn1").removeClass('liked');
	        $("#btn1").addClass('dislike');
	        $("#btn1").text('Unfollow');
	    } else {

	        // $.ajax(); Do Like
	        
	        $.post("/MyTravelerProject/likePost");
	        $("#btn1").addClass('liked');
	        $("#btn1").text('Follow');
	    }
	    
	});
	$( "div.container" )
	  .mouseover(function() {
		  if($("#btn").hasClass('following')){
		  $("#btn").addClass('unfollow');
			$("#btn").text('Unfollow');
		  }
	  })
	  .mouseout(function() {
		  if($("#btn").hasClass('following')){
		  $("#btn").removeClass('unfollow');
			$("#btn").text('Following');
		  }
	  });
	
});

</script>



<!-- print username, first, last, email -->

	<h2 class="lead"><c:out value="${ usersprofile.username }"></c:out>
	</h2>
	<c:if test="${sessionScope.username !=null && sessionScope.username != usersprofile.username && !isFollowing}">
		<div id = "btn" >
	   	 	<button class="btn followButton" rel="6">Follow</button>
		</div>
	</c:if>
	<c:if test="${sessionScope.username !=null && sessionScope.username != usersprofile.username && isFollowing}">
		<div id = "btn1" >
	   	 	<button class="btn followButton" rel="6">Following</button>
		</div>
	</c:if>
	<p> <font size="5" face="Book Antiqua" color="black" > 
		First name: 	
              
					<c:out value="${ usersprofile.first_name }"></c:out> <br>
       Last name:
					<c:out value="${ usersprofile.last_name }"></c:out> <br>
       Email:
					<c:out value="${ usersprofile.email }"></c:out> <br>
                    </font></p>
<!-- nqkyde vsqsno butoni POSTS FOLLOWING FOLLOWERS -->


<div id="wall" align="center"></div>
<button class="btn btn-action btn-lg" id="postShow">Posts</button>
<button class="btn btn-action btn-lg" id="followersShow">Followers</button>
<button class = "btn btn-action btn-lg" id="followingShow">Following</button>
<!-- No posts/no followers !!!! -->

<div hidden id="printedPosts" align="center">
			<font style= "oblique" size="5" style="color:black;">
		<u><c:out value="${usersprofile.username}' posts:"></c:out></u>
		<c:forEach var="post" items="${usersprofile.posts}">
		<div class="postlook" align="center">
			 <a  style="color:blue" href = "post/<c:url value="${post.postId}"/> " >${ post.postName }</a>  posted on ${post.date} <br><br><br>
                        <img src="picture/${post.postId}" height="100" ><br>
                       ${ post.likes } likes
			  
	            
		</div><br>
	</c:forEach>
	  </font>
</div>

<div hidden id="printedFollowers" align="center">
<font style= "oblique" size="5" style="color:black;">
		<u><c:out value="${usersprofile.username}'s followers:"></c:out></u>
	<c:forEach var="string" items="${usersprofile.followers}">
		<div class="postlook" align="center">
				<!-- show small Picture -->
				<img class="img-circle-users" src="/MyTravelerProject/image/<c:url value="${ string }"></c:url>" height=30 width="30"/> <br>
				<!-- linka kym profile page na user-a nqmam ideq dali trqbva da e taka -->
				<a href = "/MyTravelerProject/user/<c:out value="${string}"/> " >${ string }</a><br>
				
				
		</div><br>
	</c:forEach>
	</font>
</div>


<div hidden id="printedFollowing" align="center">
<font style= "oblique" size="5" style="color:black;">
		<u><c:out value="${usersprofile.username} is following:"></c:out></u>
	<c:forEach var="string" items="${usersprofile.following}">
		<div class="postlook" align="center">
				<!-- show small Picture -->
				<img class="img-circle-users" src="/MyTravelerProject/image/<c:url value="${ string }"></c:url>" height=30 width="30"/> <br>
				<!-- linka kym profile page na user-a nqmam ideq dali trqbva da e taka -->
				<a href = "/MyTravelerProject/user/<c:out value="${string}"/> " >${ string }</a><br>
				
				
		</div><br>
	</c:forEach>
	</font>
	</div>
	</div>
	</div>
 
</body>
</html>