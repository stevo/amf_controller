class <%= amf_controller_name.pluralize %>Controller < ApplicationController

def read
    result = params[:id].nil? ? <%= amf_controller_name %>.all : <%= amf_controller_name %>.find(params[:id])

    respond_to do |format|
      format.amf { render_with_amf :amf => result }
      format.html { render :text => result.to_yaml }
    end
  end

  def create
    respond_to do |format|
      format.amf do
        # z rubyamfa dostajemy kompletny obiekt jako params[0][:<%= amf_controller_name.dup.to_snake! %>]
        @<%= singular_name %> = params[0][:<%= amf_controller_name.dup.to_snake! %>]
        if @product.save
          render :amf => <%= amf_controller_name %>.find(@<%= singular_name %>.id)
        else
          render :amf => FaultObject.new(@<%= singular_name %>.errors.full_messages.join("\n"))
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.amf do
        updated_product_attributes = params[0][:<%= amf_controller_name.dup.to_snake! %>].attributes
        updated_id = updated_product_attributes.delete("id")
        updated_product_attributes.delete("lock_version")     #SQLite specific
        @<%= singular_name %> = <%= amf_controller_name %>.find(updated_id)
        @<%= singular_name %>.attributes = updated_product_attributes
        if @<%= singular_name %>.save
          render :amf => <%= amf_controller_name %>.find(@<%= singular_name %>.id)
        else
          render :amf => FaultObject.new(@<%= singular_name %>.errors.full_messages.join("\n"))
        end
      end
    end
  end

  def destroy
    @<%= singular_name %> = <%= amf_controller_name %>.find_by_id(params[:id])
    respond_to do |format|
      format.amf do
        if @<%= singular_name %>
          @<%= singular_name %>.destroy
          render :amf => true
        else
          render :amf => FaultObject.new("Couldn't find <%= singular_name %> with given ID!")
        end
      end
    end
  end


end