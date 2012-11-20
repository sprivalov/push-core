module Push
  class Configuration < ActiveRecord::Base
    self.table_name = 'push_configurations'

    def self.enabled
      self.scoped.where(:enabled => true)
    end

    validates :app, :presence => true
    validates :connections, :presence => true
    validates :connections, :numericality => { :greater_than => 0, :only_integer => true }
    validates :type, :uniqueness => { :scope => :app, :message => "Only one push provider type per configuration name" }
  end
end