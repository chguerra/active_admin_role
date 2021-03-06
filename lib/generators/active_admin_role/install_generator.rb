require "rails/generators/migration"
require "generators/active_admin_role/helper"

module ActiveAdminRole
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration
      include ActiveAdminRole::Generators::Helper

      source_root File.expand_path("../templates", __FILE__)

      class_option :model, optional: true,
                           type:     :string,
                           banner:   "model",
                           desc:     "Specify the model class name if you will use anything other than `AdminUser`",
                           default:  "AdminUser"

      def copy_initializer_file
        template "initializer.rb", "config/initializers/active_admin_role.rb"
      end

      def configure_model
        generate :"active_admin:install #{model_class_name}" unless model_class_name.safe_constantize
        inject_into_model
      end

      def copy_migration_files
        migration_template "migration/add_role_to_admin_users.rb", "db/migrate/add_role_to_#{model_class_name.tableize}.rb", migration_class_name: migration_class_name
        migration_template "migration/create_active_admin_managed_resources.rb", "db/migrate/create_active_admin_managed_resources.rb", migration_class_name: migration_class_name
        migration_template "migration/create_active_admin_permissions.rb", "db/migrate/create_active_admin_permissions.rb", migration_class_name: migration_class_name
      end

      def copy_model_file
        template "model/ability.rb", "app/models/ability.rb"
      end

      def configure_active_admin
        gsub_file "config/initializers/active_admin.rb",
                  "# config.authorization_adapter = ActiveAdmin::CanCanAdapter",
                  "config.authorization_adapter = ActiveAdmin::CanCanAdapter"
      end

      def copy_admin_permission_file
        template "admin/permission.rb", "app/admin/permission.rb"
      end

      def configure_admin_user_file
        inject_into_file "app/admin/#{model_file_path}.rb",
                         "  role_changeable\n",
                         after: "ActiveAdmin.register #{model_class_name} do\n"
      end
    end
  end
end
