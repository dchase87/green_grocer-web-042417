def consolidate_cart(cart)
  count_hash = Hash.new(0)
  item_list = cart.uniq
  new_hash = {}

  cart.each do |element|
    count_hash[element] += 1
  end

  count_hash.each do |item_hash, count|
    item_hash.each do |item, item_data|
      item_data[:count] = count
      new_hash[item] = item_data
    end
  end
  new_hash
end

def get_number_of_coupons(coupons)
  count_hash = Hash.new(0)
  coupon_list = coupons.uniq
  new_hash = {}

  coupons.each do |element|
    count_hash[element] += 1
  end

  count_hash.each do |coupon_hash, count|
    coupon_list << coupon_hash[:count] = count
  end

  coupon_list.select do |element|
    element.kind_of?(Hash)
  end
end

def apply_coupons(cart, coupons)
  coupon_list = get_number_of_coupons(coupons)

  updated_cart = {}

  cart.each do |item, item_data|
    updated_cart[item] = item_data

    coupon_list.each do |coupon_hash|
      if coupon_hash[:item] == item
        updated_cart["#{item} W/COUPON"] = {:price => coupon_hash[:cost], :clearance => item_data[:clearance]}
        if item_data[:count] >= (coupon_hash[:num] * coupon_hash[:count])
          updated_cart["#{item} W/COUPON"][:count] = coupon_hash[:count]
          updated_cart[item][:count] = item_data[:count] - (coupon_hash[:num] * coupon_hash[:count])
        elsif item_data[:count] < (coupon_hash[:num] * coupon_hash[:count])
          coupon_count = 1
          until (coupon_count * coupon_hash[:num]) < item_data[:count] do
            coupon_count += 1

          end

          updated_cart["#{item} W/COUPON"][:count] = coupon_count
          updated_cart[item][:count] = item_data[:count] - (coupon_count * coupon_hash[:num])
        end
      end
    end
  end

  updated_cart
end



def apply_clearance(cart)
  updated_cart = {}

  cart.each do |item, item_data|
    updated_cart[item] = item_data
    if item_data[:clearance] == true
      discount_price = item_data[:price].to_f - (item_data[:price].to_f * 0.2)
      updated_cart[item][:price] = discount_price
    end
  end
  updated_cart
end

def checkout(cart, coupons)
  new_cart = consolidate_cart(cart)

  cart_item_costs = []

  if new_cart.length == 1
    coupon_cart = apply_coupons(new_cart, coupons)
    clearance_cart = apply_clearance(coupon_cart)
    clearance_cart.each do |item, item_data|
      cart_item_costs << (item_data[:price] * item_data[:count])
    end
  elsif new_cart.length > 1
    coupon_cart = apply_coupons(new_cart, coupons)
    clearance_cart = apply_clearance(coupon_cart)
    clearance_cart.each do|item, item_data|
      cart_item_costs << (item_data[:price] * item_data[:count])
    end
  end
  apply_discount(cart_item_costs.inject {|sum, n| sum + n})
end

def apply_discount(total)
  if total > 100
    total.to_f - (total.to_f * 0.1)
  else
    total
  end
end
