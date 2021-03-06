<%@page import="java.util.Map.Entry"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.example.model.dbModel.CategoryDAO"%>
<%@ page language="java" contentType="text/html; charset=utf-8"
   pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="errorPage.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
      <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
      <title>Add new post</title>
      <style>
         /* Always set the map height explicitly to define the size of the div
         * element that contains the map. */
         #map {
         height: 2000%;
         width:80%;
         }
         /* Optional: Makes the sample page fill the window. */
         html, body {
         height: 100%;
         margin: 0;
         padding: 0;
         }
      </style>
   </head>
   <body class="home">
      <jsp:include page="header2.jsp" />
    <div id="head6">
          <div class="container">
           <div class="row">
			<div id="map"></div>
   		   <c:if test="${sessionScope.username ==null }">
   		   <c:set var="url" scope="session" value="addPost"></c:set>
         <c:redirect url= "login"></c:redirect>
      </c:if>
            <div id="map"></div>
      
      <font face="Bradley Hand ITC" size="4" style="color:black;">${ errorMsg}</font>
      <input id="pac-input" class="controls" type="text" placeholder="Search Box" >
        <div  class = "basic-grey"id="form">
         <form action="addPost" method="post" enctype="multipart/form-data">
            <p>
               <font size="4" face="verdana" color="black" >
               <label style="color:lightgrey">Share your experience</label>
               </br>
                  <label for= "postname" >Post name:</label>
                  <input type="text" value="${ postname }" name="postname" placeholder="Add name"  maxlength="30" required></br>
                  <label for="postdescription">Post description:</label>
                  <textarea onkeyup="auto_grow(this)" name="postdescription" value="${postdescription }" placeholder="Add description" maxlength="1000" required></textarea>
                  
                  <label for="destination">Destination name: </label> <input  type="text" value="${ destinationname }" name="destinationname" placeholder="Add destination" maxlength="30" required></br>
                
                  <input id="longitude" hidden type="text" value="${ longitude }" name="longitude">
                  <input id="latitude" hidden type="text" value="${latitude}" name="latitude" >
                   <label for="hashtags">  Enter key words separated by spaces: </label> <input  type="text" value="${ hashtags }" name="hashtags" placeholder="Add tags" ></br>
                   <label for="category"> Categories:  </label>
                  <select name = "category">
                     <c:forEach var="category" items="${CategoryDAO.getInstance().categories}">
                        <option value="${category.name}">
                           <c:out value="${category.name}"></c:out>
                        </option>
                     </c:forEach>
                  </select>
                  <br>
                  <label for="photo"> Select picture:  </label>
                  <input  type="file" name="picture">
                  <label for="video"> Select video:  </label>
                  <input  type="file" name="video"  ><br>
               </font>
            </p>
            <input class="btn" type="submit" value = "Add post"></br>
         </form>
      </div>
      <input hidden id="pac-input" class="controls" type="text" placeholder="Search Box">
      </div>
      </div>
      </div>
      <script>
         // This example adds a search box to a map, using the Google Place Autocomplete
         // feature. People can enter geographical searches. The search box will return a
         // pick list containing a mix of places and predicted search terms.
         
         // This example requires the Places library. Include the libraries=places
         // parameter when you first load the API. For example:
         // <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places">
         
         function auto_grow(element) {
         element.style.height = "5px";
         element.style.height = (element.scrollHeight)+"px";
         }
         function initAutocomplete() {
           var map = new google.maps.Map(document.getElementById('map'), {
             center: {lat: 42.69, lng: 23.32},
             zoom: 10,
             mapTypeId: 'roadmap'
           });
         
           var marker;
           var infowindow;
           var messagewindow;
         
           // Create the search box and link it to the UI element.
           var input = document.getElementById('pac-input');
           var searchBox = new google.maps.places.SearchBox(input);
           map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);
         
           // Bias the SearchBox results towards current map's viewport.
           map.addListener('bounds_changed', function() {
             searchBox.setBounds(map.getBounds());
           });
           
           infowindow = new google.maps.InfoWindow({
               content: document.getElementById('form')
             })
         
             messagewindow = new google.maps.InfoWindow({
               content: document.getElementById('message')
             });
         
             google.maps.event.addListener(map, 'click', function(event) {
             	
            	 if (marker && marker.setMap) {
            		    marker.setMap(null);
            		  }
               marker = new google.maps.Marker({
                 position: event.latLng,
                 map: map
               });
               document.getElementById('latitude').value = event.latLng.lat();
               document.getElementById('longitude').value = event.latLng.lng();
         	  infowindow.open(map, marker);
         
         
         
               google.maps.event.addListener(marker, 'click', function() {
             	  document.getElementById('latitude').value = event.latLng.lat();
                   document.getElementById('longitude').value = event.latLng.lng();
             	  infowindow.open(map, marker);
                 
               });
               
               
             });
         
           var markers = [];
           // Listen for the event fired when the user selects a prediction and retrieve
           // more details for that place.
           searchBox.addListener('places_changed', function() {
             var places = searchBox.getPlaces();
         
             if (places.length == 0) {
               return;
             }
         
             // Clear out the old markers.
             markers.forEach(function(marker) {
               marker.setMap(null);
             });
             markers = [];
         
             // For each place, get the icon, name and location.
             var bounds = new google.maps.LatLngBounds();
             places.forEach(function(place) {
               if (!place.geometry) {
                 console.log("Returned place contains no geometry");
                 return;
               }
               var icon = {
                 url: place.icon,
                 size: new google.maps.Size(1, 1),
                 origin: new google.maps.Point(0, 0),
                 anchor: new google.maps.Point(17, 34),
                 scaledSize: new google.maps.Size(25, 25)
               };
         
               // Create a marker for each place.
               markers.push(new google.maps.Marker({
                 map: map,
                 icon: icon,
                 title: place.name,
                 position: place.geometry.location
               }));
         
               if (place.geometry.viewport) {
                 // Only geocodes have viewport.
                 bounds.union(place.geometry.viewport);
               } else {
                 bounds.extend(place.geometry.location);
               }
             });
             map.fitBounds(bounds);
           });
         }
         
      </script>
      <script async defer
         src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBN0sPhqPEf8YKqPYO862QcMihJmO0xb5s&callback=initMap"></script>
      <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBN0sPhqPEf8YKqPYO862QcMihJmO0xb5s&libraries=places&callback=initAutocomplete"
         async defer></script>
   </body>
</html>