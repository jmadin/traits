class UsersController < ApplicationController
  before_action :signed_in_user,  only: [:show, :edit, :update]
  before_action :correct_user,    only: [:show, :edit, :update]
  before_action :editor,          only: :index
  before_action :admin_user,      only: :destroy

  def index
    @users = User.all
  end

  def show

    # params[:n] = 20 if params[:n].blank?
    # n = params[:n]
    # n = 9999999 if params[:n] == "all"

    @user = User.find(params[:id])
    @observations = Observation.where(:user_id => @user.id)
    @observations = observation_filter(@observations)
    @observations = @observations.order('created_at DESC')

    if params[:resource].present?
      @observations = @observations.where(:resource_id => params[:resource])
    end

    if params[:location].present?
      @observations = @observations.where(:location_id => params[:location])
    end

    if params[:specie].present?
      @observations = @observations.where(:specie_id => params[:specie])
    end

    if params[:trait].present?
      @observations = @observations.where(:id => Measurement.where(:trait_id => params[:trait]).map(&:observation_id))
    end

    if params[:access].present?
      @observations = @observations.where(:private => params[:access])
    end

    @resources = Resource.where(:id => @observations.map(&:resource_id))
    @locations = Location.where(:id => @observations.map(&:location_id))
    @species = Specie.where(:id => @observations.map(&:specie_id))
    @traits = Trait.where("id IN (?) AND trait_class != 'Contextual'", Measurement.where(:observation_id => @observations.map(&:id)).map(&:trait_id))

    respond_to do |format|
      if params[:resource].present? or params[:location].present? or params[:specie].present? or params[:trait].present?
        format.html { @observations = @observations.paginate(page: params[:page], per_page: 9999) }
      else
        format.html { @observations = @observations.paginate(page: params[:page]) }
      end
      format.csv { download_observations(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
      format.zip{ send_zip(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
    end
  end


  def species
    @user = User.find(params[:id])
    render json: {
      species: Specie.where(:id => @user.observations.map(&:specie_id)).select(:id, :specie_name)
    }
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      
      SignUpMailer.acknowledge(@user).deliver
      
      flash[:success] = "Welcome to the " + ENV["SITE_NAME"]
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    #params[:user].delete(:password) if params[:user][:password].blank?
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:danger] = "User destroyed."
    redirect_to users_url
  end


  def edit_multiple
    @observations = Observation.find(params[:obs_ids])
  end

  def update_multiple
    User.where(:id => params[:ids]).update_all(:contributor => false)
    User.where(:id => params[:contrib_true_ids]).update_all(:contributor => true)
    User.where(:id => params[:ids]).update_all(:editor => false)
    User.where(:id => params[:editor_true_ids]).update_all(:contributor => true)
    User.where(:id => params[:editor_true_ids]).update_all(:editor => true)
    User.where(:id => params[:ids]).update_all(:admin => false)
    User.where(:id => params[:admin_true_ids]).update_all(:contributor => true)
    User.where(:id => params[:admin_true_ids]).update_all(:admin => true)
    User.where(:id => params[:admin_true_ids]).update_all(:editor => true)

    redirect_to users_path, flash: {success: "Privileges updated." }
  end




  private

    def user_params
      params.require(:user).permit(:name, :last_name, :institution, :email, :password, :password_confirmation, :admin, :contributor, :editor, :password_reset_token, :datetime)
    end

    # Before filters
  end
