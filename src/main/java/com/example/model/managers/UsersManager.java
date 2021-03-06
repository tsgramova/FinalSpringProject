package com.example.model.managers;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import com.example.model.dbModel.DBManager;
import com.example.model.dbModel.UserDAO;
import com.example.model.InvalidInputException;
import com.example.model.MailSender;
import com.example.model.Post;
import com.example.model.User;

public class UsersManager {
	//concurrenthashmap because a lot of threads can use it
	  private ConcurrentHashMap<String, User> registeredUsers; //username--> user
	  private static UsersManager instance=new UsersManager();
	  private UsersManager() {
		registeredUsers = new ConcurrentHashMap<>();
	   try {
		   Set<User> users = UserDAO.getInstance().getAllUsers();
		   for (User u : users) {
			   registeredUsers.put(u.getUsername(), u);
		   }
		} catch (SQLException e1) {
			e1.printStackTrace();
		}
	    
	 }
	  
	  public static synchronized UsersManager getInstance() {
	    return instance;
	  }
	  
	  public Map<String, User> getRegisteredUsers() {
		return Collections.unmodifiableMap(registeredUsers);
	}
	  
	  public boolean validateLogin(String username, String password) {
	    if ( !registeredUsers.containsKey(username)) { //if the username doesn't exist return false
	      return false;
	    }
	    
	    //return if user's password matches the given password 
	    return (registeredUsers.get(username)).getPassword().equals(password);
	  }
	  
	 
	  
	  public boolean validateRegistration(String username, String password, String firstName, String lastName, String email) {
				if(username == null || username.isEmpty() || registeredUsers.contains(username)) {
					return false;
				}
				if(firstName == null || firstName.isEmpty()) {
					return false;
				}
				if(lastName == null || lastName.isEmpty()) {
					return false;
				}
				if (!validateEmailAddress(email)) {
					return false;
				}
				
				if(!validatePassword(password)){
					return false;
				}
				
		  return true;
	  } 
	  
	  public void register(String username, String password, String firstName, String lastName, String email) throws SQLException {
	    User user;
		try {
			user = new User(username, UsersManager.getInstance().hashPassword(password), firstName, lastName, email);
			 registeredUsers.put(username, user); //put user in collection
			 UserDAO.getInstance().saveUser(user); //save user in DB
		} catch (InvalidInputException e) {
			e.printStackTrace();
		}
	  }
	  
	  public void delete(User u) throws Exception  {
		  Connection con = DBManager.getInstance().getConnection();
		  try {
			con.setAutoCommit(false);
			registeredUsers.remove(u);
			UserDAO.getInstance().deleteUser(u);
			if(!u.getPosts().isEmpty()) {
				for(Post p: u.getPosts()) {
					PostManager.getInstance().deletePost(p);
				}
			}
			con.commit();
		} catch (SQLException e) {
			try {
				con.rollback();
			} catch (SQLException e1) {
				e1.printStackTrace();
			}
			e.printStackTrace();
		} 
		  finally {
			  try {
				con.setAutoCommit(true);
			} catch (SQLException e) {
				e.printStackTrace();
			}
		  }
		 
	  }
	  
	  //update user's information by given parameters.. 
	  public void updateUser(User u) throws SQLException {
		  //some validations of values for the fields to be changed
		  UserDAO.getInstance().updateUser(u);
	  }
	  
	  public boolean validatePassword (String password) {
			boolean upperCaseLetter = false; 
			boolean lowerCaseLetter = false;
			boolean digit = false;
			if(password.length() < 5 || password.length() > 15) { 
				return false;
			}
			for (int i = 0; i < password.length(); i++) {
				if (password.charAt(i) >= 'A' && password.charAt(i) <= 'Z') {
					upperCaseLetter = true;
					continue;
				}
				if (password.charAt(i) >= 'a' && password.charAt(i) <= 'z' ) { 
					lowerCaseLetter = true;
					continue;
				}
				if (password.charAt(i) >= '0' && password.charAt(i) <= '9'){ 
					digit = true;
					continue;
				}
				if (upperCaseLetter && lowerCaseLetter && digit) { 
					break;
				}
			}
			return (upperCaseLetter && lowerCaseLetter && digit); 
		}
	  
	  public String hashPassword(String password){
		  String passwordToHash = password;
	        String generatedPassword = null;
	        try {
	            // Create MessageDigest instance for MD5
	            MessageDigest md = MessageDigest.getInstance("MD5");
	            //Add password bytes to digest
	            md.update(passwordToHash.getBytes());
	            //Get the hash's bytes 
	            byte[] bytes = md.digest();
	            //This bytes[] has bytes in decimal format;
	            //Convert it to hexadecimal format
	            StringBuilder sb = new StringBuilder();
	            for(int i=0; i< bytes.length ;i++)
	            {
	                sb.append(Integer.toString((bytes[i] & 0xff) + 0x100, 16).substring(1));
	            }
	            //Get complete hashed password in hex format
	            generatedPassword = sb.toString();
	        } 
	        catch (NoSuchAlgorithmException e) 
	        {
	            e.printStackTrace();
	        }
	        System.out.println(generatedPassword);
	    
			return generatedPassword;
		}

		public boolean validateEmailAddress(String email) {
			for(Entry<String, User> user : registeredUsers.entrySet()) {
				if(user.getValue().getEmail().equals(email)) {
					return false;
				}
			}
	      String ePattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\])|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$";
	      java.util.regex.Pattern p = java.util.regex.Pattern.compile(ePattern);
	      java.util.regex.Matcher m = p.matcher(email);
	      return m.matches();
		}

		public void updatePass(String newPass, User u) throws SQLException {
			UserDAO.getInstance().updatePass(hashPassword(newPass), u);
			
		}

		
		public void addProfilePic(String username,String photoUrl) throws SQLException {
			User u = registeredUsers.get(username);
			u.setPhotoURL(photoUrl);
			UserDAO.getInstance().addProfilePic(u);
		}

		public List<User> searchUser(String words) {
			ArrayList<User> searchResults = new ArrayList<>();
			for (User user : registeredUsers.values()) {
				if (user.getFirst_name().contains(words) || user.getLast_name().contains(words) || user.getUsername().contains(words) || (user.getFirst_name() + " " + user.getLast_name()).contains(words)){
					searchResults.add(user);
				}
			}
			return Collections.unmodifiableList(searchResults);
		}
		
		public List<User> allUsersMostFollowed(){
			ArrayList<User> sortedUsers = new ArrayList<>();
			for (User user : registeredUsers.values()) {
				sortedUsers.add(user);
			}
			Collections.sort(sortedUsers, new Comparator<User>() {

				@Override
				public int compare(User o1, User o2) {
					if (o1.getFollowers().size() == o2.getFollowers().size()) return o1.hashCode() - o2.hashCode();
					return o1.getFollowers().size() - o2.getFollowers().size();
				}
			});
			return sortedUsers;
		}
		public void contactUs(String from, String text) {
			MailSender mailSender = new MailSender("travelbookmails@gmail.com", "Message from " + from, text);
			mailSender.start();
		}
	  
		
		public void follow(User follower, User following) throws SQLException {
			follower.follow(following.getUsername());
			UserDAO.getInstance().follow(follower, following);
		}
		public void unFollow(User follower, User following) throws SQLException {
			follower.unfollow(following.getUsername());
			UserDAO.getInstance().unFollow(follower, following);
		}

		public void updateAboutMe(User u, String aboutMe) throws SQLException {
			UserDAO.getInstance().updateAboutMe(aboutMe, u);
			
		}
	}



