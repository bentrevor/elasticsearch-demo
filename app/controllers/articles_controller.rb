class ArticlesController < ApplicationController
  def index
    if params[:query].present?
      @articles = Article.search (params[:query] )
    else
      @articles = Article.order( "created_at ASC" ).all
    end
  end

  def show
    @article = Article.find( params[:id] )
  end
  
  def create
    if @article.save
      redirect_to @article
    else
      flash.now[ :error ] = "There was an error creating the article"
      render :error
    end
  end

  def update
    if @article.update_attributes( params[:article] )
      redirect_to @article
    else
      flash.now[ :error ] = "There was an error updating the article"
      render :new
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_path
  end
end
