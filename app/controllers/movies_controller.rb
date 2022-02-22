class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    if params[:orderBy].nil? && params[:ratings].nil? && (!session[:orderBy].nil? || !session[:ratings].nil?)
      flash.keep
      redirect_to movies_path(:orderBy => session[:orderBy], :ratings => session[:ratings])
    elsif params[:orderBy].nil? && !session[:orderBy].nil?
      flash.keep
      redirect_to movies_path(:orderBy => session[:orderBy], :ratings => params[:ratings])
    elsif params[:ratings].nil? && !session[:ratings].nil?
      flash.keep
      redirect_to movies_path(:orderBy => params[:orderBy], :ratings => session[:ratings])
    end

    @all_ratings = Movie.ratings

    @orderBy = params[:orderBy]
    @ratings = params[:ratings]

    if @ratings.nil?
      ratings = Movie.ratings
      @all_ratings = Hash[@all_ratings.map{ |rating| [rating, true] }]
    else
      ratings = @ratings.keys
      @all_ratings = Movie.ratings.inject(Hash.new) { |all_ratings, rating|
        all_ratings[rating] = @ratings.nil? ? false : @ratings.has_key?(rating) 
        all_ratings
      }
    end

    if !@orderBy.nil?
      @movies = Movie.order("#{@orderBy}").with_ratings(ratings)
    else
      @movies = Movie.with_ratings(ratings)
    end
    
    session[:orderBy] = @orderBy
    session[:ratings] = @ratings
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
