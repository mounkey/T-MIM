class WikiController < ApplicationController
  before_action :authenticate_user!
  before_action :set_article, only: %i[show edit update destroy]

  def index
    @query = params[:q].to_s.strip
    @active_tab = params[:tab] || "manual"

    # Guías oficiales globales de T-MIM
    @global_articles = WikiArticle.global_articles
    if @query.present?
      @global_articles = @global_articles.where("title ILIKE :q OR content ILIKE :q", q: "%#{@query}%")
    end

    # Artículos internos y fichas técnicas del taller del cliente
    @company_articles = WikiArticle.company_articles
    if @query.present?
      @company_articles = @company_articles.where("title ILIKE :q OR content ILIKE :q", q: "%#{@query}%")
    end

    @selected_article = if params[:id].present?
                          WikiArticle.unscoped.find_by(id: params[:id])
                        else
                          @active_tab == "company" ? @company_articles.first : @global_articles.first
                        end
  end

  def show
    @selected_article = @article
    index
    render :index
  end

  def new
    @article = WikiArticle.new(category: "Procedimientos de Taller", icon: "fa-wrench")
  end

  def edit
    if @article.is_global? && !current_user.admin?
      redirect_to wiki_index_path, alert: "Los manuales oficiales de T-MIM solo pueden ser modificados por administración."
    end
  end

  def create
    @article = WikiArticle.new(article_params)
    @article.account = current_user.account
    @article.is_global = false # Artículos del cliente siempre son privados de su empresa

    if @article.save
      redirect_to wiki_index_path(id: @article.id, tab: "company"), notice: "Artículo de procedimiento creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @article.is_global? && !current_user.admin?
      redirect_to wiki_index_path, alert: "No tiene permisos para editar guías globales del sistema."
      return
    end

    if @article.update(article_params)
      tab = @article.is_global? ? "manual" : "company"
      redirect_to wiki_index_path(id: @article.id, tab: tab), notice: "Artículo actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @article.is_global? && !current_user.admin?
      redirect_to wiki_index_path, alert: "No tiene permisos para eliminar guías globales de T-MIM."
      return
    end

    @article.destroy
    redirect_to wiki_index_path(tab: "company"), notice: "Artículo eliminado correctamente.", status: :see_other
  end

  private

  def set_article
    @article = WikiArticle.unscoped.find(params[:id])
    # Si no es global, verificar que pertenezca al taller
    if !@article.is_global? && @article.account_id != current_user.account_id
      redirect_to wiki_index_path, alert: "No tiene acceso a este documento."
    end
  end

  def article_params
    params.require(:wiki_article).permit(:title, :category, :content, :icon)
  end
end
