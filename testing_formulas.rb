Inventory.all.each do |item|
  arr = []
  stock = item.qty
  item.clinic.surgery_appts.each do |recipe|
    recipe.surgery_type.surgery_recipe_reqs.each do |req|
      arr << req.qty
    end
  end
  arr.sum
end



#This method will take Inventory ID as an argument
def inventorycheck(args)
  #find inventory item by id
  Inventory.find(args) do |item|
    arr = []
    #capture stock item qty into variable
    stock = item.qty
    #loop into each item and check the existing appointments per item
    item.clinic.surgery_appts.each do |recipe|
      #check the surgery recipe requirements per appointment
      #check ONLY the items that pertain the the supply list item that was declared above
      recipe.surgery_type.surgery_recipe_reqs.where(supply_list_id:args).each do |req|
        #store those recipe requirements into the array
        arr << req.qty
      end
    end
    #sum all the items in the array together
    arr = arr.sum
    p arr
    #subract the appointment totals from the Inventory stock qty
    stock = stock - arr
    #update the Inventory stock qty
    Inventory.find(args).update(qty:stock)
  end
end




#This will list the inventory demand, by item
def inventorycheck(args)
  Inventory.find(args) do |item|
    arr = []
    stock = item.qty
    item.clinic.surgery_appts.each do |recipe|
      recipe.surgery_type.surgery_recipe_reqs.where(supply_list_id:args).each do |req|
        arr << req.qty
      end
    end
    arr = arr.sum
    p "The demand for #{item.supply_list.item_name} is #{arr}"
  end
end











SupplyList.find(1) do |collect|
  arr = []
  collect.surgery_recipe_reqs.each do |i|
    i.surgery_type.surgery_appts.each do |x|
      x.surgery_type.surgery_recipe_reqs.where(supply_list_id:1).each do |item|
        arr << item.qty
      end
    end
  end
  arr = arr.sum
  p arr
  Inventory.find(1).update(qty:(Inventory.first.qty - arr))
end


Inventory.first.clinic.surgery_appts.first.surgery_type.surgery_recipe_reqs.first.qty
myvar = SupplyList.first.surgery_recipe_reqs.first.surgery_type.surgery_appts.first.surgery_type.surgery_recipe_reqs.where(supply_list_id:1).first.qty
Inventory.first.update(qty:(Inventory.first.qty - myvar))













#==================================================================
#==================================================================
#==================================================================
#==================================================================
#Here go functions that attempt to create the actual recipe reqs at 0 at moment of appointment creation
#When Surgery Appt created
#capture individual surgery appointment data set
"surgery_type_id"=>"1"
@surgery_appt = SurgeryAppt.new(surgery_appt_params)
# this_surgery = SurgeryAppt.create(surgery_date: "2017-10-6", clinic_id:1, surgery_type_id: params[:surgery_type_id])
#Select Surgery Type
#Select ALL surgery recipe REQS
#Change each surgery recipe req to 0
#Create actual recipe reqs with correct params
SurgeryType.find(@surgery_appt.surgery_type_id).surgery_recipe_reqs.each do |req|
  supply_item = req.supply_list_id
  ActualRecipeReq.create(
    qty:0,
    supply_list_id:supply_item,
    surgery_appt_id:@surgery_appt.id)
end












s = 1
this_surgery = SurgeryAppt.create(surgery_date: "2017-10-6", clinic_id:1, surgery_type_id: s)
#Select Surgery Type
#Select ALL surgery recipe REQS
#Change each surgery recipe req to 0
#Create actual recipe reqs with correct params
SurgeryType.find(s).surgery_recipe_reqs.each do |req|
  supply_item = req.supply_list_id
  ActualRecipeReq.create(
    qty:0,
    supply_list_id:supply_item,
    surgery_appt_id:this_surgery.id)
end






#=======================================================================
#=======================================================================
#=======================================================================
#CALCULATING DEMAND AND SUBTRACTING FROM INVENTORY
#capture supplylist item into variable
#variable declarations
this_supply = SupplyList.find(1)
actual_consumed = 0
this_clinic = Clinic.find(1)
this_supply_at_clinic = this_clinic.inventories.where(supply_list_id: this_supply)
this_supply_at_clinic_qty = 0

#Collect actual_recipe_req by item and qty
#add them all together one by one
#and store them in a variable called this_supply_qty
SurgeryAppt.all.each do |appt|
  appt.actual_recipe_reqs.where(supply_list_id: this_supply).each do |item|
    actual_consumed += item.qty
  end
end

#collect the pertinent inventories of the clinic
#add them all together one by one
#and store them in a variable called this_supply_at_clinic_qty
this_supply_at_clinic.each do |inventory|
  this_supply_at_clinic_qty += inventory.qty
end

#complete the transactions
#create new inventory variable by subracting the demand from the inventory
new_inventory = this_supply_at_clinic_qty -= actual_consumed
#complete the SQL updates below
this_supply_at_clinic.first.update(qty:new_inventory)


p "The Clinic #{this_clinic.clinic_name} has Inventory of #{this_supply.item_name} @ #{this_supply_at_clinic_qty} units, they have a actual consumption for #{actual_consumed} units"
