module Selleo
  module AMFController
    def self.included(base)
      base.extend ControllerMethods
    end

    module ControllerMethods
      def amf_controller(options = {})
        class_inheritable_accessor :model

        self.model = options[:model] || controller_name.sub(/Controller$/, '').classify.constantize


        include Controller::CommonActions
        ((!options[:actions].blank? and options[:actions]) or %w(create read update destroy)).each do |method|
          include "Selleo::AMFController::Controller::Action#{method.to_s.capitalize}".constantize
        end
      end
    end

    module Controller
      module CommonActions
        private
        def find_resources
          @result = params[:id].nil? ? model.find(:all) : model.find(params[:id])
        end

        def get_resource_from_resource_params
          @result = params[0][model.to_s.to_snake!.to_sym]
        end
      end

      module ActionRead

        def read
          find_resources

          respond_to do |format|
            format.amf { render_with_amf :amf => @result }
            format.html { render :text => @result.to_yaml }
          end
        end
      end

      module ActionCreate
        def create
          respond_to do |format|
            format.amf do
              get_resource_from_resource_params

              if @result.save
                render :amf => model.find(@result.id)
              else
                render :amf => FaultObject.new(@result.errors.full_messages.join("\n"))
              end
            end
          end
        end
      end

      module ActionUpdate
        def update
          respond_to do |format|
            format.amf do
              updated_product_attributes = get_resource_from_resource_params.attributes
              updated_id = updated_product_attributes.delete("id")
              updated_product_attributes.delete("lock_version")
              @result = model.find(updated_id)
              @result.attributes = updated_product_attributes
              if @result.save
                render :amf => model.find(@result.id)
              else
                render :amf => FaultObject.new(@result.errors.full_messages.join("\n"))
              end
            end
          end
        end
      end

      module ActionDestroy
        def destroy
          @result = model.find_by_id(params[:id])
          respond_to do |format|
            format.amf do
              if @result
                @result.destroy
                render :amf => true
              else
                render :amf => FaultObject.new("Couldn't find #{model.to_s} with given ID!")
              end
            end
          end
        end
      end

    end
  end
end