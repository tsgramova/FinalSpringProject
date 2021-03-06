package com.example.model.dbModel;

import java.sql.Connection;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;



import com.example.model.managers.PostManager;
import com.example.model.managers.UsersManager;
import com.example.model.Comment;
import com.example.model.InvalidInputException;

import com.example.model.User;

public class CommentDAO {

private static CommentDAO instance;
	
	public ConcurrentHashMap<Long, Comment> comments;
	

	private CommentDAO() {
		comments= new ConcurrentHashMap<>();
		Connection con = DBManager.getInstance().getConnection();
		try {
			
			PreparedStatement ps = con.prepareStatement("SELECT comment_id,author_id,text,posts_post_id,date FROM comments");
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				PreparedStatement authorST = con.prepareStatement("SELECT username FROM users WHERE user_id=?"); 
		  		authorST.setLong(1, rs.getLong("author_id"));
		  		ResultSet authorRS = authorST.executeQuery();
		  		authorRS.next();
		  		User author = UsersManager.getInstance().getRegisteredUsers().get(authorRS.getString("username"));
		  		
		  		Long postId = rs.getLong("posts_post_id");
		  		Comment comment = new Comment(author, rs.getString("text"), postId,rs.getTimestamp("date").toLocalDateTime());
				comments.put(rs.getLong("comment_id"), comment);
				comment.setComment_id(rs.getLong("comment_id"));
				PreparedStatement likersST = con.prepareStatement("SELECT liker_id FROM comments_has_likers WHERE comment_id=?");
				likersST.setLong(1, comment.getComment_id());
				ResultSet likersRS = likersST.executeQuery();
				while(likersRS.next()) {
					PreparedStatement usernamePS = con.prepareStatement("SELECT username FROM users WHERE user_id = ?");
					usernamePS.setLong(1, likersRS.getLong("liker_id"));
					ResultSet usernameRS = usernamePS.executeQuery();
					usernameRS.next();
					User u = UsersManager.getInstance().getRegisteredUsers().get(usernameRS.getString("username"));
					comment.like(u);
					usernamePS.close();
					usernameRS.close();
				}
				
				
				
				authorRS.close();
				authorST.close();
				likersRS.close();
				likersST.close();
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			
			e.printStackTrace();
		} catch (InvalidInputException e) {
			e.printStackTrace();
		}
		
	}
	
	public static synchronized CommentDAO getInstance() {
		if(instance == null) {
			instance = new CommentDAO();
		}
		return instance;
	}
	
	public Map<Long, Comment> getALlComments() {
		return Collections.unmodifiableMap(comments);
	}
	

	public synchronized void deleteComment(Comment com) throws SQLException{
		PreparedStatement prepSt;
		Connection con = DBManager.getInstance().getConnection();
		  try {
			prepSt = con.prepareStatement("DELETE FROM comments WHERE comment_id=?");
			prepSt.setLong(1, com.getComment_id());
			prepSt.executeUpdate();
			prepSt.close();
			this.comments.remove(com);
			System.out.println("Comment successfully deleted!");
			
		  } catch (SQLException e) {
			 System.out.println(e.getMessage());
			 throw e;
		  }
	}
	
	public synchronized void addNewComment(Comment comment) throws SQLException {
		Connection con = DBManager.getInstance().getConnection();
		PreparedStatement ps = null;
		
		try {
			ps = con.prepareStatement("INSERT INTO comments (author_id,text,posts_post_id,date) VALUES (?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
			ps.setLong(1, comment.getAuthor().getUserId());
			ps.setString(2, comment.getText());
			ps.setLong(3, comment.getPost());
			ps.setTimestamp(4, Timestamp.valueOf(comment.getDate()));
			ps.executeUpdate();
			
			ResultSet rs = ps.getGeneratedKeys();
			rs.next();
			long commentId = rs.getLong(1);
			comment.setComment_id(commentId);;
			rs.close();
			ps.close();
			this.comments.put(comment.getComment_id(), comment);
			System.out.println("Comment added successfully");
			comments.put(comment.getComment_id(), comment);
			PostManager.getInstance().getPosts().get(comment.getPost()).addComment(comment);
			System.out.println("komentari-" + PostManager.getInstance().getPosts().get(comment.getPost()).getComments().size());

		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		}
				
	}
	

}

