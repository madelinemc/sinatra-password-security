require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

	configure do
		set :views, "app/views"
		enable :sessions
		set :session_secret, "password_security"
	end

	get "/" do #renders the index.erb file which has links to sign up or login
		erb :index
	end

	get "/signup" do #renders a form to create a new user with form fields username and password
		erb :signup
	end

	post "/signup" do #makes a new instance of the user class with a username and password form params
		user = User.new(:username => params[:username], :password => params[:password]) 
		#Note that even though our database has a column called password_digest, we still access the attribute of password. This is given to us by has_secure_password.

		if user.save #will not be able to save to database if the password field is NOT filled out. user.save will return false if the user can't be persisted so redirect to login if true and failure page if false.
			redirect "/login"
		else
			redirect "/failure"
		end
	end 

	get "/login" do #renders a form for logging in
		erb :login
	end

	post "/login" do
		user = User.find_by(:username => params[:username]) #find user by username
		if user && user.authenticate(params[:password])
			#check to confirm if a user was found. can be written as user or user != nil 
			#also, check to confirm user's password matches up the value in password_digest by authenticate method provided by has_secure_password macro. Ruby handles this "invisibly" for us. 
			session[:user_id] = user.id #if user authenticates, the session's user_id is set to that user's id. 
			redirect "/success"
		else
			redirect "/failure"
		end
	end

	get "/success" do #renders a success.erb file which is displayed once a user successfully logs in
		if logged_in?
			erb :success
		else
			redirect "/login"
		end
	end

	get "/failure" do #renders a failure.erb page which will be accessed if there is an error logging in or signing up. 
		erb :failure
	end

	get "/logout" do #clears the session data and redirects to homepage
		session.clear
		redirect "/"
	end

	helpers do # renders a true or false based on the presence of a session[:user_id]
		def logged_in?
			!!session[:user_id]
		end

		def current_user #returns the instance of the logged in user, based on the session[:user_id]
			User.find(session[:user_id])
		end
	end

end
