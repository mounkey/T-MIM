class Superadmin::SystemSettingsController < Superadmin::BaseController
  def index
    # Pre-fetch existing settings into a hash for easy form rendering
    @settings = SystemSetting.all.index_by(&:key)
  end

  def update_multiple
    settings_params = params.require(:settings).permit!
    
    settings_params.each do |key, value|
      setting = SystemSetting.find_or_initialize_by(key: key)
      setting.value = value
      setting.save
    end

    redirect_to superadmin_system_settings_path, notice: "Configuraciones actualizadas exitosamente."
  end
end
