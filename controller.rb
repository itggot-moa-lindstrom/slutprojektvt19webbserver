require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require 'sinatra/flash'
require_relative 'model.rb'
include Model
enable :sessions
un_secure_routes = ['/', '/login', '/signup', '/signup/new', '/oopsie', '/mustbelogged', '/posts', '/cantliketwice' ]

before do
    unless un_secure_routes.include? request.path()
        if session[:loggedin] != true
            redirect('/')
        end
    end
end

# Displays the first page
#
get('/') do
    slim(:login)
end

# Displays the sign up page
#
get('/signup') do
    slim(:signup)
end

# Attempts to create a new user
#
# @param [String] firstname, the first name of the user
# @param [String] lastname, the last name of the user
# @param [String] username, the username of the user
# @param [String] phone, the phone number of the user
# @param [String] email, the email of the user
# @param [String] password, the password of the user
#
# @see Model#signup_new
post('/signup/new') do
    response = signup_new(params)
    id = response[:data]
    if response[:error]
        flash[:error] = response[:message]
        redirect back
    else
        session[:loggedin] = true
        session[:userid] = response[:data]
        session[:username] = params["username"]
        redirect("/myside")
    end
end

# Attempts to log in and updates the session
#
# @param [String] username, the username of the user
# @param [String] pasword, the password of the user
#
# @see Model#login
post('/login') do 
    svar = login(params)
    if svar[:error]
        flash[:error] = svar[:message]
        redirect back
    else
        session[:loggedin] = true
        session[:userid] = svar[:data]
        session[:username] = params["username"]
        redirect("/myside")
    end
end 

# Displays error page
#
get('/oopsie') do
    slim(:oopsie)
end

# Displays the user's profile
#
# @param [String] id, the id of the user
#
# @see Model#get_posts
# @see Model#get_users
get('/myside') do
    id = session[:userid]
    result = get_posts(id)
    result2 = get_users(id)
    slim(:myside, locals:{
        posts: result, users: result2
    })
end

# Displays the user's profile's edit page
#
# @param [String] id, the id of the user
#
# @see Model#get_users
get('/myside/edit') do
    id = session[:userid]
    slim(:edit, locals:{
        users: get_users(id)
    })
end

# Attempts to update the user's data in the database
#
# @param [String] firstname, the first name of the user
# @param [String] lastname, the last name of the user
# @param [String] username, the username of the user
# @param [String] phone, the phone number of the user
# @param [String] email, the email of the user
# @param [String] id, the id of the user
#
# @see Model#myside_update
post('/myside/update') do
    id = session[:userid]
    myside_update(params,id)
    redirect("/myside")
end

# Displays every user's posts
#
# @see Model#mposts
# @see Model#likes
get('/posts') do
    result = posts()
    result2 = likes()
    slim(:posts, locals:{
        users: result, likes: result2
    })
end

# Displays the page for writing a new post
#
get('/newpost') do
    slim(:newpost)
end

# Attempts to create a new post
#
# @param [String] title, the title of the post
# @param [String] text, the text of the post
# @param [String] userid, the id of the user
#
# @see Model#newpost
post('/newpost/new') do
    userid = session[:userid]
    if session[:loggedin] == true
        newpost(params,userid)
        redirect('/posts')
    else
        redirect('/mustbelogged')
    end
end

# Displays the page where you can edit your own posts
#
# @param [String] id, the id of the post
#
# @see Model#edit_post
get('/editpost/:id') do
    result = edit_post(params)
    slim(:editpost, locals:{
        users: result
    })
end

# Attempts to update the post in the database
#
# @param [String] id, the id of the post
#
# @see Model#edit_post
post('/editpost/:id/update') do
    update_post(params)
    redirect("/myside")
end

# Attempts to update the amount of likes on a post
#
# @param [String] userid, the id of the user
# @param [String] postid, the id of the post
#
# @see Model#like
post('/like') do
    if session[:loggedin] == true
        userid = session[:userid]
        like(params,userid)
    else
        redirect('/mustbelogged')
    end
end

# Displays error page
# 
get('/mustbelogged') do
    slim(:mustbelogged)
end

# Displays error page
# 
get('/cantliketwice') do
    slim(:cantliketwice)
end

# Attempts to log out user and destroy session
# 
post('/logout') do
    session.destroy
    redirect('/login')
end