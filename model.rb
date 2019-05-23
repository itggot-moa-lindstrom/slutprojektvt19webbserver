module Model
    # Establishes a connection to the database
    #
    # @return [SQLite3::Database] a connection with Hash
    def connect
        db=SQLite3::Database.new("db/slutpro.db")
        db.results_as_hash = true
        return db
    end

    # Establishes a connection to the database
    #
    # @return [SQLite3::Database] a connection without Hash
    def connect_non_hash
        db=SQLite3::Database.new("db/slutpro.db")
        return db
    end

    # Attemps to get all posts from the posts table
    #
    # @return [Array] containing the data of all the posts
    def get_posts(id)
        db = connect()
        return result=db.execute("SELECT * FROM posts WHERE posts.userid=(?)", id)
    end

    # Attempts to create a new user in the users table
    #
    # @param [Hash] params form data
    # @option params [String] firstname, the first name of the user
    # @option params [String] lastname, the last name of the user
    # @option params [String] username, the username of the user
    # @option params [String] phone, the phone number of the user
    # @option params [String] email, the email of the user
    # @option params [String] password, the password of the user
    #
    # @return [Hash]
    #   * :error [Boolean] if an error occured
    #   * :message [String] error message if an error occured
    #   * :data [Integer] the user's id if the user was created
    def signup_new(params)
        if params["password"] == params["password2"]
            db = connect()
            name = params["username"]
            password = BCrypt::Password.create(params["password"])
            result = db.execute("SELECT userid FROM users WHERE username =(?)", params["username"])
            if result != []
                return {
                    error: true,
                    message: "Username taken"
                }
            else
                db.execute("INSERT INTO users(firstname, lastname, username, phone, email, password) VALUES((?),(?),(?),(?),(?),(?))", params["firstname"], params["lastname"], name, params["phone"], params["email"], password)                         
                id = db.execute("SELECT userid FROM users WHERE username =(?)", params["username"])
                return {
                    error: false,
                    data: id[0][0]
                }
            end
        else
            return {
                error: true,
                message: "Passwords do not match"
            }
        end
    end

    # Attempts to find a user in the users table
    #
    # @param [Hash] params form data
    # @option params [String] username, the username of the user
    # @option params [String] password, the password of the user
    #
    # @return [Hash]
    #   * :error [Boolean] if an error occured
    #   * :message [String] error message if an error occured
    #   * :data [Integer] the user's id if the user was created
    def login(params)
        db = connect()
        result = db.execute("SELECT userid, username, password FROM users WHERE users.username=(?)", params["username"])
        if result == []
            return {
                error: true,
                message: "Username or Password is incorrect"
            }
        end
        username = result[0]["username"]
        password = result[0]["password"]
        id = result[0]["userid"]
        if params["username"] == username && BCrypt::Password.new(password) == params["password"]
            return {
                error: false,
                data: id
            }
        else 
            return{
                error: true,
                message: "Username or password is incorrect"
            }
        end
    end

    # Attempts to fetch userdata from the users table
    #
    # @option params [String] id, the id of the user
    #
    # @return [Array] userdata
    def get_users(id)
        db = connect()    
        return result2 = db.execute("SELECT * FROM users WHERE userid=(?)", id)
    end

    # Attempts to update the user data from the users table
    #
    # @param [Hash] params form data
    # @option params [String] firstname, the first name of the user
    # @option params [String] lastname, the last name of the user
    # @option params [String] username, the username of the user
    # @option params [String] phone, the phone number of the user
    # @option params [String] email, the email of the user
    # @option params [String] id, the id of the user
    #
    # @return [Array] userdata
    def myside_update(params,id)
        db = connect_non_hash()
        result = db.execute("UPDATE users SET firstname=(?), lastname=(?), username=(?), email=(?), phone=(?) WHERE userid=(?)", params["firstname"], params["lastname"], params["username"], params["email"], params["phone"], id)
        return result
    end

    # Attempts to fetch the postdata from the posts table
    #
    # @return [Array] postdata
    def posts()
        db = connect()
        result = db.execute("SELECT users.userid, users.firstname, users.lastname, users.username, users.email, users.phone, posts.title, posts.text, posts.postid FROM users INNER JOIN posts ON users.userid=posts.userid")
        return result
    end

    # Attempts to fetch the amount of likes from the likes table
    #
    # @return [Array] postdata
    def likes()
        db = connect()
        result2 = db.execute("SELECT * FROM likes")
        return result2
    end

    # Attempts to add a row in the posts table
    #
    # @option params [String] userid, the id of the user
    # @option params [String] title, the title of the post
    # @option params [String] text, the text of the post
    def newpost(params,userid)
        db = connect_non_hash()
        db.execute("SELECT userid FROM users")
        db.execute("INSERT INTO posts(title, text, userid) VALUES (?, ?, ?)", params["title"], params["text"], userid)
    end

    # Attempts to edit a row in the posts table
    #
    # @option params [String] id, the id of the post
    #
    # @return [Array] postdata
    def edit_post(params)
        db = connect()
        result=db.execute("SELECT posts.title, posts.text, posts.postid FROM posts WHERE posts.postid=(?)", params['id'].to_i)
        return result
    end

    # Attempts to edit a row in the posts table
    #
    # @option params [String] id, the id of the post
    #
    # @return [Array] postdata
    def update_post(params)
        db = connect_non_hash()
        db.execute("UPDATE posts SET title=(?), text=(?) WHERE postid=(?)", params["title"], params["text"], params["id"])
    end

    # Attempts to update a row in the likes table
    #
    # @option params [String] postid, the id of the post
    # @option params [String] userid, the id of the user
    def like(params,userid)
        db = connect_non_hash()
        likedposts=db.execute("SELECT likes.postid FROM likes WHERE userid=(?)", userid)
        likedposts = likedposts.flatten
        if likedposts.include? params["postid"].to_i
            redirect('/cantliketwice')
        else
            db.execute("INSERT INTO likes(userid, postid) VALUES (?, ?)", userid, params["postid"])
            redirect('/posts')
        end
    end
end