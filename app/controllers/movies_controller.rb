class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
    self.restore_session
  end

  def restore_session
    @sort_type = session[:sort_type]
    @param_str = session[:param_str]
    @submit_str = session[:submit_str]
    @all_ratings = session[:all_ratings]
  end

  def index
    @sort_type = ''    
    @all_ratings = Hash.new()
    @param_str = ''
    checkked_buttons = []
=begin
    flash[:notice] = "sess_sort_type: #{session[:sort_type]},
    sess_all_ratings: #{session[:all_ratings]}, 
    cur_params: #{params}"
=end

    
    # Setup Parameters & Consult/Save Session Parameters as need be
    session[:sort_type] = params["sort"] unless params["sort"] == nil
    @sort_type = session[:sort_type]

    # find uniq rating parameters from db, and setup @all_ratings 
    # First time setup checkked_buttons in session
    if session[:all_ratings] == nil
      ratings = Movie.select(:rating).map(&:rating).uniq.sort
      ratings.each {|rating| @all_ratings[rating] = true}
      session[:all_ratings] = @all_ratings  
    else
      @all_ratings = session[:all_ratings]
    end

    if params["ratings"] == nil
          @all_ratings.each {|rating, val| checkked_buttons << rating unless val == false}
    else
        keys = @all_ratings.keys
        keys.each {|rating| @all_ratings[rating] = false}
        checkked_buttons =  params["ratings"].keys
        checkked_buttons.each  {|rating| @all_ratings[rating] = true}
        session[:all_ratings] = @all_ratings  
    end
    
    # Get the records from the database, sort as needed
    @movies = Movie.where(:rating => checkked_buttons).all    
    
    if session[:sort_type] != nil
      if session[:sort_type] == 'title'
        @movies.sort! {|t1, t2| t1.title <=> t2.title }
      elsif session[:sort_type] == 'release_date'
        @movies.sort! {|r1, r2| r1.release_date <=> r2.release_date}
      end
    end
    
    # @param_str instance parameters 
    # RESTful for redirection
    checkked_buttons.each {|rating| @param_str = @param_str+'&ratings['+rating+']='+'1'}
    session[:param_str] = @param_str
    if params["commit"] != nil 
      @submit_str = "?utf8="+params["utf8"]+@param_str+"&commit="+params["commit"]
      session[:submit_str] = @submit_str
    end
  end

  def new
    # default: render 'new' template
  end

  def redirect
    self.restore_session 
    if @sort_type != nil
      redirect_to movies_path+'?sort='+@sort_type+@param_str
    elsif @submit_type == 'commit'
      redirect_to movies_path+@submit_str
    else
      redirect_to movies_path
    end
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created." 
    self.redirect
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."    
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    self.redirect
  end

end
