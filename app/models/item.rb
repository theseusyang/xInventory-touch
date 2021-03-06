class Item < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where("#{table_name}.voided = 0")

  belongs_to :category , :class_name => :Category, :foreign_key => :category_type                                                            
  belongs_to :donor , :class_name => :Donor, :foreign_key => :donor_id                                                           
  belongs_to :project , :class_name => :Project, :foreign_key => :project_id
  belongs_to :supplier , :class_name => :Supplier, :foreign_key => :vendor
  belongs_to :manufacturer , :class_name => :Manufacturer, :foreign_key => :brand
  belongs_to :site , :class_name => :Site, :foreign_key => :location
  has_one :current_state, :class_name => :ItemState,:foreign_key => :item_id
  belongs_to :currency, :class_name => :Currencies, :foreign_key => :currency_id


 def current_location
  location = DispatchReceive.where(:asset_id => self.id)
  unless location.blank?
    return Site.find(location.last.location_id)
  else
    return Site.find(self.location)
  end
 end

 def barcode_label
   label = ZebraPrinter::StandardLabel.new                                     
   label.font_size = 1
   label.font_horizontal_multiplier = 2                                        
   label.font_vertical_multiplier = 2                                          
   label.left_margin = 50                                                      
   label.draw_barcode(50,210,0,1,2,15,70,false,"#{self.barcode}") 
   label.draw_multi_text("#{self.name.titleize}")                      
   label.draw_multi_text("SN: #{self.serial_number}")
   label.draw_multi_text("Donor: #{self.donor.name.upcase}")                      
   label.draw_multi_text("Project: #{self.project.name}")
   label.draw_multi_text("Location: #{self.current_location.name}")
   label.print(1)
 end
 
 def responsible_person
  location = DispatchReceive.where(:asset_id => self.id)
  unless location.blank?
    return location.last.responsible_person
  end
 end

end
