require "absa-h2h/version"
require "yaml"

require 'absa-h2h/helpers'
require 'absa-h2h/record'
require 'absa-h2h/transmission'
require 'absa-h2h/account_holder_verification'
require 'absa-h2h/eft'

module Absa
  module H2h
    
    class File
      
      def initialize(options = {})
        @header = nil
        @user_sets = []
        @trailer = nil
      end

      def self.build(options = {})
        file = self.new
        file.build_header options[:transmission][:header]
        file.build_trailer options[:transmission][:trailer]
        
        options[:transmission][:user_sets].each do |user_set|
          puts user_set.inspect
          file.build_user_set(user_set)
        end
        
        #validate!
        
        file
      end
      
      def validate!
        raise "Error: Header and Trailer Status needs to be the same" if @header.th_rec_status != @trailer.tt_rec_status
      end
      
      def build_header(options = {})
        @header = Transmission::Header.new(options)
      end
      
      def build_trailer(options = {})
        @trailer = Transmission::Trailer.new(options)
      end
      
      def build_user_set(options = {})
        class_name = "Absa::H2h::Transmission::#{options[:type].camelize}"
        puts class_name
        hash = class_name.constantize.build(options[:content])
        puts "user set hash"
        puts hash.inspect
        @user_sets.push hash
      end
    
      def self.write_file!(header, trailer, destination)
        File.open(destination, 'w') do |f| 
          f.write(header)
          f.write(trailer) 
        end
      end
      
      def to_s
        lines = []
        lines << @header.to_s
        
        @user_sets.each do |set| 
          lines << set[:header].to_s
          
          set[:transactions].each do |transaction|
            lines << transaction.to_s
          end
          
          lines << set[:trailer].to_s
        end
        
        lines << @trailer.to_s
        lines.join("\r\n")
      end
    
    end
    
  end
end
