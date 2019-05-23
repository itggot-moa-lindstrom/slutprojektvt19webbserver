require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'

enable :sessions

get('/') do
    slim(:login)
end

get('/login') do
    slim(:login)
end

get('/signup') do
    slim(:signup)
end

post('/signup/new') do
    db=SQLite3::Database.new("db/slutpro.db")
    hash_password = BCrypt::Password.create(params["password"])
    db.execute("INSERT INTO users(firstname, lastname, username, email, phone, password) VALUES ((?), (?), (?), (?), (?), (?))", params["firstname"], params["lastname"], params["username"], params["email"], params["phone"], hash_password)
    redirect('/')
end

post('/login') do 
    db=SQLite3::Database.new("db/slutpro.db")
    db.results_as_hash = true
    result = db.execute("SELECT userid, username, password FROM users WHERE users.username=(?)", params["username"])
    username = result[0]["username"]
    password = result[0]["password"]
    
    id = result[0]["userid"]
        if params["username"] == username && BCrypt::Password.new(password) == params["password"]
            session[:loggedin] = true
            p result[0]["userid"]
            session[:userid] = id
            session[:firstname] = params["firstname"]
            
            redirect("/myside/#{id}")
        else 
            redirect('/oopsie')
        end
end

get('/oopsie') do
    slim(:oopsie)
end

get('/blogg') do
    slim(:blogg)
end

get('/myside/:id') do
    if session[:loggedin] == true
        db=SQLite3::Database.new("db/slutpro.db")
        db.results_as_hash = true
        result=db.execute("SELECT * FROM posts WHERE posts.userid=(?)", session[:userid])
        result2=db.execute("SELECT * FROM users WHERE users.userid=(?)", session[:userid])
        slim(:myside, locals:{
            posts: result, users: result2
        })
    else
        redirect('/oopsie')
    end
end

get('/myside/:id/edit') do
    db=SQLite3::Database.new("db/slutpro.db")
    db.results_as_hash = true
    result = db.execute("SELECT userid, firstname, lastname, username, email, phone, password FROM users WHERE userid=(?)", params['id'].to_i)
    slim(:edit, locals:{
        users: result
    })
end

post('/myside/:id/update') do
    db=SQLite3::Database.new("db/slutpro.db")
    db.execute("UPDATE users SET firstname=(?), lastname=(?), username=(?), email=(?), phone=(?) WHERE userid=(?)", params["firstname"], params["lastname"], params["username"], params["email"], params["phone"], session["userid"])
    id=session[:userid]
    redirect("/myside/#{id}")
end

get('/posts') do
    db=SQLite3::Database.new("db/slutpro.db")
    db.results_as_hash=true
    result=db.execute("SELECT users.userid, users.firstname, users.lastname, users.username, users.email, users.phone, posts.title, posts.text, posts.postid FROM users INNER JOIN posts ON users.userid=posts.userid")
    likes = db.execute("SELECT * FROM likes")
    slim(:posts, locals:{
        users: result,
        likes: likes,
    })
end

get('/newpost') do
    slim(:newpost)
end

post('/newpost/new') do
    if session[:loggedin] == true
        db=SQLite3::Database.new("db/slutpro.db")
        db.execute("INSERT INTO posts(title, text, userid) VALUES (?, ?, ?, ?)", params["title"], params["text"], session["userid"])
        redirect('/posts')
    else
        redirect('/mustbelogged')
    end
end

get('/editpost/:id') do
    db=SQLite3::Database.new("db/slutpro.db")
    db.results_as_hash = true
    result=db.execute("SELECT posts.title, posts.text, posts.postid FROM posts WHERE posts.postid=(?)", params['id'].to_i)
    slim(:editpost, locals:{
        users: result
    })
end

post('/editpost/:id/update') do
    db=SQLite3::Database.new("db/slutpro.db")
    db.execute("UPDATE posts SET title=(?), text=(?) WHERE postid=(?)", params["title"], params["text"], params["id"])
    id=session[:userid]
    redirect("/myside/#{id}")
end

post('/like') do
    if session[:loggedin] == true
        db=SQLite3::Database.new("db/slutpro.db")
        likedposts=db.execute("SELECT likes.postid FROM likes WHERE userid=(?)", session[:userid])
        likedposts = likedposts.flatten
        if likedposts.include? params["postid"].to_i
            redirect('/oopsie')
        else
            db.execute("INSERT INTO likes(userid, postid) VALUES (?, ?)", session[:userid], params["postid"])
            redirect('/posts')
        end
    else
        redirect('/mustbelogged')
    end
end

get('/mustbelogged') do
    slim(:mustbelogged)
end