class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tag, only: %i[ edit update destroy ]

  def index
    @tags = Tag.all.order(:name).page(params[:page]).per(20)
  end

  def new
    @tag = Tag.new
  end

  def edit
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      @tags = Tag.all.order(:name).page(params[:page]).per(20)
      flash.now[:notice] = "Etiqueta creada exitosamente."

      respond_to do |format|
        format.html { redirect_to tags_path, notice: "Etiqueta creada exitosamente." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tag.update(tag_params)
      @tags = Tag.all.order(:name).page(params[:page]).per(20)
      flash.now[:notice] = "Etiqueta actualizada exitosamente."

      respond_to do |format|
        format.html { redirect_to tags_path, notice: "Etiqueta actualizada exitosamente." }
        format.turbo_stream { render :create }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.destroy
    redirect_to tags_path, notice: "Etiqueta eliminada exitosamente.", status: :see_other
  end

  private
    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name, :color)
    end
end
