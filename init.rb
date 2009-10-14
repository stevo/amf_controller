require "string_extensions"
require "mime_types"
require 'abstract_amf_controller'
ActionController::Base.send(:include, Selleo::AMFController)